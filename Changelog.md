# Changelog

## vNext

Features:

- Allow specifying the file properties that should be used to determine the date to use for the destination directory name.
  Default is 'Date taken', 'Media created', 'LastWriteTime', and 'CreationTime'.
- Allow specifying which date strategy should be used for the destination directory name; oldest (default), newest, or priority (order the properties are specified in).
- Converted script into a module.
- Write warning if the source directory to move the files from does not exist.

Fixes:

- Do not try to process null files, which would result in an error.

Breaking Changes:

- Changed default behaviour to use the oldest date out of 'Date taken', 'Media created', 'LastWriteTime', and 'CreationTime', rather than just using the LastWriteTime.
- Changed `Target` parameters to `Destination` to be more consistent with PowerShell terminology.

## v1.1.0 - October 19, 2022

Features:

- Add support for more special characters in filenames, such as brackets, to address [issue #2](https://github.com/deadlydog/MoveFilesIntoDateDirectories/issues/2).
- Update Invoke script values to be more descriptive and self-explanatory.

## v1.0.0 - November 1, 2020

Initial script.
