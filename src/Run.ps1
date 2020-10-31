[string] $thisScriptsDirectory = $PSScriptRoot
[string] $scriptFilePath = Join-Path -Path $thisScriptsDirectory -ChildPath 'MoveFilesIntoDateDirectories.ps1'

& $scriptFilePath `
	-SourceDirectoryPath 'C:\dev\Git\MoveFilesIntoDateDirectories\SourceDirectory' `
	-TargetDirectoryPath 'C:\dev\Git\MoveFilesIntoDateDirectories\TargetDirectory'
	# -SourceDirectoryDepthToSearch 2 `
	# -TargetDirectoriesDateScope "Month" `
	# -Force
