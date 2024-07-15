#!/usr/bin/env fish

function extract_timestamp
    set filename $argv[1]

    # First pattern: screenshot_20xx-11-24-07-29-02png
    if string match -r -q "(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})" $filename
        set match (string match -r -g "(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})" $filename)
        set timestamp_str $match[1]
        set timestamp (date -j -f "%Y-%m-%d-%H-%M-%S" $timestamp_str "+%Y:%m:%d %H:%M:%S")
        echo $timestamp
        return
    end

    # Second pattern: Screenshot 2024-04-24 at 08.35.25 (mac)
    if string match -r -q "Screenshot (\d{4}-\d{2}-\d{2}) at (\d{2})\.(\d{2})\.(\d{2})" $filename
        set match (string match -r -g "Screenshot (\d{4}-\d{2}-\d{2}) at (\d{2})\.(\d{2})\.(\d{2})" $filename)
        set date_str $match[1]
        set hour $match[2]
        set minute $match[3]
        set second $match[4]
        set time_str "$hour:$minute:$second"
        set timestamp_str "$date_str $time_str"
        set timestamp (date -j -f "%Y-%m-%d %H:%M:%S" "$timestamp_str" "+%Y:%m:%d %H:%M:%S")
        echo $timestamp
        return
    end

    # Third pattern: signal-2024-07-13-204822_002
    if string match -r -q "(\d{4}-\d{2}-\d{2}-\d{6})" $filename
        set match (string match -r -g "(\d{4}-\d{2}-\d{2}-\d{6})" $filename)
        set timestamp_str $match[1]
        set timestamp (date -j -f "%Y-%m-%d-%H%M%S" $timestamp_str "+%Y:%m:%d %H:%M:%S")
        echo $timestamp
        return
    end

    # Fourth pattern: LWScreenShot_2023_12_19_at_18.28.21
    if string match -r -q "(\d{4}_\d{2}_\d{2})_at_(\d{2}\.\d{2}\.\d{2})" $filename
        set match (string match -r -g "(\d{4}_\d{2}_\d{2})_at_(\d{2}\.\d{2}\.\d{2})" $filename)
        set timestamp_str $match[1]_$match[2]
        set timestamp (date -j -f "%Y_%m_%d_%H.%M.%S" $timestamp_str "+%Y:%m:%d %H:%M:%S")
        echo $timestamp
        return
    end

    # Fifth pattern: 2019-05-08, 15_58 Office Lens
    if string match -r -q "(\d{4}-\d{2}-\d{2}), (\d{2}_\d{2})" $filename
        set match (string match -r -g "(\d{4}-\d{2}-\d{2}), (\d{2}_\d{2})" $filename)
        set timestamp_str $match[1]-$match[2]
        set timestamp (date -j -f "%Y-%m-%d-%H_%M" $timestamp_str "+%Y:%m:%d %H:%M:%S")
        echo $timestamp
        return
    end

end

function get_timezone_offset
    set timestamp (date -j -f "%Y:%m:%d %H:%M:%S" "$argv[1]" +%s)
    if test -n $argv[2]
        set timezone_str $argv[2]
    else
        set timezone_str Europe/Stockholm
    end
    set offset (TZ=$timezone_str date -r $timestamp +%z)
    set formatted_offset (string sub -l 3 $offset)":"(string sub -s 4 $offset) # Convert +0200 to +02:00
    echo $formatted_offset
end

function add_metadata_to_png
    set image_path $argv[1]
    set timestamp $argv[2]
    set timezone $argv[3]
    set force $argv[4]

    # set timestamp_str (date -j -f "%Y:%m:%d %H:%M:%S" $timestamp "+%Y:%m:%d %H:%M:%S")
    # set mod_timestamp_str $timestamp_str$timezone

    # Check if the EXIF keys already exist
    set existing_metadata (exiftool -DateTimeOriginal -CreateDate "$image_path")

    if test "$force" != true
        if echo $existing_metadata | grep -q "Date/Time Original"; or echo $existing_metadata | grep -q "Create Date"
            echo "EXIF metadata already exists for $image_path. Skipping update."
            return
        end
    end

    # Update EXIF data using exiftool
    exiftool -overwrite_original "-DateTimeOriginal=$timestamp" "-CreateDate=$timestamp" "$image_path"

    set mod_time (TZ=$timezone date -j -f "%Y:%m:%d %H:%M:%S" "$timestamp" +%s)

    # Convert mod_time to a format touch can use
    set touch_time (TZ=$timezone date -r $mod_time +"%Y%m%d%H%M.%S")

    # Update the file modification time
    touch -t $touch_time "$image_path"

end

function process_folder
    set folder_path $argv[1]
    set timezone_str $argv[2]
    set input_timestamp $argv[3]
    set force $argv[4]

    # Loop through all files in the folder
    for filename in (ls $folder_path)
        if string match -r -i ".(png|jpg|jpeg)" "$filename"
            set image_path "$folder_path/$filename"
            echo "Processing $image_path..."

            # Extract timestamp from the filename
            set filename (basename $image_path)
            if test -n "$input_timestamp"
                set timestamp $input_timestamp
            else
                set timestamp (extract_timestamp $filename)
            end

            if test -n "$timestamp"
                set timezone (get_timezone_offset $timestamp $timezone_str)

                # Call the function and capture the output
                set output (add_metadata_to_png $image_path $timestamp $timezone $force)

                # Check if the output contains the "already" message
                if echo $output | grep -q already
                    echo $output
                else
                    echo "Metadata and modification time updated for $image_path with timezone $timezone"
                end

            else
                echo "Timestamp not found in filename for $image_path. Skipping..."
            end
        end
    end
end

function process_single_image
    set image_path $argv[1]
    set timezone_str $argv[2]
    set input_timestamp $argv[3]
    set force $argv[4]

    echo "Processing $image_path..."

    # Extract timestamp from the filename
    set filename (basename $image_path)
    if test -n "$input_timestamp"
        set timestamp $input_timestamp
    else
        set timestamp (extract_timestamp $filename)
    end

    echo $timestamp

    if test -n "$timestamp"
        set timezone (get_timezone_offset $timestamp $timezone_str)
        echo $timezone

        # Call the function and capture the output
        set output (add_metadata_to_png $image_path $timestamp $timezone $force)

        # Check if the output contains the "already" message
        if echo $output | grep -q already
            echo $output
        else
            echo "Metadata and modification time updated for $image_path with timezone $timezone"
        end
    else
        echo "Timestamp not found in filename for $image_path. Skipping..."
    end
end

# Parse arguments
set path $argv[1]
set timezone_str Europe/Stockholm
set batch false
set input_timestamp ""
set force false

if contains -- --timezone $argv
    set timezone_str $argv[(math (contains -i -- --timezone $argv) +1)]
end

if contains -- --batch $argv
    set batch true
end

if contains -- --timestamp $argv
    set input_timestamp (date -j -f "%Y-%m-%d %H:%M:%S" $argv[(math (contains -i  -- --timestamp $argv) +1 )] "+%Y:%m:%d %H:%M:%S")
    echo $input_timestamp
end

if contains -- --force $argv
    set force true
end

# Check if the path is a directory or a file
if test -d $path
    if test $batch = true
        process_folder $path $timezone_str $input_timestamp $force
    else
        echo "Error: $path is a directory, but batch mode is not enabled."
    end
else if test -f $path; and string match -r -i -q ".(png|jpg|jpeg)" $path
    process_single_image $path $timezone_str $input_timestamp $force
else
    echo "Error: $path is not a valid PNG, JPG, or JPEG file or directory."
end
