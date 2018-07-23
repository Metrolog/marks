<#
.Synopsis
    Преобразует относительные имена файлов в выводе GNU Make в абсолютные.
.Description
    Преобразует относительные имена файлов в выводе GNU Make в абсолютные.
.Example
    make 2>&1 | .\.vscode\Resolve-PathInGNUMakeLog.ps1;
#>
[CmdletBinding(
    SupportsShouldProcess = $false
)]

param (
    # Строка вывода GNU Make.
	[Parameter(
		Mandatory = $true
		, ValueFromPipeline = $true
	)]
	[Alias('GNUMakeOutput')]
	[AllowEmptyString()]
	[String]
    $InputObject
)

process {
	$ErrorActionPreference = 'Continue';
	Switch -Regex ( $_ ) {
		'make(?:\.exe)?\s+.*?-C\s+(?<subDir>\S+)' {
			Push-Location $Matches['subDir'];
			$_
		}
		'^make\[\d+\]: Leaving directory ''(?<subDir>.+?)''' {
			Pop-Location;
			$_
		}
		'^(.+?):(\d+):\s+(.*?) Stop.$' {
			$_ -replace '^(.+?)(?=:)', "$( Join-Path (Get-Location) '$1')"
		}
		'^make: \*\*\* \[(?<fileName>\S+?):(?<line>\d+):\s*(.*?)\]\s+(?<saverity>Error|Warning)\s+(?<code>\d+)$' {
			$_ -replace '(?<=make: \*\*\* \[)(\S+?)(?=:)', "$( Join-Path (Get-Location) '$1')"
		} `
		default { $_ }
	};
}
