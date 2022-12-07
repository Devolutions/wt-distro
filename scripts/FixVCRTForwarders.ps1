
. $PSScriptRoot\common.ps1

$NugetVersion = "1.0.4"
$NugetName = "Microsoft.VCRTForwarders.140"
$NupkgBaseName = "Microsoft.VCRTForwarders.140.$NugetVersion"
$NupkgFileName = "$NupkgBaseName.nupkg"

Invoke-WebRequest "https://www.nuget.org/api/v2/package/$NugetName/$Version" -OutFile $NupkgFileName

Remove-Item .\$NupkgBaseName -Recurse -Force
Expand-Archive -Path .\$NupkgFileName -Destination .\$NupkgBaseName
Remove-Item .\$NupkgFileName -Force | Out-Null

$ProductVersion = "$NugetVersion.0"
$ProductName = "VCRT Forwarders"
$CompanyName = "Microsoft"
$LegalCopyright = "Copyright 2020, $CompanyName"
$VsProductVersion = $ProductVersion -Replace "(\d*).(\d*).(\d*).(\d*)", "`$1,`$2,`$3,`$4"

# choco install reshack -y
$Env:PATH += ";C:\Program Files (x86)\Resource Hacker"

if (-Not (Get-Command -Name 'ResourceHacker.exe' -ErrorAction SilentlyContinue)) {
	throw "ResourceHacker.exe not in PATH!"
}

$RcCommand = Get-Item "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\rc.exe" | sort -Descending | Select-Object -First 1

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

	& $RcCommand.FullName '/nologo' $RcFile

	Start-Process -FilePath "ResourceHacker.exe" -ArgumentList @(
		'-open', $DllName,
		'-save', $DllName,
		'-resource', $ResFile,
		'-action', 'addoverwrite',
		'-mask', 'VersionInf',
		'-log', 'CONSOLE'
	) -Wait

	Remove-Item $RcFile -Force
	Remove-Item $ResFile -Force
}

Remove-Item .\$NupkgFileName -Force -ErrorAction SilentlyContinue | Out-Null
Compress-Archive .\$NupkgBaseName\* -DestinationPath .\$NupkgFileName -CompressionLevel Optimal
Remove-Item .\$NupkgBaseName -Recurse -Force
