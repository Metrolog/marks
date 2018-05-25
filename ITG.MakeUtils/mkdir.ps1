[CmdletBinding(
    SupportsShouldProcess = $true,
    ConfirmImpact = 'Medium'
)]
 
param (
    [Parameter(
        Mandatory = $true,
        Position = 0
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $DirectoryPath
,
    # no error if existing, make parent directories as needed
    [Alias('p')]
    [Switch]
    $Parents
)

$OldVerbosePreference = $VerbosePreference;
$VerbosePreference = 'SilentlyContinue';

Import-Module -Name Microsoft.PowerShell.Utility;

$VerbosePreference = $OldVerbosePreference;

Write-Debug -Message "Создание каталога $($DirectoryPath)...";

If ( -not ( Test-Path -Path $DirectoryPath ) ) {
    New-Item `
        -ItemType Directory `
        -Path $DirectoryPath `
        -Force `
        -WhatIf:$WhatIfPreference `
        -Verbose:$VerbosePreference `
        -Debug:$DebugPreference `
    | Out-Null `
    ;
} 
