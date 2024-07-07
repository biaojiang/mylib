# PNG Metadata and Timestamp Updater

This script processes PNG files to add metadata (timestamp) extracted from the filename and update the file's modification time. It supports batch processing of all PNG files in a specified folder or processing a single PNG file.

## Features

- Extracts timestamp from PNG filenames.
- Updates EXIF metadata with the extracted timestamp.
- Updates the file modification time to include the correct timezone offset.
- Supports both single file and batch processing.

## Filename Patterns Supported

The script supports the following filename patterns to extract timestamps:

1. `screenshot_YYYY-MM-DD-HH-MM-SSpng_XXXXXXXXXXX.png`
2. `Screenshot YYYY-MM-DD at HH.MM.SS.png`

## Requirements

- Python 3.x
- `Pillow` library
- `piexif` library
- `pytz` library

Install the required libraries using pip:

```bash
pip install pillow piexif pytz
```

## Usages
Command-Line Arguments
* `path`: Path to a folder or a single PNG file.
* `--timezone`: Timezone to use for file modification time (default: Europe/Stockholm).
* `--batch`: Process all PNG files in the folder.
* `--batch False`: Process a single PNG file.
