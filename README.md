# Project Overview

This project contains various scripts and tools for different purposes. Below is a list of the scripts and their descriptions.

Some scripts were made by guiding **ChatGPT 4o/3.5**.

## Scripts

### Timestamp to EXIF

- [timestamp_to_exif](docs/timestamp_to_exif.md): Script to add metadata (timestamp) extracted from PNG filenames and update the file's modification time.

### Manage Overlapping Files

Script to find and optionally remove overlapping files between two directories.
[Read more](docs/zsh/manage_overlapping_files.md)

### Manage Overlapping Photos

E.g., in Dropbox, between Camera Uploads and other folders containing photos with Dropbox name convention automation.

[Manage Overlapping Photos](docs/zsh/manage_overlapping_photos.md): Script to manage overlapping photo files between two folders.

### Undo Dropbox Naming Convention
- [Undo Dropbox Naming Convention](docs/fish/undo_dropbox_naming.md): Script to rename files that follow the Dropbox Camera Uploads naming convention.

This script failed in `zsh`, so `fish` was used.

This documentation provides a comprehensive guide on using the `undo_dropbox_naming.fish` script and includes an example, explanation, and source code reference. This documentation provides a comprehensive guide on using the `undo_dropbox_naming.fish` script and includes an example, explanation, and source code reference.

### update_exif.fish

The `update_exif.fish` script updates the EXIF metadata for PNG, JPG, and JPEG images. It supports both single-image processing and batch processing for directories. For detailed usage instructions, see [update_exif.fish documentation](docs/fish/update_exif.md).

### Rename Files Script

The `rename_media.fish` script is designed to rename media files (images and videos) in a specified folder or a single file based on their creation date and time metadata. It also allows appending a custom description to the filenames. For detailed documentation on using the `rename_media.fish` script, please refer to the [Rename Files Script Documentation](docs/fish/rename_files.md).

## Installation

Ensure you have the required dependencies installed. For the `rename_files.fish` script, you need `exiftool` and `fd` . 

### Install `exiftool` and `fd` 

- **For macOS**:

```bash
brew install exiftool fd
```

**For Linux**:

```sh
sudo apt-get install exiftool fd-find
```

## License

This project is licensed under the MIT License.

## Author

[biajia]
