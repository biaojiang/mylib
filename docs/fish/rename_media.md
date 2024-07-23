# Rename Media Files (PNG, JPG, MOV, mp4, etc.) Script Documentation

## Overview

The `rename_media.fish` script is designed to rename media files (images and videos) in a specified folder or a single file based on their creation date and time metadata. It also allows appending a custom description to the filenames.

## Usage

```sh
./rename_media.fish <path >[--dry-run] [--batch] [--desp <description >]
```
### Arguments

- `<path>`: The path to the file or directory containing the files to be renamed. This can be an absolute or relative path.
- `--dry-run`: (Optional) If specified, the script will show what renaming actions would be performed without actually renaming any files.
- `--batch`: (Optional) If specified, the script will process all supported files in the specified directory.
- `--desp <description>`: (Optional) If specified, the given description will be appended to the new filenames.

## Examples

### Example 1: Dry Run for a Single File


```sh
./rename_files.fish /path/to/your/file.jpg --dry-run
```

### Example 2: Batch Process a Directory with Description

```sh
./rename_files.fish /path/to/your/files --batch --desp "Vacation2024"
```
## Script Logic

1. **Argument Parsing**:

    - The script parses the provided arguments to check for the `--dry-run`, `--batch`, and `--desp` flags.
    - It verifies the provided path and ensures it exists.
2. **File Processing**:
    
    - If `--batch` is specified, the script processes all supported files in the directory.
    - If processing a single file, the script directly processes the provided file.
3. **Metadata Extraction**:
    
    - The script uses `exiftool` to extract the creation date and time from the file metadata.
4. **Filename Construction**:
    
    - Constructs a new filename based on the extracted date, time, and optional description.
    - Ensures the new filename is unique by appending a counter if necessary.
5. **Dry Run or Rename**:
    
    - If `--dry-run` is specified, the script prints the proposed renaming actions without making any changes.
    - Otherwise, the script renames the files as per the constructed filenames.
## Troubleshooting

### Path Issues

If you encounter an error saying the path does not exist, ensure:

- You are providing the correct absolute or relative path.
- The path does not contain any special characters or spaces. If it does, enclose it in quotes.

### Exiftool Issues

If the script cannot find `exiftool`, ensure it is installed and accessible from your `PATH`.

### Dry Run and Batch Mode

- The `--dry-run` flag will simulate the renaming process without making any changes.
- The `--batch` flag is required to process all files in a directory. Without this flag, the script will assume the provided path is a single file.