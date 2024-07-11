# Manage Overlapping Files Script

This script, `manage_overlapping_files.zsh`, is designed to find and optionally remove overlapping files between two directories. This can be particularly useful for cleaning up duplicate files between different folders.

## Usage

### Command-Line Arguments

- **small_folder**: Path to the smaller directory.
- **big_folder**: Path to the larger directory.
- **--remove**: Optional flag to remove the overlapping files from the small folder.

### Example

To list overlapping files without removing them:
```sh
./manage_overlapping_files.zsh /path/to/small_folder /path/to/big_folder
```

To remove the overlapping files from the small folder:
```sh
./manage_overlapping_files.zsh /path/to/small_folder /path/to/big_folder --remove
```

## Description

1. Argument Check: Ensures that at least two arguments are provided.
2. Define Directories: Assign the input arguments to small_folder and big_folder.
3. Remove Flag: Checks if the --remove flag is provided.
4. File Paths: Sets the paths for output files.
5. Generate File Lists: Uses fd to list all files in each folder recursively, saving the results.
6. Sort File Lists: Sort the lists of files in place using sort.
7. Find Overlapping Files: Uses comm -12 to find and save overlapping files.
8. Conditional File Removal: If --remove is provided, remove the overlapping files from the small folder.

> Notes
* The script uses `fd` for finding files and `comm` for finding common files between the two directories.
* Ensure you have the necessary permissions to remove files from the specified directories if using the `--remove` flag.
