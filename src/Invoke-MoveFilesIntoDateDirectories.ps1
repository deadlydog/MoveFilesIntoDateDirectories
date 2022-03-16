[string] $thisScriptsDirectory = $PSScriptRoot
[string] $moduleFilePath = Join-Path -Path $thisScriptsDirectory -ChildPath 'MoveFilesIntoDateDirectories.psm1'
Import-Module -Name $moduleFilePath -Force

# Specify the parameters to call the cmdlet with.
[hashtable] $parameters = @{
	SourceDirectoryPath = 'C:\SourceDirectory\WithFilesToMove'
	#SourceDirectoryDepthToSearch = 2	# Default is to search all subdirectories.
	TargetDirectoryPath = 'C:\TargetDirectory\ToMoveFilesInto'
	TargetDirectoriesDateScope = 'Day'	# Hour, Day, Month, or Year.
	FileDatePropertiesToUse = @('Date taken', 'Media created', 'CreationTime', 'LastWriteTime')
	Force = $false
}

# Run the cmdlet using the specified parameters.
Move-FilesIntoDateDirectories @parameters -Verbose -InformationAction Continue
