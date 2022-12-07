
function New-VsVersionInfo
{
    [CmdletBinding()]
	param(
		[string] $VsFileVersion = "",
		[string] $VsProductVersion = "",
		[string] $CompanyName = "Devolutions",
		[string] $FileDescription = "",
		[string] $FileVersion = "",
		[string] $InternalName = "",
		[string] $LegalCopyright = "",
		[string] $OriginalFilename = "",
		[string] $ProductName = "",
		[string] $ProductVersion = ""
    )

    # https://learn.microsoft.com/en-us/windows/win32/menurc/versioninfo-resource
    # https://learn.microsoft.com/en-us/windows/win32/api/verrsrc/ns-verrsrc-vs_fixedfileinfo

    $FileExtension = $OriginalFileName -Replace "(.*)\.(\w*)", "`$2"

    if ($FileExtension -eq 'exe') {
        $FileType = '0x1L' # VFT_APP
    } elseif ($FileExtension -eq 'dll') {
        $FileType = '0x2L' # VFT_DLL
    } else {
        $FileType = '0x0L' # VFT_UNKNOWN
    }

	@"
#include <winresrc.h>
VS_VERSION_INFO VERSIONINFO
    FILEVERSION ${VsFileVersion}
    PRODUCTVERSION ${VsProductVersion}
    FILEFLAGSMASK 0x3fL
#ifdef _DEBUG
    FILEFLAGS 0x1L
#else
    FILEFLAGS 0x0L
#endif
    FILEOS 0x40004L
    FILETYPE ${FileType}
    FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904b0"
        BEGIN
            VALUE "CompanyName", "${CompanyName}"
            VALUE "FileDescription", "${FileDescription}"
            VALUE "FileVersion", "${FileVersion}"
            VALUE "InternalName", "${InternalName}"
            VALUE "LegalCopyright", "${LegalCopyright}"
            VALUE "OriginalFilename", "${OriginalFilename}"
            VALUE "ProductName", "${ProductName}"
            VALUE "ProductVersion", "${ProductVersion}"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x0409, 1200
    END
END
"@
}
