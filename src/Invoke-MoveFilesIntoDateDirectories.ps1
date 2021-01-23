[string] $thisScriptsDirectory = $PSScriptRoot
[string] $scriptFilePath = Join-Path -Path $thisScriptsDirectory -ChildPath 'MoveFilesIntoDateDirectories.ps1'

# Specify the parameters to call the cmdlet with.
[hashtable] $scriptParameters = @{
	SourceDirectoryPath = 'C:\Dans\Imported Photos\NotByDateYet'
	#SourceDirectoryDepthToSearch = 2
	TargetDirectoryPath = 'C:\Dans\Imported Photos'
	TargetDirectoriesDateScope = 'Day'	# Hour, Day, Month, or Year
	Force = $false
}

# Run the cmdlet using the specified parameters.
& $scriptFilePath @scriptParameters
