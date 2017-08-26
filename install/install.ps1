<# 
.Synopsis 
    Скрипт подготовки среды сборки и тестирования проекта
.Description 
    Скрипт подготовки среды сборки и тестирования проекта.
.Link 
    https://github.com/Metrolog/marks
.Example 
    .\install.ps1 -GUI;
    Устанавливаем необходимые пакеты, в том числе - и графические среды.
#> 
[CmdletBinding(
    SupportsShouldProcess = $true
    , ConfirmImpact = 'Medium'
    , HelpUri = 'https://github.com/Metrolog/marks'
)]
 
param (
    # Ключ, определяющий необходимость установки визуальных средств.
    # По умолчанию устанавливаются только средства для командной строки.
    [Switch]
    $GUI
) 

Import-Module -Name PackageManagement;

$null = Install-PackageProvider -Name NuGet -Force;
$null = Import-PackageProvider -Name NuGet -Force;
$null = (
    Get-PackageSource -ProviderName NuGet `
    | Set-PackageSource -Trusted `
);
$null = Install-PackageProvider -Name Chocolatey -Force;
$null = Import-PackageProvider -Name Chocolatey -Force;
$null = (
    Get-PackageSource -ProviderName Chocolatey `
    | Set-PackageSource -Trusted `
);
if ( -not ( $env:APPVEYOR -eq 'True' ) ) {
    $null = Install-Package -Name chocolatey -MinimumVersion 0.9.10.3 -ProviderName Chocolatey;
};
$null = Import-PackageProvider -Name Chocolatey -Force;
$null = (
    Get-PackageSource -ProviderName Chocolatey `
    | Set-PackageSource -Trusted `
);

& choco install gsview --confirm --failonstderr | Out-String -Stream | Write-Verbose;
