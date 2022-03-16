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

	[Parameter(Mandatory = $false, HelpMessage = "The property of the file that should be used to determine the file's date. Will prefer properties at the start of the array (i.e. index 0) and use sequential index properties if the property is not found. Default is DateTaken, CreationTime, LastWriteTime.")]
	[string[]] $FileDatePropertiesToUse = @('Date taken', 'Media created', 'CreationTime', 'LastWriteTime'),

	[Parameter(Mandatory = $false, HelpMessage = 'If provided, the script will overwrite existing files instead of reporting an error the the file already exists.')]
	[switch] $Force
)

Process
{
	[System.Collections.ArrayList] $filesToMove = Get-ChildItem -Path $SourceDirectoryPath -File -Force -Recurse -Depth $SourceDirectoryDepthToSearch

	$filesToMove | ForEach-Object {
		[System.IO.FileInfo] $file = $_

		[DateTime] $fileDate = Get-FileDate -file $file -fileDatePropertiesToUse $FileDatePropertiesToUse
		[string] $dateDirectoryName = Get-FormattedDate -date $fileDate -dateScope $TargetDirectoriesDateScope
		[string] $dateDirectoryPath = Join-Path -Path $TargetDirectoryPath -ChildPath $dateDirectoryName

		Ensure-DirectoryExists -directoryPath $dateDirectoryPath

		[string] $filePath = $file.FullName
		Write-Information "Moving file '$filePath' into directory '$dateDirectoryPath'."
		Move-Item -LiteralPath $filePath -Destination $dateDirectoryPath -Force:$Force
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

	function Ensure-DirectoryExists([string] $directoryPath)
	{
		if (!(Test-Path -Path $directoryPath -PathType Container))
		{
			Write-Verbose "Creating directory '$directoryPath'."
			New-Item -Path $directoryPath -ItemType Directory -Force > $null
		}
	}
	function Get-FileDate([System.IO.FileInfo] $file, [string[]] $fileDatePropertiesToUse)
	{
		# Need to use special COM shell objects to search extended file properties.
		$directoryPath = $file.DirectoryName
		$directoryObject = $ShellObject.Namespace($directoryPath)
		$fileObject = $directoryObject.ParseName($file.Name)

		[DateTime] $fileDateToUse = $file.LastWriteTime	# Default value if no specified date properties are found.
		foreach ($fileDateProperty in $fileDatePropertiesToUse)
		{
			[int] $datePropertyIndex = Get-FilePropertyIndex -directoryObject $directoryObject -fileProperty $fileDateProperty

			[string] $dateString = $directoryObject.GetDetailsOf($fileObject, $datePropertyIndex)
			[string] $sanitizedDateString = Get-SanitizedDateString -dateString $dateString

			[DateTime] $fileDatePropertyDate = [DateTime]::MaxValue
			[bool] $datePropertyWasFound = [DateTime]::TryParse($sanitizedDateString, [ref]$fileDatePropertyDate)
			if ($datePropertyWasFound)
			{
				$fileDateToUse = $fileDatePropertyDate
				Write-Verbose "Using property '$fileDateProperty' to determine file date for file '$($file.FullName)'."
				break
			}
		}
		return $fileDateToUse
	}

	function Get-FilePropertyIndex($directoryObject, [string] $fileProperty)
	{
		$propertyIndex = 0
		do
		{
			$propertyName = $directoryObject.GetDetailsOf($directoryObject.Items, ++$propertyIndex)
		} while ($propertyName -ne $fileDateProperty)
	}

	function Get-SanitizedDateString([string] $dateString)
	{
		# Property values sometimes have unicode characters in them, so string out all characters
		# except for letters, numbers, spaces, colons, slashes, and backslashes.
		[string] $sanitizedDateString = $dateString -replace '[^a-zA-Z0-9\s:/\\]', ''
		return $sanitizedDateString
	}

	$ShellObject = New-Object -ComObject Shell.Application

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
