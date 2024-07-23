#!/usr/bin/env fish

# Check if exiftool is installed
if not command -v exiftool >/dev/null
    echo "exiftool could not be found. Please install exiftool and try again."
    exit 1
end

# Function to print usage
function print_usage
    echo "Usage: rename_media.fish <folder_path|file_path> [--dry-run] [--batch] [--desp <description>]"
    exit 1
end

# Check if the correct number of arguments are provided
if test (count $argv) -lt 1 -o (count $argv) -gt 6
    print_usage
end

# Define the path from the input argument
set path $argv[1]

# Check for the dry-run option
set dry_run false
set batch_mode false
set description ""

if contains -- --dry-run $argv
    set dry_run true
end

if contains -- --batch $argv
    set batch_mode true
end

if contains -- --desp $argv
    set description $argv[(math (contains -i -- --desp $argv) +1 )]
end

# Ensure the folder or file exists
if not test -e "$path"
    echo "Error: $path does not exist."
    exit 1
end

# Debug statement: print path and dry-run status
echo "Processing path: $path"
if test "$dry_run" = true
    echo "Dry-run mode enabled"
else
    echo "Dry-run mode disabled"
end

# Function to extract a valid date from the metadata
function get_valid_date
    for tag in DateTimeOriginal CreateDate ModifyDate ProfileDateTime
        set date_time (exiftool -s3 -$tag "$argv[1]")
        if test -n "$date_time"
            set date_part (echo $date_time | cut -d' ' -f1)
            if string match -r -q "20[0-9][0-9]:[0-1][0-9]:[0-3][0-9]" "$date_part"
                set month (echo $date_part | cut -d':' -f2)
                set day (echo $date_part | cut -d':' -f3)
                if test "$month" != 00 -a "$day" != 00
                    echo $date_time
                    return
                end
            end
        end
    end
    echo ''
end

# Loop through the files in the folder
function process_file
    set file $argv[1]
    echo "Process $file."

    # Extract the folder path
    set folder_path (dirname "$file")

    # Extract the base name of the file
    set base_name (basename "$file")
    # Strip the extension from base_name
    set base_name (string replace -r '\.[^.]*$' '' $base_name)

    # Check if the base name already contains a date pattern
    if string match -r "20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]" "$base_name"
        echo "File $file already has a date pattern. Skipping..."
        return
    else if string match -r "20[0-9][0-9][0-1][0-9][0-3][0-9]" "$base_name"
        echo "File $file already has a date pattern. Skipping..."
        return
    end

    # Determine if basename starts with IMG or DSC
    set keep_basename true
    for prefix in IMG DSC mmexport
        if string match -qr "^$prefix" $base_name
            set keep_basename false
            break
        end
    end

    # Extract the description part if base name starts with IMG
    if test "$batch_mode" = true
        set description ""
    end
    if test -z "$description"
        if string match -qr "^IMG_[0-9]{4}" $base_name
            set description (string replace -r 'IMG_[0-9]{4}' '' $base_name)
        end
    end

    # Check if the base name starts with "mmexport"
    if string match -qr "^mmexport" "$base_name"
        set suffix _wechat
    else
        set suffix ""
    end

    # Extract the creation date using exiftool
    set date_time (get_valid_date "$file")
    if test -z "$date_time"
        echo "Invalid or missing creation date for $file. Skipping..."
        return
    end

    set creation_date (echo $date_time | cut -d' ' -f1 | tr ':' '-')
    set creation_time (echo $date_time | cut -d' ' -f2 | tr -d ':')

    # Debug statement: print creation date and time
    echo "Found creation time for $file: $creation_date $creation_time"

    # Determine the file extension
    set extension (echo "$file" | awk -F. '{print $NF}')
    # Decide on the base name to use and create the initial new file name
    if test "$keep_basename" = true
        echo Keep
        set new_file_name "$creation_date"_"$creation_time"_"$base_name$suffix.$extension"
    else if test -n "$description"
        echo "Keep description $description"
        set new_file_name "$creation_date"_"$creation_time$description$suffix.$extension"
    else
        echo "Name with timestamp"
        set new_file_name "$creation_date"_"$creation_time$suffix.$extension"
    end
    # set new_file_name "$creation_date"_"$creation_time$suffix.$extension"

    # Ensure the new file name is unique
    set counter 1
    set final_new_file_name "$new_file_name"
    while test -e "$folder_path/$final_new_file_name"
        set base_name_new_file (string replace -r '\.[^.]*$' '' $new_file_name)
        set final_new_file_name "$base_name_new_file"_$counter.$extension
        set counter (math $counter + 1)
    end

    # Debug statement: print final new file name
    echo "Final new file name: $final_new_file_name"

    # Define the full new path
    set new_file_path "$folder_path/$final_new_file_name"

    # Print what would be done in dry run mode
    if test "$dry_run" = true
        echo "Would rename: $file -> $new_file_path"
    else
        # Rename the file
        mv "$file" "$new_file_path"
        echo "Renamed: $file -> $new_file_path"
    end
end


# Process files based on the batch mode
if test "$batch_mode" = true
    # Loop through the files in the folder
    for file in (fd . -e png -e jpg -e jpeg -e heic -e gif -e mp4 -e mov $path)
        process_file "$file"
        echo ""
    end
else
    process_file "$path"
end


if test "$dry_run" = true
    echo "Dry run complete. No files were actually renamed."
else
    echo "All applicable files have been renamed."
end
