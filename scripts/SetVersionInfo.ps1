
. $PSScriptRoot\common.ps1

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
