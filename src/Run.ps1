[string] $thisScriptsDirectory = $PSScriptRoot
[string] $scriptFilePath = Join-Path -Path $thisScriptsDirectory -ChildPath 'MoveFilesIntoDateDirectories.ps1'

& $scriptFilePath `
	-SourceDirectoryPath 'C:\dev\Git\MoveFilesIntoDateDirectories\FilesToSearch' `
	-TargetDirectoryPath 'C:\dev\Git\MoveFilesIntoDateDirectories\SortedFiles'
