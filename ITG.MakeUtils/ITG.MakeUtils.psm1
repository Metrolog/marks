Function New-Directory {
<#
.Synopsis
	Кроссплатформенная альтернатива mkdir.
.Inputs
	System.String
	Путь к каталогу.
#>
	[CmdletBinding(
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Medium'
	)]

	param (
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
		)]
		[ValidateNotNullOrEmpty()]
		[String]
		$Path
	,
		# no error if existing, make parent directories as needed.
		# Не используется. Добавлен ради совместимости с параметром -p от mkdir
		[Alias('p')]
		[Switch]
		$Parents
	,
		# передавать домены далее по конвейеру или нет
		[Switch]
		$PassThru
	)

	process {
		If ( -not ( Test-Path -Path $Path ) ) {
			$Directory = New-Item `
				-ItemType Directory `
				-Path $Path `
				-Force `
				-WhatIf:$WhatIfPreference `
				-Verbose:$VerbosePreference `
				-Debug:$DebugPreference `
			;
			If ( $PassThru ) { return $Directory; }
		}
	}

}

New-Alias -Name mkdir -Value New-Directory -Option AllScope -Scope Global -Force;

Export-ModuleMember -Function New-Directory -Alias mkdir;

Function Remove-FileOrDirectory {
<#
.Synopsis
	Кроссплатформенная альтернатива rm.
.Inputs
	System.String
	Путь к каталогу, файлу.
#>
	[CmdletBinding(
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Medium'
	)]

	param (
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
		)]
		[ValidateNotNullOrEmpty()]
		[String]
		$Path
	,
		[Alias('r')]
		[Switch]
		$Recurse
	,
		[Alias('f')]
		[Switch]
		$Force
	)

	process {
		If ( Test-Path -Path $Path ) {
			Remove-Item `
				-Path $Path `
				-Recurse:$Recurse `
				-Force:$Force `
				-WhatIf:$WhatIfPreference `
				-Verbose:$VerbosePreference `
				-Debug:$DebugPreference `
			;
		}
	}

}

New-Alias -Name rm -Value Remove-FileOrDirectory -Option AllScope -Scope Global -Force;

Export-ModuleMember -Function Remove-FileOrDirectory -Alias rm;
