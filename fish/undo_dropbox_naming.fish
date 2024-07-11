#!/usr/bin/env fish

# Function to print usage
function print_usage
    echo "Usage: $argv[0] <folder_path> [--dry-run]"
    exit 1
end

# Check if the correct number of arguments are provided
if test (count $argv) -lt 1 -o (count $argv) -gt 2
    print_usage
end

# Define the folder from the input argument
set folder_path $argv[1]

# Check for the dry-run option
set dry_run false
if test (count $argv) -eq 2 -a $argv[2] = --dry-run
    set dry_run true
end

# Ensure the folder exists
if not test -d $folder_path
    echo "Error: Directory $folder_path does not exist."
    exit 1
end

# Loop through the files in the folder and rename them
for file in $folder_path/*
    # Extract the filename without the folder path
    set base_name (basename $file)

    # Check if the file matches the pattern yyyy-mm-dd - filename
    if echo $base_name | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} - .+$'
        # Extract the new filename (part after the ' - ')
        set new_file_name (echo $base_name | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2} - //')

        # Define the full new path
        set new_file_path "$folder_path/$new_file_name"

        # Print what would be done in dry run mode
        if test $dry_run = true
            echo "Would rename: $file -> $new_file_path"
        else
            # Rename the file
            mv $file $new_file_path
            echo "Renamed: $file -> $new_file_path"
        end
    end
end

if test $dry_run = true
    echo "Dry run complete. No files were actually renamed."
else
    echo "All applicable files have been renamed."
end
