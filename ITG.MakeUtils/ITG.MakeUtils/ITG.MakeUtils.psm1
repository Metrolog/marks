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

New-Alias -Name cp -Value Copy-Item -Option AllScope -Scope Global -Force;

Export-ModuleMember -Alias cp;

New-Alias -Name curl -Value Invoke-WebRequest -Option AllScope -Scope Global -Force;

Export-ModuleMember -Alias curl;

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
		[Parameter( Mandatory = $true )]
		[ValidateSet( 'Running', 'Passed', 'Failed' )]
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
	
	Write-Information "Test '$TestId' is $Status$( & { if ( $TimeElapsed -ne 0 ) { "" in $($TimeElapsed)"" } } ).";
	
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
	)

	Invoke-Command -ScriptBlock $StatusWriter -ArgumentList $TestId, 'Running';
	$sw = [Diagnostics.Stopwatch]::StartNew();
	$Passed = $true;
	$testScriptOutput = '';
	$CurrentErrorActionPreference = $ErrorActionPreference;
	$ErrorActionPreference = 'Continue';
	try {
		# https://stackoverflow.com/questions/8097354/how-do-i-capture-the-output-into-a-variable-from-an-external-process-in-powershe
		$testScriptOutput = & { trap {}; & $ScriptBlock; } 2>&1;
		$sw.Stop();
		$testScriptOutput | ? { $_ -is [System.Management.Automation.ErrorRecord] } | % { $Passed = $false; };
	} catch {
		$sw.Stop();
		$Passed = $false;
	} finally {
		$testScriptStdOutput = $testScriptOutput | ? { $_ -isnot [System.Management.Automation.ErrorRecord] } | Out-String;
		$testScriptStdError = $testScriptOutput | ? { $_ -is [System.Management.Automation.ErrorRecord] } | Out-String;
		$testScriptOutput `
		| % {
			if ( $_ -is [System.Management.Automation.ErrorRecord] ) {
				$_;
			} else {
				Write-Information $_;
			};
		};
		if ( $Passed ) {
			Invoke-Command -ScriptBlock $StatusWriter -ArgumentList $TestId, 'Passed', ($sw.Elapsed), $testScriptStdOutput;
		} else {
			Invoke-Command -ScriptBlock $StatusWriter -ArgumentList $TestId, 'Failed', ($sw.Elapsed), $testScriptStdOutput, $testScriptStdError;
		};
		$ErrorActionPreference = $CurrentErrorActionPreference;
	};
}

Export-ModuleMember -Function Test-UnitTest;
