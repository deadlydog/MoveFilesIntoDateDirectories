[string] $thisScriptsDirectory = $PSScriptRoot
[string] $scriptFilePath = Join-Path -Path $thisScriptsDirectory -ChildPath 'MoveFilesIntoDateDirectories.ps1'

# Specify the parameters to call the cmdlet with.
[hashtable] $scriptParameters = @{
	SourceDirectoryPath = 'C:\dev\Git\MoveFilesIntoDateDirectories\SourceDirectory'
	# SourceDirectoryDepthToSearch = 2
	TargetDirectoryPath = 'C:\dev\Git\MoveFilesIntoDateDirectories\TargetDirectory'
	# TargetDirectoriesDateScope = 'Year'	# Hour, Day, Month, or Year
	Force = $false
}

# Run the cmdlet using the specified parameters.
& $scriptFilePath @scriptParameters
