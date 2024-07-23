#!/usr/bin/env fish

function extract_timestamp
    set image_path $argv[1]

    set filename (basename $image_path)
    # First pattern: screenshot_20xx-11-24-07-29-02png
    if string match -r -q "(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})" $filename
        set match (string match -r -g "(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})" $filename)
        set timestamp_str $match[1]
        set timestamp (date -j -f "%Y-%m-%d-%H-%M-%S" $timestamp_str "+%Y:%m:%d %H:%M:%S")
        echo $timestamp
        return
    end

    # Second pattern: Screenshot 2024-04-24 at 08.35.25 (mac)
    if string match -r -q "(\d{4}-\d{2}-\d{2}) at (\d{2})\.(\d{2})\.(\d{2})" $filename
        set match (string match -r -g "(\d{4}-\d{2}-\d{2}) at (\d{2})\.(\d{2})\.(\d{2})" $filename)
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

    # Sixth pattern: Screenshot 2024-04-24 08.35.25 (dropbox naming automation)
    if string match -r -q "(\d{4}-\d{2}-\d{2}) (\d{2})\.(\d{2})\.(\d{2})" $filename
        set match (string match -r -g "(\d{4}-\d{2}-\d{2}) (\d{2})\.(\d{2})\.(\d{2})" $filename)
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

    # If can't find timestamp from the filename, check whether already exists
    set existing_metadata (exiftool -DateTimeOriginal -CreateDate "$image_path")

    # If no timestamp found and no existing metadata, skip processing
    if test -n "$existing_metadata"
        echo "Timestamp found in existing metadata for $image_path."
    end

end

function extract_photo_taken_time
    set json_file $argv[1]
    set raw_timestamp (jq -r '.photoTakenTime.formatted' $json_file)

    # Debugging: print the raw timestamp
    # Sep 17, 2022, 12:10:34 PM UTC
    # echo "Raw timestamp: $raw_timestamp"

    # Extract date and time components using regex
    set match (echo $raw_timestamp | string match -r -g '(\w{3}) (\d{1,2}), (\d{4}), (\d{1,2}):(\d{2}):(\d{2})[\s ]*(AM|PM)[\s ]*(UTC|[A-Z]{1,3})')

    if test (count $match) -eq 0
        echo "Failed to parse date string: $raw_timestamp"
        return
    end

    # echo "Match: $match"

    # Assign extracted components to variables
    set month_str $match[1]
    set day $match[2]
    set year $match[3]
    set hour $match[4]
    set minute $match[5]
    set second $match[6]
    set period $match[7]
    set timezone $match[8]

    # Convert month name to numerical value
    switch $month_str
        case Jan
            set month 01
        case Feb
            set month 02
        case Mar
            set month 03
        case Apr
            set month 04
        case May
            set month 05
        case Jun
            set month 06
        case Jul
            set month 07
        case Aug
            set month 08
        case Sep
            set month 09
        case Oct
            set month 10
        case Nov
            set month 11
        case Dec
            set month 12
    end

    # Convert the 12-hour format to 24-hour format if necessary
    if test "$period" = PM -a "$hour" != 12
        set hour (math "$hour + 12")
    end
    if test "$period" = AM -a "$hour" = 12
        set hour 00
    end

    # Convert single-digit day and hour to double digits if necessary
    set day (printf "%02d" $day)
    set hour (printf "%02d" $hour)

    # Create the timestamp string in the format "YYYY:MM:DD HH:MM:SS"
    set timestamp_str "$year:$month:$day $hour:$minute:$second"

    # echo "TS from json: $timestamp_str"

    set timestamp_epoch (TZ=UTC date -j -f "%Y:%m:%d %H:%M:%S" "$timestamp_str" +%s)
    # echo "TS epoch from json: $timestamp_epoch"

    # Convert the epoch timestamp to EXIF format
    set timestamp_exif (TZ=Europe/Stockholm date -r $timestamp_epoch "+%Y:%m:%d %H:%M:%S")

    echo $timestamp_exif
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

function map_offset_to_timezone
    set offset $argv[1]

    switch $offset
        case "+01:00"
            echo Europe/Paris
        case "+02:00"
            echo Europe/Helsinki
        case "+03:00"
            echo Europe/Moscow
        case "+08:00"
            echo Asia/Shanghai
            # Add more cases as needed
        case "*"
            echo UTC # Default fallback
    end
end

function add_metadata_to_png
    set image_path $argv[1]
    set timestamp $argv[2]
    set timezone $argv[3]
    set force $argv[4]
    set timezone_str $argv[5]

    # set timestamp_str (date -j -f "%Y:%m:%d %H:%M:%S" $timestamp "+%Y:%m:%d %H:%M:%S")
    # set mod_timestamp_str $timestamp_str$timezone
    # Check if the EXIF keys already exist
    set existing_metadata (exiftool -DateTimeOriginal -CreateDate "$image_path")
    set has_original (echo $existing_metadata | grep -c "Date/Time Original")
    set has_create (echo $existing_metadata | grep -c "Create Date")
    set has_modify_date (echo $existing_metadata | grep -c "Modify Date")

    # Get the current modification time of the file
    set current_mod_time (date -r (stat -f %m "$image_path") "+%Y:%m:%d %H:%M:%S")

    # Extract the existing DateTimeOriginal
    set existing_original_time ""
    if test $has_original -gt 0
        set existing_original_time (exiftool -DateTimeOriginal -d "%Y:%m:%d %H:%M:%S" -s3 "$image_path")
    end

    # Determine whether to update the modification time
    set update_mod_time true
    if test "$current_mod_time" = "$existing_original_time"
        set update_mod_time false
        echo "Modification time already matches DateTimeOriginal for $image_path. Skipping update."
    end

    if echo $timestamp | grep -q "found in existing metadata"

        if test $has_original -gt 0
            # Extract the existing Date Time Original
            set timestamp_with_tz (exiftool -DateTimeOriginal -d "%Y:%m:%d %H:%M:%S%z" -s3 "$image_path")
            echo "Timestamp extracted from Date Time Original"
        else if test "$has_create" -gt 0
            # Extract the existing Create Date
            set timestamp_with_tz (exiftool -CreateDate -d "%Y:%m:%d %H:%M:%S%z" -s3 "$image_path")
            echo "Timestamp extracted from Create Date"
        else if test "$has_modify_date" -gt 0
            set timestamp_with_tz (exiftool -ModifyDate -d "%Y:%m:%d %H:%M:%S%z" -s3 "$image_path")
            echo "Timestamp extracted from Modify Date"

        end

        # Extract the timezone part 2013:03:11 23:01:03+08:00
        set timestamp (string sub -l 19 "$timestamp_with_tz")
        set timezone_from_exif (string sub -s 20 "$timestamp_with_tz")

        # Set the timezone variable if it's not empty
        if test -n "$timezone_from_exif"
            # Format the timezone to include the colon
            set formatted_timezone (string sub -l 3 $timezone_from_exif)":"(string sub -s 4 $timezone_from_exif)
            set timezone $formatted_timezone
        else
            set timezone (get_timezone_offset $timestamp $timezone_str)
        end

        echo "Timezone:$timezone"

        if test "$force" != true
            if test $has_original -gt 0
                echo "Date/Time Original already exists for $image_path. Skipping metadata update, but updating modification time.."
            else
                exiftool -overwrite_original "-DateTimeOriginal=$timestamp" "$image_path"
            end
        else
            set timezone (get_timezone_offset $timestamp $timezone_str)
            # Update EXIF data using exiftool
            exiftool -overwrite_original "-DateTimeOriginal=$timestamp" "$image_path"
            echo "Metadata and modification time updated for $image_path with timezone $timezone"
        end
    else

        if test "$force" != true
            if test $has_original -gt 0
                echo "EXIF metadata already exists for $image_path. Skipping update."
            else

                # Update only DateTimeOriginal with the value from Create Date
                exiftool -overwrite_original "-DateTimeOriginal=$timestamp" "-CreateDate=$timestamp" "$image_path"
                echo "Updated DateTimeOriginal with input or filename timestamp for $image_path."
            end
        else

            # Update EXIF data using exiftool
            exiftool -overwrite_original "-DateTimeOriginal=$timestamp" "-CreateDate=$timestamp" "$image_path"
            echo "Metadata and modification time forcely updated for $image_path with timezone $timezone"
        end
    end

    # Check if timezone offsets already exist
    set existing_offsets (exiftool -OffsetTime -OffsetTimeOriginal "$image_path")
    set has_offset (echo $existing_offsets | grep -c "Offset Time")

    if test "$force" = true -o "$has_offset" -eq 0
        # Update timezone offsets
        exiftool -overwrite_original "-OffsetTime=$timezone" "-OffsetTimeOriginal=$timezone" "$image_path"
        echo "Timezone offsets updated for $image_path."
    else
        echo "Timezone offsets already exist for $image_path. Skipping update."
    end

    # Update the file modification time if needed
    if test "$force" = true -o "$update_mod_time" = true
        # Update the file modification time
        set timezone_name (map_offset_to_timezone $timezone)
        set mod_time (TZ=$timezone_name date -j -f "%Y:%m:%d %H:%M:%S" "$timestamp" +%s)

        # Convert mod_time to a format touch can use
        set touch_time (TZ=Europe/Stockholm date -r $mod_time +"%Y%m%d%H%M.%S")
        # Update the file modification time
        touch -t $touch_time "$image_path"
        echo "Modification time updated for $image_path with timezone $timezone"
    end

end


function process_folder
    set folder_path $argv[1]
    set timezone_str $argv[2]
    set input_timestamp $argv[3]
    set force $argv[4]
    set use_json $argv[5] # Google Photos

    # Loop through all files in the folder
    # for filename in (ls $folder_path)
    #     if string match -r -i ".(png|jpg|jpeg)" "$filename"
    #         set image_path "$folder_path/$filename"
    # Find all files in the folder and subfolders
    for image_path in (fd . -e png -e jpg -e jpeg -e heic -e gif -e mp4 -e mov -e m2ts -e MTS $folder_path)
        echo "Processing $image_path..."

        # Extract timestamp from the filename or JSON
        set filename (basename $image_path)
        if test "$use_json" = true
            set json_file "$image_path.json"
            if test -f $json_file
                set timestamp (extract_photo_taken_time $json_file)
                echo "Extracted timestamp from JSON: $timestamp"
            else
                echo "JSON metadata file not found for $image_path. Skipping..."
                continue
            end
        else if test -n "$input_timestamp"
            set timestamp $input_timestamp
            echo "Using input timestamp: $timestamp"
        else
            set timestamp (extract_timestamp $image_path)
            echo "Extracted timestamp from filename or metadata: $timestamp"
        end

        if test -n "$timestamp"
            # If timestamp is not found, we still proceed to check CreateDate in add_metadata_to_png

            if echo "$timestamp" | grep -q "found in existing metadata"

                set timezone ""
            else
                set timezone (get_timezone_offset $timestamp $timezone_str)
            end

            # Call the function and capture the output
            set output (add_metadata_to_png $image_path $timestamp $timezone $force $timezone_str)

            # Check if the output contains the "already" message
            # if echo $output | grep -q already
            echo $output
            # else
            #     echo "Metadata and modification time updated for $image_path with timezone $timezone"
            # end

        else
            echo "Timestamp not found in filename for $image_path. Skipping..."
        end
        echo ""
    end
end

function process_single_image
    set image_path $argv[1]
    set timezone_str $argv[2]
    set input_timestamp $argv[3]
    set force $argv[4]
    set use_json $argv[5]

    echo "Processing $image_path..."
    # Extract timestamp from the filename or JSON
    set filename (basename $image_path)
    set timestamp ""

    if test "$use_json" = true
        set json_file "$image_path.json"
        if test -f $json_file
            set timestamp (extract_photo_taken_time $json_file)
            echo "Extracted timestamp from JSON: $timestamp"
        else
            echo "JSON metadata file not found for $image_path. Skipping..."
            return
        end
    else if test -n "$input_timestamp"
        set timestamp $input_timestamp
        echo "Using input timestamp: $timestamp"
    else
        set timestamp (extract_timestamp $image_path)
        echo "Extracted timestamp from filename: $timestamp"
    end

    if test -n "$timestamp"
        # If timestamp is not found, we still proceed to check CreateDate in add_metadata_to_png
        set timezone ""
        if not echo "$timestamp" | grep -q "found in existing metadata"
            set timezone (get_timezone_offset $timestamp $timezone_str)
            echo "Computed timezone offset: $timezone"
        end

        # Call the function and capture the output
        set output (add_metadata_to_png $image_path $timestamp $timezone $force $timezone_str)

        echo $output
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
set use_json false

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

if contains -- --json $argv
    set use_json true
end

# Check if the path is a directory or a file
if test -d $path
    if test $batch = true
        process_folder $path $timezone_str $input_timestamp $force $use_json
    else
        echo "Error: $path is a directory, but batch mode is not enabled."
    end
else if test -f $path; and string match -r -i -q ".(png|jpg|jpeg|heic|gif|mp4|mov|m2ts|MTS)" $path
    process_single_image $path $timezone_str $input_timestamp $force $use_json
else
    echo "Error: $path is not a valid PNG, JPG, or JPEG file or directory."
end

# Usage
# --Asia/Shanghai (to set Chinese timezone)
# ./update_exif.fish /path/to/image --timezone Asia/Shanghai --timestamp "2012-06-01 08:00:00"
