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
| Where-Object { -not $_.StartsWith('#') } `
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
| Where-Object { -not $_.StartsWith('#') } `
| ConvertFrom-Csv `
    -Delimiter "`t" `
    -Header ( 'EncodingCode', 'UnicodeCode', 'GlyphDescription' ) `
| ForEach-Object {
	$UnicodeCode = [int32] $_.UnicodeCode;
	$EncodingCode = [int32] $_.EncodingCode;
	if ( $EncodingCode -lt 0x20 ) {
        $EncodingTable[ $EncodingCode ] = '.notdef';
    } elseif ( $UnicodeCode -eq 0 ) {
        $EncodingTable[ $EncodingCode ] = '.notdef';
    } elseif ( $GlyphNames[ $UnicodeCode ] ) {
        $EncodingTable[ $EncodingCode ] = $GlyphNames[ $UnicodeCode ];
    } else {
        $EncodingTable[ $EncodingCode ] = "uni$( '{0:X4}' -f $UnicodeCode )";
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
		$CharIndex = 0;
		$OutputLine = '';
		$CharIndexInLine = 0;
		$LineIndexInBlock = 0;
		@"
%!PS-Adobe-3.0
%%Creator: Sergey S. Betke <sergey.s.betke@yandex.ru>
%%Copyright: 2018 Sergey S. Betke <sergey.s.betke@yandex.ru>
%%+ See LICENSE at https://github.com/Metrolog/marks
%%DocumentData: Clean7Bit
%%Title: ${Encoding} - PostScript Resource Encoding file
%%DocumentSuppliedResources: encoding (${Encoding}Encoding.ps)
%%Version: 1.0 0
%%EndComments
%%BeginProlog

%/${Encoding}Encoding.ps /Encoding resourcestatus { pop pop } {
%!PS-Adobe-3.0 Resource-Encoding
%%BeginResource: Encoding (${Encoding}Encoding.ps)
%%EndComments
/${Encoding}Encoding.ps [
"@;
	}
	process {
        if ( $GlyphName ) {
            $OutputGlyphName = "/${GlyphName}";
        } else {
            $OutputGlyphName = '/.notdef';
		};
		if ( ( $LineIndexInBlock -eq 0 ) -and ( $CharIndexInLine -eq 0 ) ) {
			@"
% 0x$( '{0:X2}' -f $CharIndex )
"@;
		};
		$OutputLine += $OutputGlyphName;
		$CharIndex ++;
		$CharIndexInLine = ( $CharIndexInLine + 1 ) % 8;
		if ( $CharIndexInLine -eq 0 ) {
			@"
${OutputLine}
"@;
			$OutputLine = '';
			$LineIndexInBlock = ( $LineIndexInBlock + 1 ) % 4;
		};
	}
	end {
		if ( $OutputLine ) {
			@"
${OutputLine}
"@;
		};
@"
] /Encoding defineresource pop
%%EndResource
%} ifelse
%%EndProlog
"@;
	}

}

$EncodingTable `
| ConvertTo-PostScriptEncodingTable -Encoding $Encoding `
| Out-File -FilePath $FilePath -Encoding ascii -Force `
;
