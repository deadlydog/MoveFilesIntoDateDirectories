# Move Files Into Date Directories

[This PowerShell script](src/MoveFilesIntoDateDirectories.ps1) will scan all files in the `SourceDirectoryPath` and then move them into directories whose name is based on the file's date.
Target directories will be created if they doesn't already exist, using a name based upon the `TargetDirectoriesDateScope`, and they will be created within the `TargetDirectoryPath`.

You can use the [Run.ps1](src/Run.ps1) script to easily provide parameters and run the cmdlet.

## Changelog

See what's changed in the application over time by viewing [the changelog](Changelog.md).

## Donate

Buy me a hot apple cider for providing this script open source and for free :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.me/deadlydogDan/2USD)
