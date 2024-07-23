# update_exif.fish

## Overview

The `update_exif.fish` script is a utility for updating the EXIF metadata of PNG, JPG, and JPEG images. It can process single images or batch process all images in a directory.

## Usage

### Basic Usage

To process a single image:

```sh
./update_exif.fish path/to/image --timezone Europe/Stockholm
```

To process all images in a directory:

```sh
./update_exif.fish path/to/directory --timezone Europe/Stockholm --batch
```

### Arguments

- `path`: The path to the image file or directory containing image files.
- `--timezone`: The timezone to use for the metadata (default is `Europe/Stockholm`).
- `--batch`: Enable batch mode to process all images in the directory.
- `--timestamp`: Specify a timestamp to use for the EXIF metadata. Format: `YYYY-MM-DD HH:MM:SS`.
- `--force`: Force update of EXIF metadata even if it already exists.

### Examples

#### Single Image Processing

```sh
./update_exif.fish /path/to/image.png --timezone Europe/Stockholm
```

#### Batch Processing

`./update_exif.fish /path/to/images --timezone Europe/Stockholm --batch`

#### Use JSON metadata

`./update_exif.fish /path/to/images --timezone Europe/Stockholm --batch --json`

#### Specifying a Timestamp

```sh
./update_exif.fish /path/to/image.jpg --timezone Europe/Stockholm --timestamp "2024-07-03 14:41:11"
```

#### Forcing Metadata Update

```sh
./update_exif.fish /path/to/image.jpeg --timezone Europe/Stockholm --force
```

## Notes

- Ensure you have `exiftool` installed on your system.
- The script will only process PNG, JPG, and JPEG files.
