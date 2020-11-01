# Move Files Into Date Directories

[This PowerShell script](src/MoveFilesIntoDateDirectories.ps1) will scan all files in the `SourceDirectoryPath` and then move them into directories whose name is based on the file's LastWriteTime date.
Target directories will be created if they don't already exist, using a name based upon the specified `TargetDirectoriesDateScope`, and they will be created within the `TargetDirectoryPath`.
It is acceptable for the `SourceDirectoryPath` and `TargetDirectoryPath` to be the same directory path.

A common use-case of this script is to move photos into date-named directories based on when the photo was taken.

You can use the [Run.ps1](src/Run.ps1) script to easily provide parameters and run the cmdlet.

## Example

Some various files that were last updated on different dates:

![Source directory screenshot](docs/Images/SourceDirectoryScreenshot.png)

The target directory containing the same files after the script ran and moved them into month date-named directories based on their LastWriteTime:

![Target directory screenshot](docs/Images/TargetDirectoryScreenshot.png)

## Changelog

See what's changed in the application over time by viewing [the changelog](Changelog.md).

## Donate

Buy me a hot apple cider for providing this script open source and for free :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.me/deadlydogDan/2USD)
