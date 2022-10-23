[string] $thisScriptsDirectory = $PSScriptRoot
[string] $moduleFilePath = Join-Path -Path $thisScriptsDirectory -ChildPath 'MoveFilesIntoDateDirectories.psm1'
Import-Module -Name $moduleFilePath -Force

# Specify the parameters to call the cmdlet with.
[hashtable] $parameters = @{
	SourceDirectoryPath = 'C:\SourceDirectory\WithFilesToMove'
	#SourceDirectoryDepthToSearch = 2	# Default is to search all subdirectories.
	DestinationDirectoryPath = 'C:\DestinationDirectory\ToMoveFilesInto'
	DestinationDirectoriesDateScope = 'Day'	# Hour, Day, Month, or Year.
	FileDatePropertiesToCheck = @('Date taken', 'Media created', 'CreationTime', 'LastWriteTime')
	FileDateStrategy = 'Oldest'	# Oldest, Newest, or Priority
	Force = $false
}

# Run the cmdlet using the specified parameters.
Move-FilesIntoDateDirectories @parameters -Verbose -InformationAction Continue
