[string] $thisScriptsDirectory = $PSScriptRoot
[string] $moduleFilePath = Join-Path -Path $thisScriptsDirectory -ChildPath 'MoveFilesIntoDateDirectories.psm1'
Import-Module -Name $moduleFilePath

# Specify the parameters to call the cmdlet with.
[hashtable] $parameters = @{
	SourceDirectoryPath = 'C:\SourceDirectory\WithFilesToMove'
	#SourceDirectoryDepthToSearch = 2	# Default is to search all subdirectories.
	TargetDirectoryPath = 'C:\TargetDirectory\ToMoveFilesInto'
	TargetDirectoriesDateScope = 'Day'	# Hour, Day, Month, or Year.
	Force = $false
}

# Run the cmdlet using the specified parameters.
Move-FilesIntoDateDirectories @parameters
