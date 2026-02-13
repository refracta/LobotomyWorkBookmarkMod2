param(
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ProjectPath = Join-Path $RepoRoot "src\refracta_WorkBookmark_MOD\refracta_WorkBookmark_MOD.csproj"
$BuildOutputDir = Join-Path $RepoRoot ("out\" + $Configuration + "\refracta_WorkBookmark_MOD")
$PackageRoot = Join-Path $RepoRoot "dist\refracta_WorkBookmark_MOD"
$ZipPath = Join-Path $RepoRoot "dist\refracta_WorkBookmark_MOD.zip"
$InfoRoot = Join-Path $RepoRoot "mod\refracta_WorkBookmark_MOD\Info"

if (Test-Path $BuildOutputDir) {
    Remove-Item -Path $BuildOutputDir -Recurse -Force
}
if (Test-Path $PackageRoot) {
    Remove-Item -Path $PackageRoot -Recurse -Force
}
if (Test-Path $ZipPath) {
    Remove-Item -Path $ZipPath -Force
}

New-Item -ItemType Directory -Path $BuildOutputDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $PackageRoot "Info\kr") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $PackageRoot "Info\en") -Force | Out-Null

dotnet build $ProjectPath -c $Configuration -o $BuildOutputDir
if ($LASTEXITCODE -ne 0) {
    throw "Build failed."
}

$BuiltDllPath = Join-Path $BuildOutputDir "refracta_WorkBookmark_MOD.dll"
if (-not (Test-Path $BuiltDllPath)) {
    throw "Built DLL not found: $BuiltDllPath"
}

if (-not (Test-Path (Join-Path $InfoRoot "kr\Info.xml"))) {
    throw "KR Info.xml not found in mod template."
}
if (-not (Test-Path (Join-Path $InfoRoot "en\Info.xml"))) {
    throw "EN Info.xml not found in mod template."
}

Copy-Item -Path $BuiltDllPath -Destination (Join-Path $PackageRoot "refracta_WorkBookmark_MOD.dll") -Force
Copy-Item -Path (Join-Path $InfoRoot "kr\Info.xml") -Destination (Join-Path $PackageRoot "Info\kr\Info.xml") -Force
Copy-Item -Path (Join-Path $InfoRoot "en\Info.xml") -Destination (Join-Path $PackageRoot "Info\en\Info.xml") -Force

Compress-Archive -Path $PackageRoot -DestinationPath $ZipPath -Force

Write-Output ("Built DLL: " + $BuiltDllPath)
Write-Output ("Zip: " + $ZipPath)
