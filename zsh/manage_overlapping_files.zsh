#!/bin/zsh

# Check if the correct number of arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <small_folder> <big_folder> [--remove]"
    exit 1
fi

# Define the directories from the input arguments
small_folder="$1"
big_folder="$2"

# Check if the --remove flag is provided
remove_flag=false
if [ "$#" -eq 3 ] && [ "$3" = "--remove" ]; then
    remove_flag=true
fi

# Define the output file paths
small_files_path=~/Downloads/small_files.txt
big_files_path=~/Downloads/big_files.txt
overlapping_files_path=~/Downloads/overlapping_files.txt

# Generate file lists for all files recursively
fd --type f --base-directory "$small_folder" > "$small_files_path"
fd --type f --base-directory "$big_folder" > "$big_files_path"

# Sort the file lists in place
sort "$small_files_path" -o "$small_files_path"
sort "$big_files_path" -o "$big_files_path"

# Find overlapping files and write to the output file
comm -12 "$small_files_path" "$big_files_path" > "$overlapping_files_path"

# Conditionally remove the overlapping files
if [ "$remove_flag" = true ]; then
    while IFS= read -r file; do
        full_path="$small_folder/$file"
        
        if [ -f "$full_path" ]; then
            rm "$full_path"
            echo "Removed: $full_path"
        fi
    done < "$overlapping_files_path"
    echo "Removed all overlapping files listed in $overlapping_files_path"
else
    echo "Overlapping files listed in $overlapping_files_path (no files were removed)"
fi
