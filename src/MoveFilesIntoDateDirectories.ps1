#Requires -Version 5.0
# This script will inspect files from the provided source directory, and move them into a directory based on their LastWriteTime.

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
	Get-ChildItem -Path $SourceDirectoryPath -File -Force -Recurse -Depth $SourceDirectoryDepthToSearch |
		ForEach-Object {
			[System.IO.FileInfo] $file = $_

			[DateTime] $fileDate = $file.LastWriteTime
			[string] $dateDirectoryName = Get-FormattedDate -date $fileDate -dateScope $TargetDirectoriesDateScope
			[string] $dateDirectoryPath = Join-Path -Path $TargetDirectoryPath -ChildPath $dateDirectoryName

			if (!(Test-Path -Path $dateDirectoryPath -PathType Container))
			{
				Write-Verbose "Creating directory '$dateDirectoryPath'."
				New-Item -Path $dateDirectoryPath -ItemType Directory -Force > $null
			}

			[string] $filePath = $file.FullName
			Write-Information "Moving file '$filePath' into directory '$dateDirectoryPath'."
			Move-Item -Path $filePath -Destination $dateDirectoryPath -Force:$Force
		}
}

Begin
{
	$InformationPreference = "Continue"
	$VerbosePreference = "Continue"

	function Get-FormattedDate([DateTime] $date, [string] $dateScope)
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

	# Display the time that this script started running.
	[datetime] $startTime = Get-Date
	Write-Verbose "Starting script at '$startTime'." -Verbose
}

End
{
	# Display the time that this script finished running, and how long it took to run.
	[datetime] $finishTime = Get-Date
	[timespan] $elapsedTime = $finishTime - $startTime
	Write-Verbose "Finished script at '$finishTime'. Took '$elapsedTime' to run." -Verbose
}
