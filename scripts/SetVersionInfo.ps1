
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

if ($args.count -lt 2) {
    throw "insufficient arguments - <SourcePath> <ProductVersion>"
}

$SourcePath = $args[0]
$ProductVersion = $args[1]

$ProductName = "Windows Terminal"
$CompanyName = "Devolutions Inc."
$LegalCopyright = "Copyright $((Get-Date).Year), $CompanyName"
$VsProductVersion = $ProductVersion -Replace "(\d*).(\d*).(\d*).(\d*)", "`$1,`$2,`$3,`$4"

$VersionFiles = @{
    "wt.exe" = "src\cascadia\wt\wt.rc";
    "WindowsTerminal.exe" = "src\cascadia\WindowsTerminal\WindowsTerminal.rc";
    "WindowsTerminalShellExt.dll" = "src\cascadia\ShellExtension\WindowsTerminalShellExt.vcxproj";

    "elevate-shim.exe" = "src\cascadia\ElevateShim\elevate-shim.rc";

    "OpenConsole.exe" = "src\host\exe\Host.EXE.rc";
    "OpenConsoleProxy.dll" = "src\host\proxy\Host.Proxy.vcxproj";

    "TerminalApp.dll" = "src\cascadia\TerminalApp\dll\TerminalApp.vcxproj";
    "TerminalAzBridge.exe" = "src\cascadia\TerminalAzBridge\TerminalAzBridge.vcxproj";
    "TerminalConnection.dll" = "src\cascadia\TerminalConnection\TerminalConnection.vcxproj";

    "Microsoft.Terminal.Control.dll" = "src\cascadia\TerminalControl\dll\TerminalControl.vcxproj";
    "Microsoft.Terminal.Remoting.dll" = "src\cascadia\Remoting\dll\Microsoft.Terminal.Remoting.vcxproj";
    "Microsoft.Terminal.Settings.Editor.dll" = "src\cascadia\TerminalSettingsEditor\Microsoft.Terminal.Settings.Editor.vcxproj";
    "Microsoft.Terminal.Settings.Model.dll" = "src\cascadia\TerminalSettingsModel\dll\Microsoft.Terminal.Settings.Model.vcxproj";
}

$VersionFiles.GetEnumerator() | ForEach-Object {
    $FileName = $_.Name
    $ProjectFile = Join-Path $SourcePath $_.Value

    Write-Host "$FileName / $($_.Value)"

    $InternalName = $FileName -Replace "(.*)(\.\w*)", "`$1"

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

    $VersionInfo = New-VsVersionInfo @Params

    if ($ProjectFile.EndsWith(".rc")) {
        if (-Not ((Get-Content $ProjectFile) | Select-String -Pattern '#include "version.rc"')) {
            Add-Content -Path $ProjectFile -Value '#include "version.rc"'
        }
    }

    $VersionRC = Join-Path (Get-Item $ProjectFile).Directory "version.rc"
    Set-Content -Path $VersionRC -Value $VersionInfo -Force
}
