
. $PSScriptRoot\common.ps1

$NugetVersion = "1.0.4"

if ($args.Count -gt 0) {
	$NugetVersion = $args[0]
}

$NugetName = "Microsoft.VCRTForwarders.140"
$NupkgBaseName = "Microsoft.VCRTForwarders.140.$NugetVersion"
$NupkgFileName = "$NupkgBaseName.nupkg"

Invoke-WebRequest "https://www.nuget.org/api/v2/package/$NugetName/$Version" -OutFile $NupkgFileName

Remove-Item .\$NupkgBaseName -Recurse -ErrorAction SilentlyContinue | Out-Null
Expand-Archive -Path .\$NupkgFileName -Destination .\$NupkgBaseName
Remove-Item .\$NupkgFileName -Force | Out-Null

$ProductVersion = "$NugetVersion.0"
$ProductName = "VCRT Forwarders"
$CompanyName = "Microsoft"
$LegalCopyright = "Copyright 2020, $CompanyName"
$VsProductVersion = $ProductVersion -Replace "(\d*).(\d*).(\d*).(\d*)", "`$1,`$2,`$3,`$4"

# choco install reshack -y
$ResHackCmd = Get-Item "C:\Program Files (x86)\Resource Hacker\ResourceHacker.exe"

if (-Not (Get-Command -Name 'rc.exe' -ErrorAction SilentlyContinue)) {
    throw "rc.exe not in PATH! Use a proper Visual Studio developer environment"
}

Get-Item .\$NupkgBaseName\runtimes\win10-*\native\*\*.dll | ForEach-Object {
    $FileName = $_.Name
    $DllName = $_.FullName
    $RcFile = $_.FullName -Replace '.dll', '.rc'
    $ResFile = $_.FullName -Replace '.dll', '.res'

    Write-Host "$FileName / $RcFile"

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
    Set-Content -Path $RcFile -Value $VersionInfo -Force

    & rc.exe '/nologo' $RcFile

    Start-Process -FilePath $ResHackCmd.FullName -ArgumentList @(
        '-open', $DllName,
        '-save', $DllName,
        '-resource', $ResFile,
        '-action', 'addoverwrite',
        '-mask', 'VersionInf',
        '-log', 'CONSOLE'
    ) -Wait

    Remove-Item $RcFile -Force -ErrorAction SilentlyContinue
    Remove-Item $ResFile -Force -ErrorAction SilentlyContinue
}

if ((Test-Path Env:CODESIGN_THUMBPRINT) -and (Test-Path Env:TIMESTAMP_SERVER)) {
    $TimestampServer = $Env:TIMESTAMP_SERVER
    $Certificate = Get-Item cert:\CurrentUser\My\$Env:CODESIGN_THUMBPRINT
    Get-Item .\$NupkgBaseName\runtimes\win10-*\native\*\*.dll | ForEach-Object {
        Set-AuthenticodeSignature -Certificate $Certificate -TimestampServer $TimestampServer $_
    }
}

Remove-Item .\$NupkgFileName -Force -ErrorAction SilentlyContinue | Out-Null
Compress-Archive .\$NupkgBaseName\* -DestinationPath .\$NupkgFileName -CompressionLevel Optimal
Remove-Item .\$NupkgBaseName -Recurse -Force
