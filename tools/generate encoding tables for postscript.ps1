$EncodingsDir = Join-Path `
    -Path (Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)) `
    -ChildPath 'encodings' `
;
$AGLFilePath = Join-Path `
    -Path (Join-Path -Path $EncodingsDir -ChildPath 'agl-aglfn') `
    -ChildPath 'aglfn.txt' `
;
$DestDir = Join-Path `
    -Path (
        Join-Path `
            -Path (Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)) `
            -ChildPath 'sources' `
    ) `
    -ChildPath 'inc' `
;
$GlyphNames = New-Object String[] 0x10000;
Get-Content `
    -LiteralPath $AGLFilePath `
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

$CP1251EncodingTable = New-Object String[] 0x100;
$CP1251EncodingSourceFilePath = Join-Path `
    -Path $EncodingsDir `
    -ChildPath 'CP1251.TXT' `
;
$CP1251EncodingFilePath = Join-Path `
    -Path $DestDir `
    -ChildPath 'cp1251.ps' `
;
Get-Content `
    -LiteralPath $CP1251EncodingSourceFilePath  `
    -Encoding UTF8 `
| ? { -not $_.StartsWith('#') } `
| ConvertFrom-Csv `
    -Delimiter "`t" `
    -Header ( 'EncodingCode', 'UnicodeCode', 'GlyphDescription' ) `
| ForEach-Object {
    if ( $GlyphNames[ [int32] $_.UnicodeCode ] ) {
        $CP1251EncodingTable[ [int32] ( $_.EncodingCode ) ] = $GlyphNames[ [int32] $_.UnicodeCode ];
    } else {
        $CP1251EncodingTable[ [int32] ( $_.EncodingCode ) ] = 'uni' + ( '{0:X4}' -f ( [int32] $_.UnicodeCode ) );
    };
} `
;
'/CP1251Encoding [' `
| Out-File -FilePath $CP1251EncodingFilePath -Encoding ascii -Force `
;
$CP1251EncodingTable `
| ForEach-Object { 
    if ( $_ ) {
        '/' + $_ 
    } else {
        '/null' 
    };
} `
| Out-File -FilePath $CP1251EncodingFilePath -Encoding ascii -Force -Append `
;
'] def' `
| Out-File -FilePath $CP1251EncodingFilePath -Encoding ascii -Force -Append `
;

$CP1253EncodingTable = New-Object String[] 0x100;
$CP1253EncodingSourceFilePath = Join-Path `
    -Path $EncodingsDir `
    -ChildPath 'CP1253.TXT' `
;
$CP1253EncodingFilePath = Join-Path `
    -Path $DestDir `
    -ChildPath 'cp1253.ps' `
;
Get-Content `
    -LiteralPath $CP1253EncodingSourceFilePath  `
    -Encoding UTF8 `
| ? { -not $_.StartsWith('#') } `
| ConvertFrom-Csv `
    -Delimiter "`t" `
    -Header ( 'EncodingCode', 'UnicodeCode', 'GlyphDescription' ) `
| ForEach-Object {
    if ( $GlyphNames[ [int32] $_.UnicodeCode ] ) {
        $CP1253EncodingTable[ [int32] ( $_.EncodingCode ) ] = $GlyphNames[ [int32] $_.UnicodeCode ];
    } else {
        $CP1253EncodingTable[ [int32] ( $_.EncodingCode ) ] = 'uni' + ( '{0:X4}' -f ( [int32] $_.UnicodeCode ) );
    };
} `
;
'/CP1253Encoding [' `
| Out-File -FilePath $CP1253EncodingFilePath -Encoding ascii -Force `
;
$CP1253EncodingTable `
| ForEach-Object { 
    if ( $_ ) {
        '/' + $_ 
    } else {
        '/null' 
    };
} `
| Out-File -FilePath $CP1253EncodingFilePath -Encoding ascii -Force -Append `
;
'] def' `
| Out-File -FilePath $CP1253EncodingFilePath -Encoding ascii -Force -Append `
;
