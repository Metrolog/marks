﻿Function New-Directory {
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
		# передавать каталог далее по конвейеру или нет
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

New-Alias -Name cp -Value Copy-Item -Option AllScope -Scope Global -Force;

Export-ModuleMember -Alias cp;

New-Alias -Name curl -Value Invoke-WebRequest -Option AllScope -Scope Global -Force;

Export-ModuleMember -Alias curl;

Function Add-UnitTest {
<#
.Synopsis
	Загрушка. Аналогичные функции применяются для добавления теста в консоль build серверов.
#>
	[CmdletBinding(
		SupportsShouldProcess = $false
	)]

	param (
		[Parameter( Mandatory = $true )]
		[ValidateNotNull()]
		[Alias('Name')]
		[String]
		$TestId
	,
		[Parameter( Mandatory = $false )]
		[String]
		$FileName = ''
	)

}

Export-ModuleMember -Function Add-UnitTest;

Function Set-UnitTestStatusInformation {
<#
.Synopsis
	Загрушка. Аналогичные функции применяются для отображения информации о текущем состоянии теста.
#>
	[CmdletBinding(
		SupportsShouldProcess = $false
	)]

	param (
		[Parameter( Mandatory = $true )]
		[ValidateNotNull()]
		[Alias('Name')]
		[String]
		$TestId
	,
		[Parameter( Mandatory = $false )]
		[String]
		$FileName = ''
	,
		[Parameter( Mandatory = $true )]
		[ValidateSet( 'None', 'Running', 'Passed', 'Failed', 'Ignored', 'Skipped', 'Inconclusive', 'NotFound', 'Cancelled', 'NotRunnable')]
		[Alias('Outcome')]
		[String]
		$Status
	,
		[Parameter( Mandatory = $false )]
		[Alias('Duration')]
		[System.TimeSpan]
		$TimeElapsed = 0
	,
		[Parameter( Mandatory = $false )]
		[String]
		$StdOut = ''
	,
		[Parameter( Mandatory = $false )]
		[String]
		$StdErr = ''
	)

	switch ($Status) {
		'Failed' {
			Write-Error "Test '$TestId' is $Status$( & { if ( $TimeElapsed -ne 0 ) { "" in $($TimeElapsed)"" } } ).";
		}
		default {
			Write-Information "Test '$TestId' is $Status$( & { if ( $TimeElapsed -ne 0 ) { "" in $($TimeElapsed)"" } } ).";
		}
	}

}

Export-ModuleMember -Function Set-UnitTestStatusInformation;

Function Test-UnitTest {
<#
.Synopsis
	Обёртка для выполнения модульных тестов.
#>
	[CmdletBinding(
		SupportsShouldProcess = $false
	)]

	param (
		[Parameter(
			Mandatory = $true
		)]
		[ValidateNotNull()]
		[String]
		$TestId
	,
		[Parameter( Mandatory = $false )]
		[String]
		$FileName = ''
	,
		[Parameter(
			Mandatory = $true
		)]
		[ScriptBlock]
		$ScriptBlock
	,
		[Parameter(
			Mandatory = $false
		)]
		[ValidateNotNull()]
		[ScriptBlock]
		$StatusWriter = ${Function:Set-UnitTestStatusInformation}
	,
		[Parameter(
			Mandatory = $false
		)]
		[ValidateNotNull()]
		[ScriptBlock]
		$TestCreator = ${Function:Add-UnitTest}
	)

	Invoke-Command -ScriptBlock $TestCreator -ArgumentList $TestId, $FileName;
	Invoke-Command -ScriptBlock $StatusWriter -ArgumentList $TestId, $FileName, 'Running';
	$sw = [Diagnostics.Stopwatch]::StartNew();
	$Passed = $true;
	$testScriptOutput = '';
	$CurrentErrorActionPreference = $ErrorActionPreference;
	$ErrorActionPreference = 'Continue';
	try {
		# https://stackoverflow.com/questions/8097354/how-do-i-capture-the-output-into-a-variable-from-an-external-process-in-powershe
		$testScriptOutput = & { trap {}; & $ScriptBlock; } 2>&1;
		$sw.Stop();
		$testScriptOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] } | ForEach-Object {
			[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "Passed")]
			$Passed = $false;
		};
	} catch {
		$sw.Stop();
		$Passed = $false;
	} finally {
		$testScriptStdOutput = $testScriptOutput | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] } | Out-String;
		$testScriptStdError = $testScriptOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] } | Out-String;
		$testScriptOutput `
		| ForEach-Object {
			if ( $_ -is [System.Management.Automation.ErrorRecord] ) {
				$_;
			} else {
				Write-Information $_;
			};
		};
		$ErrorActionPreference = $CurrentErrorActionPreference;
		if ( $Passed ) {
			Invoke-Command -ScriptBlock $StatusWriter -ArgumentList $TestId, $FileName, 'Passed', ($sw.Elapsed), $testScriptStdOutput;
		} else {
			Invoke-Command -ScriptBlock $StatusWriter -ArgumentList $TestId, $FileName, 'Failed', ($sw.Elapsed), $testScriptStdOutput, $testScriptStdError;
		};
	};
}

Export-ModuleMember -Function Test-UnitTest;
