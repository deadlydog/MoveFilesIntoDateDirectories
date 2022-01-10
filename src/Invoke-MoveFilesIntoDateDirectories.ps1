$sourcePath = Read-Host 'What is your source path?'
$targetPath = Read-Host 'What is your target path?'

[string] $thisScriptsDirectory = $PSScriptRoot
[string] $scriptFilePath = Join-Path -Path $thisScriptsDirectory -ChildPath 'MoveFilesIntoDateDirectories.ps1'

# Specify the parameters to call the cmdlet with.
[hashtable] $scriptParameters = @{
	SourceDirectoryPath = $sourcePath
	#SourceDirectoryDepthToSearch = 2
	TargetDirectoryPath = $targetPath
	TargetDirectoriesDateScope = 'Day'	# Hour, Day, Month, or Year
	Force = $false
}

# Run the cmdlet using the specified parameters.
& $scriptFilePath @scriptParameters
