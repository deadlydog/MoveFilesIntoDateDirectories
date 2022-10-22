#Requires -Version 5.0

function Move-FilesIntoDateDirectories
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory = $true, HelpMessage = 'The directory to look for files to move in.')]
		[ValidateNotNullOrEmpty()]
		[System.IO.DirectoryInfo] $SourceDirectoryPath,

		[Parameter(Mandatory = $false, HelpMessage = 'How many subdirectories deep the script should search for files to move. Default is no limit.')]
		[ValidateRange(0, [int]::MaxValue)]
		[int] $SourceDirectoryDepthToSearch = [int]::MaxValue,

		[Parameter(Mandatory = $true, HelpMessage = 'The directory to create the date-named directories in and move the files to.')]
		[ValidateNotNullOrEmpty()]
		[System.IO.DirectoryInfo] $TargetDirectoryPath,

		[Parameter(Mandatory = $false, HelpMessage = 'The scope at which directories should be created. Accepted values include "Hour", "Day", "Month", or "Year". e.g. If you specify "Day" files will be moved from the `SourceDirectoryPath` to `TargetDirectoryPath\yyyy-MM-dd`.')]
		[ValidateSet('Hour', 'Day', 'Month', 'Year')]
		[string] $TargetDirectoriesDateScope = 'Day',

		[Parameter(Mandatory = $false, HelpMessage = 'If provided, the script will overwrite existing files instead of reporting an error the the file already exists.')]
		[switch] $Force
	)

	Process
	{
		[bool] $sourceDirectoryExists = Test-Path -Path $SourceDirectoryPath -PathType Container
		if (-not $sourceDirectoryExists)
		{
			Write-Warning -Message "The source directory path '$SourceDirectoryPath' does not exist, so there are no files to move."
			return
		}

		[System.Collections.ArrayList] $filesToMove = Get-ChildItem -Path $SourceDirectoryPath -File -Force -Recurse -Depth $SourceDirectoryDepthToSearch

		$filesToMove | Where-Object { $null -ne $_ } | ForEach-Object {
			[System.IO.FileInfo] $file = $_

			[DateTime] $fileDate = $file.LastWriteTime
			[string] $dateDirectoryName = GetFormattedDate -date $fileDate -dateScope $TargetDirectoriesDateScope
			[string] $dateDirectoryPath = Join-Path -Path $TargetDirectoryPath -ChildPath $dateDirectoryName

			EnsureDirectoryExists -directoryPath $dateDirectoryPath

			[string] $filePath = $file.FullName
			Write-Information "Moving file '$filePath' into directory '$dateDirectoryPath'."
			Move-Item -LiteralPath $filePath -Destination $dateDirectoryPath -Force:$Force
		}
	}
}

function GetFormattedDate([DateTime] $date, [string] $dateScope)
{
	[string] $formattedDate = [string]::Empty
	switch ($dateScope)
	{
		'Hour' { $formattedDate = $date.ToString('yyyy-MM-dd-HH') }
		'Day' { $formattedDate = $date.ToString('yyyy-MM-dd') }
		'Month' { $formattedDate = $date.ToString('yyyy-MM') }
		'Year' { $formattedDate = $date.ToString('yyyy') }
		Default { throw "The specified date scope '$dateScope' is not valid. Please provide a valid scope." }
	}
	return $formattedDate
}

function EnsureDirectoryExists([string] $directoryPath)
{
	if (!(Test-Path -Path $directoryPath -PathType Container))
	{
		Write-Verbose "Creating directory '$directoryPath'."
		New-Item -Path $directoryPath -ItemType Directory -Force > $null
	}
}

Export-ModuleMember -Function Move-FilesIntoDateDirectories
