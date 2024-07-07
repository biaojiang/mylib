from PIL import Image
import piexif
import re
import datetime
import os
import pytz
import argparse


def extract_timestamp(filename):
    # First pattern: screenshot_20xx-11-24-07-29-02png
    match1 = re.search(
        r"screenshot_(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})png", filename, re.IGNORECASE
    )
    if match1:
        timestamp_str = match1.group(1)
        timestamp = datetime.datetime.strptime(timestamp_str, "%Y-%m-%d-%H-%M-%S")
        return timestamp

    # Second pattern: Screenshot 2024-04-24 at 08.35.25
    match2 = re.search(
        r"Screenshot (\d{4}-\d{2}-\d{2}) at (\d{2})\.(\d{2})\.(\d{2})",
        filename,
        re.IGNORECASE,
    )
    if match2:
        date_str = match2.group(1)
        time_str = f"{match2.group(2)}:{match2.group(3)}:{match2.group(4)}"
        timestamp_str = f"{date_str} {time_str}"
        timestamp = datetime.datetime.strptime(timestamp_str, "%Y-%m-%d %H:%M:%S")
        return timestamp

    return None


def get_timezone_offset(timestamp, timezone_str="Europe/Stockholm"):
    tz = pytz.timezone(timezone_str)
    localized_timestamp = tz.localize(timestamp)
    offset = localized_timestamp.strftime("%z")
    formatted_offset = f"{offset[:3]}:{offset[3:]}"  # Convert +0200 to +02:00
    return formatted_offset


def add_metadata_to_png(image_path, timestamp, timezone):
    img = Image.open(image_path)
    exif_dict = {"Exif": {}}

    # Convert timestamp to the appropriate format for EXIF without timezone
    timestamp_str = timestamp.strftime("%Y:%m:%d %H:%M:%S")

    # Update EXIF data
    exif_dict["Exif"][piexif.ExifIFD.DateTimeOriginal] = timestamp_str
    exif_dict["Exif"][piexif.ExifIFD.DateTimeDigitized] = timestamp_str

    # Convert back to bytes
    exif_bytes = piexif.dump(exif_dict)

    # Save the image with new EXIF data
    img.save(image_path, "png", exif=exif_bytes)

    # Update the file modification time with timezone offset
    mod_timestamp_str = timestamp_str + timezone
    mod_time = datetime.datetime.strptime(
        mod_timestamp_str, "%Y:%m:%d %H:%M:%S%z"
    ).timestamp()
    os.utime(image_path, (mod_time, mod_time))


def process_folder(folder_path, timezone_str):
    # Loop through all files in the folder
    for filename in os.listdir(folder_path):
        if filename.endswith(".png"):
            # Construct full path
            image_path = os.path.join(folder_path, filename)

            print(f"Processing {image_path}...")

            # Extract timestamp from the filename
            timestamp = extract_timestamp(filename)
            if timestamp:
                timezone = get_timezone_offset(timestamp, timezone_str)
                add_metadata_to_png(image_path, timestamp, timezone)
                print(
                    f"Metadata and modification time updated for {image_path} with timezone {timezone}"
                )
            else:
                print("Timestamp not found in filename")


def process_single_image(image_path, timezone_str):
    print(f"Processing {image_path}...")

    # Extract timestamp from the filename
    filename = os.path.basename(image_path)
    timestamp = extract_timestamp(filename)
    if timestamp:
        timezone = get_timezone_offset(timestamp, timezone_str)
        add_metadata_to_png(image_path, timestamp, timezone)
        print(
            f"Metadata and modification time updated for {image_path} with timezone {timezone}"
        )
    else:
        print("Timestamp not found in filename")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Add timestamp to PNG metadata and update file modification time."
    )
    parser.add_argument("path", type=str, help="Path to a folder or a single PNG file.")
    parser.add_argument(
        "--timezone",
        type=str,
        default="Europe/Stockholm",
        help="Timezone to use for file modification time (default: Europe/Stockholm).",
    )
    parser.add_argument(
        "--batch",
        action="store_true",
        default=True,
        help="Process all PNG files in the folder if set. Process a single file if not set.",
    )

    args = parser.parse_args()
    path = os.path.expanduser(args.path)

    if args.batch:
        if os.path.isdir(path):
            process_folder(path, args.timezone)
        else:
            print(f"Error: {path} is not a directory.")
    else:
        if os.path.isfile(path) and path.endswith(".png"):
            process_single_image(path, args.timezone)
        else:
            print(f"Error: {path} is not a valid PNG file.")
