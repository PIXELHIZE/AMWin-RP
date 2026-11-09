[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$')]
    [string]$Version,

    [Parameter(Mandatory)]
    [ValidateSet('x64', 'arm64')]
    [string]$Architecture
)

$ErrorActionPreference = 'Stop'

$runtime = "win-$Architecture"
$output = Join-Path $PSScriptRoot "artifacts/velopack/$Version/$runtime"
$publishDirectory = Join-Path $output 'publish'
$releaseDirectory = Join-Path $output 'release'
$project = Join-Path $PSScriptRoot 'AMWin-RichPresence/AMWin-RichPresence.csproj'
$icon = Join-Path $PSScriptRoot 'AMWin-RichPresence/Resources/AMWinRP.ico'

dotnet publish $project --configuration Release --runtime $runtime --self-contained true --output $publishDirectory "-p:Version=$Version" "-p:FileVersion=$Version"
if ($LASTEXITCODE -ne 0) {
    throw "dotnet publish failed for $runtime"
}

# .NET's settings provider needs the configuration file next to the application.
if (-not (Test-Path -LiteralPath (Join-Path $publishDirectory 'AMWin-RichPresence.dll.config') -PathType Leaf)) {
    throw "Missing application configuration in $runtime publish output"
}

dnx vpk --version 1.2.161 --yes -- pack `
    --packId PIXELHIZE.AMWin-RP `
    --packTitle AMWin-RichPresence `
    --packVersion $Version `
    --packDir $publishDirectory `
    --mainExe AMWin-RichPresence.exe `
    --icon $icon `
    --runtime $runtime `
    --channel $runtime `
    --outputDir $releaseDirectory
if ($LASTEXITCODE -ne 0) {
    throw "Velopack packaging failed for $runtime"
}
