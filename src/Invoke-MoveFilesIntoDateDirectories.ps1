[string] $thisScriptsDirectory = $PSScriptRoot
[string] $scriptFilePath = Join-Path -Path $thisScriptsDirectory -ChildPath 'MoveFilesIntoDateDirectories.ps1'

# Specify the parameters to call the cmdlet with.
[hashtable] $scriptParameters = @{
	SourceDirectoryPath = 'C:\SourceDirectory\WithFilesToMove'
	#SourceDirectoryDepthToSearch = 2	# Default is to search all subdirectories.
	TargetDirectoryPath = 'C:\TargetDirectory\ToMoveFilesInto'
	TargetDirectoriesDateScope = 'Day'	# Hour, Day, Month, or Year
	Force = $false
}

# Run the cmdlet using the specified parameters.
& $scriptFilePath @scriptParameters
