<# 
.Synopsis 
    Создание файла с таблицей указанной кодировки для PostScript
.Description 
    Данный сценарий создаёт файл с таблицей указанной кодировки
    для PostScript с использованием правил именования глифов
    AGLFN (Adobe Glyphs List For New fonts).
#> 
[CmdletBinding(
    SupportsShouldProcess = $false
)]
 
param (
    # Путь к файлу aglfn.txt
    [parameter(
        Mandatory = $false
    )]
    [String]
    [ValidateNotNullOrEmpty()]
    $AGLFNFilePath = (
        Join-Path `
            -Path 'agl-aglfn' `
            -ChildPath 'aglfn.txt' `
    )
,
    # Путь к исходному файлу кодировки
    [parameter(
        Mandatory = $true
        , Position = 0
    )]
    [String]
    [ValidateNotNullOrEmpty()]
    $EncodingSourceFilePath
,
    # Кодировка
    [parameter(
        Mandatory = $false
    )]
    [String]
    [ValidateNotNullOrEmpty()]
    $Encoding = ( [System.IO.Path]::GetFileNameWithoutExtension( $EncodingSourceFilePath ) ) `
,
    # Путь к генерируемому файлу
    [parameter(
        Mandatory = $false
        , Position = 1
    )]
    [String]
    [ValidateNotNullOrEmpty()]
    $FilePath = "${Encoding}.ps" `
)

$GlyphNames = New-Object String[] 0x10000;
Get-Content `
    -LiteralPath $AGLFNFilePath `
    -Encoding UTF8 `
| ? { -not $_.StartsWith('#') } `
| ConvertFrom-Csv `
    -Delimiter ';' `
    -Header ( 'Code', 'GlyphName', 'GlyphDescription' ) `
| ForEach-Object {
    $GlyphName = $_.GlyphName;
    $UnicodeCode = [int32] ( '0x' + $_.Code );
    if ( -not $GlyphNames[ $UnicodeCode ] ) {
        $GlyphNames[ $UnicodeCode ]  = $GlyphName;
    };
};

$EncodingTable = New-Object String[] 0x100;
Get-Content `
    -LiteralPath $EncodingSourceFilePath  `
    -Encoding UTF8 `
| ? { -not $_.StartsWith('#') } `
| ConvertFrom-Csv `
    -Delimiter "`t" `
    -Header ( 'EncodingCode', 'UnicodeCode', 'GlyphDescription' ) `
| ForEach-Object {
    if ( $GlyphNames[ [int32] $_.UnicodeCode ] ) {
        $EncodingTable[ [int32] ( $_.EncodingCode ) ] = $GlyphNames[ [int32] $_.UnicodeCode ];
    } else {
        $EncodingTable[ [int32] ( $_.EncodingCode ) ] = 'uni' + ( '{0:X4}' -f ( [int32] $_.UnicodeCode ) );
    };
} `
;

function ConvertTo-PostScriptEncodingTable {

	param (
		# имя глифа
		[Parameter(
			Mandatory = $true
			, ValueFromPipeline = $true
		)]
		[String]
		$GlyphName
    ,
        # Кодировка
        [parameter(
            Mandatory = $true
        )]
        [String]
        [ValidateNotNullOrEmpty()]
        $Encoding
	)

	begin {
        return "/${Encoding}Encoding [";
	}
	process {
        if ( $GlyphName ) {
            return "/$GlyphName";
        } else {
            return '/null';
        };
	}
	end {
        return '] def';
	}

}

$EncodingTable `
| ConvertTo-PostScriptEncodingTable -Encoding $Encoding `
| Out-File -FilePath $FilePath -Encoding ascii -Force `
;
