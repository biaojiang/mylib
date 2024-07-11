# Undo Dropbox Naming Convention

This script renames files in a specified folder that follow the Dropbox Camera Uploads naming convention `yyyy-mm-dd - filename` to just `filename`.

## Script: `undo_dropbox_naming.fish`

### Usage

```sh
./undo_dropbox_naming.fish <folder_path> [--dry-run]
```

- `<folder_path>`: The path to the folder containing the files to be renamed.
- `[--dry-run]`: Optional argument. If specified, the script will perform a dry run, showing what files would be renamed without actually performing the renaming.

### Example

To rename files in the folder `/path/to/your/folder`:
```sh
./undo_dropbox_naming.fish /path/to/your/folder
```

To perform a dry run:
```sh
./undo_dropbox_naming.fish /path/to/your/folder --dry-run
```

### Explanation

- **Argument Check**: Ensures the user provides the correct number of arguments and checks for the `--dry-run` option.
- **Directory Check**: Verifies that the provided argument is a valid directory.
- **Dry Run**: If `--dry-run` is specified, the script will print what would be done without actually renaming any files.
- **Loop and Rename**: Iterates over the files in the folder, checks if they match the pattern using `grep`, extracts the filename after the `-` using `sed`, and either renames the file or prints what would be done, depending on the dry run mode.