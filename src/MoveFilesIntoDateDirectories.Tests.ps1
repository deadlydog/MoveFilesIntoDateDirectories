BeforeAll {
	[string] $sutModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'MoveFilesIntoDateDirectories.psm1'
	Import-Module -Name $sutModulePath -Force

	# This function is copy-pasted from the module, since it is a private method that we cannot call directly.
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
}

Describe 'Move Files' {
	BeforeEach {
		[string] $SourceDirectoryPath = Join-Path -Path $TestDrive -ChildPath 'SourceFiles'
		[string] $TargetDirectoryPath = Join-Path -Path $TestDrive -ChildPath 'SortedFiles'

		[hashtable[]] $TestFilesToCreate = @(
			@{
				SourceFilePath = Join-Path -Path $SourceDirectoryPath -ChildPath '2020.txt'
				CreationTime = '2020-01-01 01:00:00'
				LastWriteTime = '2020-12-31 23:00:00'
			}
			@{
				SourceFilePath = Join-Path -Path $sourceDirectoryPath -ChildPath 'ChildDirectory\2021.csv'
				CreationTime = '2021-01-01 01:00:00'
				LastWriteTime = '2021-12-31 23:00:00'
			}
			@{
				SourceFilePath = Join-Path -Path $SourceDirectoryPath -ChildPath 'Multiple\Nested\Directories\2022.log'
				CreationTime = '2022-01-01 01:00:00'
				LastWriteTime = '2022-12-31 23:00:00'
			}
		)

		# Create the temp files with the specified properties.
		$TestFilesToCreate | ForEach-Object {
			New-Item -Path $_.SourceFilePath -ItemType File -Force > $null
			Set-ItemProperty -Path $_.SourceFilePath -Name CreationTime -Value $_.CreationTime
			Set-ItemProperty -Path $_.SourceFilePath -Name LastWriteTime -Value $_.LastWriteTime
		}

		# Ensure files moved from other test runs are not present.
		Remove-Item -Path $TargetDirectoryPath -Force -Recurse -ErrorAction SilentlyContinue
	}

	Context 'When sorting the files by year' {
		It 'Should move files into date directories by year' {
			# Arrange.
			[string] $targetDirectoriesDateScope = 'Year'

			# Act.
			Move-FilesIntoDateDirectories `
				-SourceDirectoryPath $SourceDirectoryPath `
				-TargetDirectoryPath $TargetDirectoryPath `
				-TargetDirectoriesDateScope $targetDirectoriesDateScope `
				-Force

			# Assert.
			[string[]] $expectedFilePaths = @()
			$TestFilesToCreate | ForEach-Object {
				[string] $fileName = Split-Path -Path $_.SourceFilePath -Leaf
				[DateTime] $lastWriteTime = [DateTime]::Parse($_.LastWriteTime)
				[string] $expectedDirectoryName =
					GetFormattedDate -date $lastWriteTime -dateScope $targetDirectoriesDateScope
				[string] $expectedFilePath =
					Join-Path -Path $TargetDirectoryPath -ChildPath "$expectedDirectoryName\$fileName"

				$expectedFilePaths += $expectedFilePath
			}

			[string[]] $actualFilePaths =
				Get-ChildItem -Path $TargetDirectoryPath -Recurse -File |
					Select-Object -ExpandProperty FullName

			$actualFilePaths | Should -Be $expectedFilePaths
		}
	}

	Context 'When sorting the files by month' {
		It 'Should move files into date directories by month' {
			# Arrange.
			[string] $targetDirectoriesDateScope = 'Month'

			# Act.
			Move-FilesIntoDateDirectories `
				-SourceDirectoryPath $SourceDirectoryPath `
				-TargetDirectoryPath $TargetDirectoryPath `
				-TargetDirectoriesDateScope $targetDirectoriesDateScope `
				-Force

			# Assert.
			[string[]] $expectedFilePaths = @()
			$TestFilesToCreate | ForEach-Object {
				[string] $fileName = Split-Path -Path $_.SourceFilePath -Leaf
				[DateTime] $lastWriteTime = [DateTime]::Parse($_.LastWriteTime)
				[string] $expectedDirectoryName =
					GetFormattedDate -date $lastWriteTime -dateScope $targetDirectoriesDateScope
				[string] $expectedFilePath =
					Join-Path -Path $TargetDirectoryPath -ChildPath "$expectedDirectoryName\$fileName"

				$expectedFilePaths += $expectedFilePath
			}

			[string[]] $actualFilePaths =
				Get-ChildItem -Path $TargetDirectoryPath -Recurse -File |
					Select-Object -ExpandProperty FullName

			$actualFilePaths | Should -Be $expectedFilePaths
		}
	}

	Context 'When sorting the files by day' {
		It 'Should move files into date directories by day' {
			# Arrange.
			[string] $targetDirectoriesDateScope = 'Day'

			# Act.
			Move-FilesIntoDateDirectories `
				-SourceDirectoryPath $SourceDirectoryPath `
				-TargetDirectoryPath $TargetDirectoryPath `
				-TargetDirectoriesDateScope $targetDirectoriesDateScope `
				-Force

			# Assert.
			[string[]] $expectedFilePaths = @()
			$TestFilesToCreate | ForEach-Object {
				[string] $fileName = Split-Path -Path $_.SourceFilePath -Leaf
				[DateTime] $lastWriteTime = [DateTime]::Parse($_.LastWriteTime)
				[string] $expectedDirectoryName =
				GetFormattedDate -date $lastWriteTime -dateScope $targetDirectoriesDateScope
				[string] $expectedFilePath =
				Join-Path -Path $TargetDirectoryPath -ChildPath "$expectedDirectoryName\$fileName"

				$expectedFilePaths += $expectedFilePath
			}

			[string[]] $actualFilePaths =
			Get-ChildItem -Path $TargetDirectoryPath -Recurse -File |
				Select-Object -ExpandProperty FullName

			$actualFilePaths | Should -Be $expectedFilePaths
		}
	}

	Context 'When sorting the files by hour' {
		It 'Should move files into date directories by hour' {
			# Arrange.
			[string] $targetDirectoriesDateScope = 'Hour'

			# Act.
			Move-FilesIntoDateDirectories `
				-SourceDirectoryPath $SourceDirectoryPath `
				-TargetDirectoryPath $TargetDirectoryPath `
				-TargetDirectoriesDateScope $targetDirectoriesDateScope `
				-Force

			# Assert.
			[string[]] $expectedFilePaths = @()
			$TestFilesToCreate | ForEach-Object {
				[string] $fileName = Split-Path -Path $_.SourceFilePath -Leaf
				[DateTime] $lastWriteTime = [DateTime]::Parse($_.LastWriteTime)
				[string] $expectedDirectoryName =
				GetFormattedDate -date $lastWriteTime -dateScope $targetDirectoriesDateScope
				[string] $expectedFilePath =
				Join-Path -Path $TargetDirectoryPath -ChildPath "$expectedDirectoryName\$fileName"

				$expectedFilePaths += $expectedFilePath
			}

			[string[]] $actualFilePaths =
			Get-ChildItem -Path $TargetDirectoryPath -Recurse -File |
				Select-Object -ExpandProperty FullName

			$actualFilePaths | Should -Be $expectedFilePaths
		}
	}

	Context 'When a maximum source directory depth search is specified' {
		It 'Should only move files from the source directory up to the maximum depth' {
			# Arrange.
			[int] $maxDirectoryDepth = 1
			[string] $targetDirectoriesDateScope = 'Year'

			# Act.
			Move-FilesIntoDateDirectories `
				-SourceDirectoryPath $SourceDirectoryPath `
				-TargetDirectoryPath $TargetDirectoryPath `
				-TargetDirectoriesDateScope $targetDirectoriesDateScope `
				-SourceDirectoryDepthToSearch $maxDirectoryDepth `
				-Force

			# Assert.
			[string[]] $expectedFilePaths = @()
			$TestFilesToCreate |
				Where-Object {
					[string] $relativeDirectoryPath = $_.SourceFilePath.Replace($SourceDirectoryPath, '').TrimStart('\')
					[string[]] $directories = $relativeDirectoryPath.Split('\')
					[int] $numberOfChildDirectories = $directories.Length - 1

					return $numberOfChildDirectories -le $maxDirectoryDepth
				} |
				ForEach-Object {
					[string] $fileName = Split-Path -Path $_.SourceFilePath -Leaf
					[DateTime] $lastWriteTime = [DateTime]::Parse($_.LastWriteTime)
					[string] $expectedDirectoryName =
					GetFormattedDate -date $lastWriteTime -dateScope $targetDirectoriesDateScope
					[string] $expectedFilePath =
					Join-Path -Path $TargetDirectoryPath -ChildPath "$expectedDirectoryName\$fileName"

					$expectedFilePaths += $expectedFilePath
				}

			[string[]] $actualFilePaths =
			Get-ChildItem -Path $TargetDirectoryPath -Recurse -File |
				Select-Object -ExpandProperty FullName

			$actualFilePaths | Should -Be $expectedFilePaths
		}
	}
}
