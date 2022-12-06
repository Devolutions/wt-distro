
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
    FILETYPE 0x1L
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
        VALUE "Translation", 0x0000, 1200
    END
END
"@
}

$ProductVersion = "1.16.2641.0"

$FileName = "WindowsTerminal.exe"

$ProductName = "Windows Terminal"
$CompanyName = "Devolutions Inc."
$InternalName = $FileName -Replace "(.*)(\.\w*)", "`$1"
$LegalCopyright = "Copyright $((Get-Date).Year), $CompanyName"
$VsProductVersion = $ProductVersion -Replace "(\d*).(\d*).(\d*).(\d*)", "`$1,`$2,`$3,`$4"

$Params = @{
	VsFileVersion = $VsProductVersion
	VsProductVersion = $VsProductVersion
	CompanyName = $CompanyName
	FileDescription = $FileName
	FileVersion = $ProductVersion
	InternalName = $InternalName
	LegalCopyright = $LegalCopyright
	OriginalFilename = $FileName
	ProductName = $ProductName
	ProductVersion = $ProductVersion
}

New-VsVersionInfo @Params

# elevate-shim.exe / src\cascadia\ElevateShim\elevate-shim.rc
# OpenConsole.exe
# TerminalAzBridge.exe
# WindowsTerminal.exe / src\cascadia\WindowsTerminal\WindowsTerminal.rc
# wtd.exe

# OpenConsoleProxy.dll
# TerminalApp.dll
# TerminalConnection.dll
# TerminalThemeHelpers.dll
# WindowsTerminalShellExt.dll

# Microsoft.Terminal.Control.dll
# Microsoft.Terminal.Remoting.dll
# Microsoft.Terminal.Settings.Editor.dll
# Microsoft.Terminal.Settings.Model.dll
