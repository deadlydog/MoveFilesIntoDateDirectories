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

	[Parameter(Mandatory = $false, HelpMessage = "The properties of the file that should be used to determine the file's date. If a property does not exist on the file, it will be ignored. Default value is @('Date taken', 'LastWriteTime', 'CreationTime').")]
	[string[]] $FileDatePropertiesToCheck = @('Date taken', 'LastWriteTime', 'CreationTime'),

	[Parameter(Mandatory = $false, HelpMessage = "When there are multiple FileDataPropertiesToCheck, this strategy determines which date should be used. Valid values are 'Oldest', 'Newest', and 'Priority'. Default value is 'Oldest', which will use the earliest date value. 'Newest' will use the latest date value. 'Priority' will use the first date value from the FileDatePropertiesToCheck array that is found in the file's properties. For example, if FileDatePropertiesToCheck = @('Date taken', 'LastWriteTime', 'CreationTime'), then 'Date taken' will be used, unless it does not exist, in which case LastWriteTime will be used.")]
	[ValidateSet('Oldest', 'Newest', 'Priority')]
	[ValidateNotNullOrEmpty()]
	[string] $FileDateStrategy = 'Oldest',

	[Parameter(Mandatory = $false, HelpMessage = 'If provided, the script will overwrite existing files instead of reporting an error the the file already exists.')]
	[switch] $Force
)

Process
{
	[System.Collections.ArrayList] $filesToMove = Get-ChildItem -Path $SourceDirectoryPath -File -Force -Recurse -Depth $SourceDirectoryDepthToSearch

	$filesToMove | ForEach-Object {
		[System.IO.FileInfo] $file = $_

		[DateTime] $fileDate = Get-FileDate -file $file -fileDatePropertiesToCheck $FileDatePropertiesToCheck -fileDateStrategy $FileDateStrategy
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

	function Get-FileDate([System.IO.FileInfo] $file, [string[]] $fileDatePropertiesToCheck, [string] $fileDateStrategy)
	{
		# Need to use special COM shell objects to search extended file properties.
		$directoryPath = $file.DirectoryName
		[__COMObject] $directoryObject = $ShellObject.Namespace($directoryPath)
		[__COMObject] $fileObject = $directoryObject.ParseName($file.Name)

		[hashtable] $fileDate = $null
		foreach ($fileDatePropertyName in $fileDatePropertiesToCheck)
		{
			switch ($fileDatePropertyName)
			{
				# First class file properties.
				'CreationTime' { $fileDatePropertyValue = $file.CreationTime; break }
				'LastWriteTime' { $fileDatePropertyValue = $file.LastWriteTime; break }

				# Search through the extended optional file properties for the one specified.
				Default
				{
					$fileDatePropertyValue = Get-FileDatePropertyValue `
						-fileDatePropertyName $fileDatePropertyName `
						-directoryObject $directoryObject `
						-fileObject $fileObject
				}
			}

			[bool] $fileDatePropertyValueWasRetrieved = ![string]::IsNullOrWhiteSpace($fileDatePropertyValue)
			if ($fileDatePropertyValueWasRetrieved)
			{
				switch ($fileDateStrategy)
				{
					'Oldest'
					{
						if ($null -eq $fileDate -or $fileDatePropertyValue -lt $fileDate.Date)
						{
							$fileDate = @{ PropertyName = $fileDatePropertyName; Date = $fileDatePropertyValue }
						}
					}

					'Newest'
					{
						if ($null -eq $fileDate -or $fileDatePropertyValue -gt $fileDate.Date)
						{
							$fileDate = @{ PropertyName = $fileDatePropertyName; Date = $fileDatePropertyValue }
						}
					}

					'Priority'
					{
						$fileDate = @{ PropertyName = $fileDatePropertyName; Date = $fileDatePropertyValue }
					}

					Default
					{
						throw "The specified file date strategy '$fileDateStrategy' is not valid. Please provide a valid strategy."
					}
				}

				# If the strategy is 'Priority', then we can stop looking as we found the property value to use.
				if ($fileDateStrategy -eq 'Priority')
				{
					break
				}
			}
		}

		[DateTime] $fileDateToUse
		if ($null -eq $fileDate)
		{
			$fileDateToUse = $file.LastWriteTime
			Write-Verbose "Could not find any of the specified file date properties, so using the LastWriteTime for the file date of file '$($file.FullName)'."
		}
		else
		{
			$fileDateToUse = $fileDate.Date
			Write-Verbose "Using property '$($fileDate.PropertyName)' for the file date of file '$($file.FullName)'."
		}

		# Free up memory before leaving.
		$directoryObject = $null
		$fileObject = $null

		return $fileDateToUse
	}

	function Get-FileDatePropertyValue([string] $fileDatePropertyName, [__COMObject] $directoryObject, [__COMObject] $fileObject)
	{
		[int] $datePropertyIndex = Get-FilePropertyIndex -filePropertyName $fileDatePropertyName -directoryObject $directoryObject

		if ($datePropertyIndex -lt 0)
		{
			return $null
		}

		[string] $dateString = $directoryObject.GetDetailsOf($fileObject, $datePropertyIndex)
		[string] $sanitizedDateString = Get-SanitizedDateString -dateString $dateString

		[DateTime] $fileDatePropertyDate = [DateTime]::MaxValue
		if ([DateTime]::TryParse($sanitizedDateString, [ref]$fileDatePropertyDate))
		{
			return $fileDatePropertyDate
		}
		return $null
	}

	function Get-FilePropertyIndex([string] $filePropertyName, [__COMObject] $directoryObject)
	{
		$propertyIndex = 0
		do
		{
			$propertyName = $directoryObject.GetDetailsOf($directoryObject.Items, ++$propertyIndex)

			# If we searched through all of the file properties and haven't found the one specified, return invalid index.
			if ([string]::IsNullOrWhiteSpace($propertyName))
			{
				return -1
			}

		} while ($propertyName -ne $filePropertyName)

		return $propertyIndex
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
