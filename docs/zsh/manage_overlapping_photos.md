# Manage Overlapping Photos

This script helps identify and manage overlapping photo files between two folders based on their date-time patterns. It can optionally remove the overlapping files from the specified folder.

## Usage

```sh
./manage_overlapping_photos.zsh <small_folder> <big_folder> [--remove]
```
- `small_folder`: Path to the folder containing the smaller set of photos.
- `big_folder`: Path to the folder containing the larger set of photos.
- `--remove`: (Optional) If provided, the overlapping files in the `big_folder` will be removed.
## Examples

### List Overlapping Files

To list overlapping files without removing them:
```sh
./manage_overlapping_photos.zsh /path/to/small_folder /path/to/big_folder
```
This will generate the list of overlapping files in `~/Downloads/overlapping_files.txt`.
### Remove Overlapping Files

To remove the overlapping files in the `big_folder`:
```sh
./manage_overlapping_photos.zsh /path/to/small_folder /path/to/big_folder --remove
```
This will remove the overlapping files and log the removed files.

## Explanation

- **Generate file lists**:
    
    - The `fd` command lists all files in the `small_folder` and `big_folder`.
- **Extract date-time parts**:
    
    - For files in the `small_folder`, extract the date and time up to minutes.
    - For files in the `big_folder`, extract the date and time up to minutes.
- **Find overlapping date-time parts**:
    
    - Compare the extracted date-time parts from both folders.
- **Match full paths of overlapping files**:
    
    - Use `grep` to find filenames that include the overlapping date-time patterns.
- **Conditionally remove the overlapping files**:
    
    - If the `--remove` flag is provided, remove the overlapping files from the `big_folder`.

## Dependencies

- `fd`: A simple, fast and user-friendly alternative to `find`.
- `awk`: A versatile programming language for working on files.
- `grep`: A command-line utility for searching plain-text data sets.