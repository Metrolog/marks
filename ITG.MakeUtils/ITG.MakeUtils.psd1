@{

RootModule = 'ITG.MakeUtils.psm1'
ModuleVersion = '0.7'
GUID = '3558AE06-9A3C-4332-BDD5-6F3990C6650E'
Author = 'Sergey S. Betke'
CompanyName = 'IT-Service.Nov.RU'
Copyright = '(c) 2013 Sergey S. Betke. All rights reserved.'
Description = @'
Данный модуль предоставляет набор командлет для сборки проектов с использованием ITG.MakeUtils
(см. https://github.com/IT-Service/ITG.MakeUtils).
'@
PowerShellVersion = '3.0'
PowerShellHostName = ''
PowerShellHostVersion = ''
DotNetFrameworkVersion = '4.0'
CLRVersion = '4.0'
ProcessorArchitecture = ''
RequiredModules = @(
	@{ ModuleName = 'Microsoft.PowerShell.Utility'; ModuleVersion = '3.1'; GUID = '1DA87E53-152B-403E-98DC-74D7B4D63D59' } `
)
RequiredAssemblies = @()
ScriptsToProcess = @()
TypesToProcess = @()
FormatsToProcess = @()
NestedModules = @()
FunctionsToExport = '*'
CmdletsToExport = '*'
VariablesToExport = '*'
AliasesToExport = '*'
ModuleList = @()
FileList = `
	'ITG.MakeUtils.psm1' `
,	'ITG.MakeUtils.psd1' `
;
PrivateData = @{}

}