[string] $ModuleName = 'MoveFilesIntoDateDirectories'
[string] $SutModulePath = Join-Path -Path $PSScriptRoot -ChildPath "$ModuleName.psm1"
Import-Module -Name $SutModulePath -Force

# Use InModuleScope so we can call internal module functions. e.g. GetFormattedDate.
InModuleScope -ModuleName $ModuleName {
	Describe 'Move Files' {
		BeforeAll {
			[string] $SourceDirectoryPath = Join-Path -Path $TestDrive -ChildPath 'SourceFiles'
			[string] $DestinationDirectoryPath = Join-Path -Path $TestDrive -ChildPath 'SortedFiles'

			[hashtable[]] $DefaultTestFiles = @(
				@{
					SourceFilePath = Join-Path -Path $SourceDirectoryPath -ChildPath '2020-RootDirectory.txt'
					CreationTime = '2020-01-01 01:00:00'
					LastWriteTime = '2020-12-31 23:00:00'
				}
				@{
					SourceFilePath = Join-Path -Path $SourceDirectoryPath -ChildPath 'ChildDirectory\2021-OneDirectoryDeep.csv'
					CreationTime = '2021-01-01 01:00:00'
					LastWriteTime = '2021-12-31 23:00:00'
				}
				@{
					SourceFilePath = Join-Path -Path $SourceDirectoryPath -ChildPath 'Multiple\Nested\Directories\2022-ThreeDirectoriesDeep.log'
					CreationTime = '2022-01-01 01:00:00'
					LastWriteTime = '2022-12-31 23:00:00'
				}
			)

			function CreateTestFiles([hashtable[]] $testFilesToCreate)
			{
				# Create the temp files with the specified properties.
				$testFilesToCreate | ForEach-Object {
					New-Item -Path $_.SourceFilePath -ItemType File -Force > $null
					Set-ItemProperty -Path $_.SourceFilePath -Name CreationTime -Value $_.CreationTime
					Set-ItemProperty -Path $_.SourceFilePath -Name LastWriteTime -Value $_.LastWriteTime
				}
			}

			function GetFilePathsInDirectory([string] $directoryPath)
			{
				[string[]] $filePaths =
					Get-ChildItem -Path $directoryPath -Recurse -Force -File |
						Select-Object -ExpandProperty FullName
				return $filePaths
			}
		}
		BeforeEach {
			# Ensure files moved from other test runs are not present.
			Remove-Item -Path $DestinationDirectoryPath -Force -Recurse -ErrorAction SilentlyContinue
		}

		Context 'When sorting the files by year' {
			It 'Should move files into date directories by year' {
				# Arrange.
				[string] $destinationDirectoriesDateScope = 'Year'
				CreateTestFiles -testFilesToCreate $DefaultTestFiles

				# Act.
				Move-FilesIntoDateDirectories `
					-SourceDirectoryPath $SourceDirectoryPath `
					-DestinationDirectoryPath $DestinationDirectoryPath `
					-DestinationDirectoriesDateScope $destinationDirectoriesDateScope `
					-Force

				# Assert.
				[string[]] $expectedFilePaths = @(
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2020\2020-RootDirectory.txt'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2021\2021-OneDirectoryDeep.csv'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2022\2022-ThreeDirectoriesDeep.log'
				)

				[string[]] $actualFilePaths = GetFilePathsInDirectory -directoryPath $DestinationDirectoryPath

				$actualFilePaths | Should -Be $expectedFilePaths
			}
		}

		Context 'When sorting the files by month' {
			It 'Should move files into date directories by month' {
				# Arrange.
				[string] $destinationDirectoriesDateScope = 'Month'
				CreateTestFiles -testFilesToCreate $DefaultTestFiles

				# Act.
				Move-FilesIntoDateDirectories `
					-SourceDirectoryPath $SourceDirectoryPath `
					-DestinationDirectoryPath $DestinationDirectoryPath `
					-DestinationDirectoriesDateScope $destinationDirectoriesDateScope `
					-Force

				# Assert.
				[string[]] $expectedFilePaths = @(
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2020-01\2020-RootDirectory.txt'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2021-01\2021-OneDirectoryDeep.csv'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2022-01\2022-ThreeDirectoriesDeep.log'
				)

				[string[]] $actualFilePaths = GetFilePathsInDirectory -directoryPath $DestinationDirectoryPath

				$actualFilePaths | Should -Be $expectedFilePaths
			}
		}

		Context 'When sorting the files by day' {
			It 'Should move files into date directories by day' {
				# Arrange.
				[string] $destinationDirectoriesDateScope = 'Day'
				CreateTestFiles -testFilesToCreate $DefaultTestFiles

				# Act.
				Move-FilesIntoDateDirectories `
					-SourceDirectoryPath $SourceDirectoryPath `
					-DestinationDirectoryPath $DestinationDirectoryPath `
					-DestinationDirectoriesDateScope $destinationDirectoriesDateScope `
					-Force

				# Assert.
				[string[]] $expectedFilePaths = @(
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2020-01-01\2020-RootDirectory.txt'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2021-01-01\2021-OneDirectoryDeep.csv'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2022-01-01\2022-ThreeDirectoriesDeep.log'
				)

				[string[]] $actualFilePaths = GetFilePathsInDirectory -directoryPath $DestinationDirectoryPath

				$actualFilePaths | Should -Be $expectedFilePaths
			}
		}

		Context 'When sorting the files by hour' {
			It 'Should move files into date directories by hour' {
				# Arrange.
				[string] $destinationDirectoriesDateScope = 'Hour'
				CreateTestFiles -testFilesToCreate $DefaultTestFiles

				# Act.
				Move-FilesIntoDateDirectories `
					-SourceDirectoryPath $SourceDirectoryPath `
					-DestinationDirectoryPath $DestinationDirectoryPath `
					-DestinationDirectoriesDateScope $destinationDirectoriesDateScope `
					-Force

				# Assert.
				[string[]] $expectedFilePaths = @(
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2020-01-01-01\2020-RootDirectory.txt'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2021-01-01-01\2021-OneDirectoryDeep.csv'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2022-01-01-01\2022-ThreeDirectoriesDeep.log'
				)

				[string[]] $actualFilePaths = GetFilePathsInDirectory -directoryPath $DestinationDirectoryPath

				$actualFilePaths | Should -Be $expectedFilePaths
			}
		}

		Context 'When a maximum source directory depth search is specified' {
			It 'Should only move files from the source directory up to the maximum depth' {
				# Arrange.
				[int] $maxDirectoryDepth = 1
				[string] $destinationDirectoriesDateScope = 'Year'
				CreateTestFiles -testFilesToCreate $DefaultTestFiles

				# Act.
				Move-FilesIntoDateDirectories `
					-SourceDirectoryPath $SourceDirectoryPath `
					-DestinationDirectoryPath $DestinationDirectoryPath `
					-DestinationDirectoriesDateScope $destinationDirectoriesDateScope `
					-SourceDirectoryDepthToSearch $maxDirectoryDepth `
					-Force

				# Assert.
				[string[]] $expectedFilePaths = @(
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2020\2020-RootDirectory.txt'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2021\2021-OneDirectoryDeep.csv'
				)

				[string[]] $actualFilePaths = GetFilePathsInDirectory -directoryPath $DestinationDirectoryPath

				$actualFilePaths | Should -Be $expectedFilePaths
			}
		}

		Context 'When specifying to use the oldest date' {
			It 'Should move files into date directories with the oldest date' {
				# Arrange.
				[string] $fileDateStrategy = 'Oldest'
				[string] $destinationDirectoriesDateScope = 'Month'

				[hashtable[]] $testFiles = @(
					@{
						SourceFilePath = Join-Path -Path $SourceDirectoryPath -ChildPath '2020-RootDirectory.txt'
						CreationTime = '2020-12-31 23:00:00'
						LastWriteTime = '2020-01-01 01:00:00'
					}
					@{
						SourceFilePath = Join-Path -Path $SourceDirectoryPath -ChildPath 'ChildDirectory\2021-OneDirectoryDeep.csv'
						CreationTime = '2021-01-01 01:00:00'
						LastWriteTime = '2021-12-31 23:00:00'
					}
				)
				CreateTestFiles -testFilesToCreate $testFiles

				[string[]] $expectedFilePaths = @(
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2020-01\2020-RootDirectory.txt'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2021-01\2021-OneDirectoryDeep.csv'
				)

				# Act.
				Move-FilesIntoDateDirectories `
					-SourceDirectoryPath $SourceDirectoryPath `
					-DestinationDirectoryPath $DestinationDirectoryPath `
					-DestinationDirectoriesDateScope $destinationDirectoriesDateScope `
					-FileDateStrategy $fileDateStrategy `
					-Force

				# Assert.
				[string[]] $actualFilePaths = GetFilePathsInDirectory -directoryPath $DestinationDirectoryPath

				$actualFilePaths | Should -Be $expectedFilePaths
			}
		}

		Context 'When specifying to use the newest date' {
			It 'Should move files into date directories with the newest date' {
				# Arrange.
				[string] $fileDateStrategy = 'Newest'
				[string] $destinationDirectoriesDateScope = 'Month'

				[hashtable[]] $testFiles = @(
					@{
						SourceFilePath = Join-Path -Path $SourceDirectoryPath -ChildPath '2020-RootDirectory.txt'
						CreationTime = '2020-12-31 23:00:00'
						LastWriteTime = '2020-01-01 01:00:00'
					}
					@{
						SourceFilePath = Join-Path -Path $SourceDirectoryPath -ChildPath 'ChildDirectory\2021-OneDirectoryDeep.csv'
						CreationTime = '2021-01-01 01:00:00'
						LastWriteTime = '2021-12-31 23:00:00'
					}
				)
				CreateTestFiles -testFilesToCreate $testFiles

				[string[]] $expectedFilePaths = @(
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2020-12\2020-RootDirectory.txt'
					Join-Path -Path $DestinationDirectoryPath -ChildPath '2021-12\2021-OneDirectoryDeep.csv'
				)

				# Act.
				Move-FilesIntoDateDirectories `
					-SourceDirectoryPath $SourceDirectoryPath `
					-DestinationDirectoryPath $DestinationDirectoryPath `
					-DestinationDirectoriesDateScope $destinationDirectoriesDateScope `
					-FileDateStrategy $fileDateStrategy `
					-Force

				# Assert.
				[string[]] $actualFilePaths = GetFilePathsInDirectory -directoryPath $DestinationDirectoryPath

				$actualFilePaths | Should -Be $expectedFilePaths
			}
		}
	}
}
