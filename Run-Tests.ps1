param(
    [ValidatePattern('^[A-Za-z][A-Za-z0-9_]{0,100}$')][string]$Database = 'FlowerParadiseVerification',
    [string]$Server = '(LocalDB)\MSSQLLocalDB'
)
$ErrorActionPreference = 'Stop'
if ($Database -notmatch '(?i)(Test|Verification)') { throw 'Use a separate database containing Test or Verification in its name.' }
$previousConnection = $env:FLOWERPARADISE_CONNECTION_STRING
$previousTestConnection = $env:FLOWERPARADISE_TEST_CONNECTION_STRING
$previousPreview = $env:FLOWERPARADISE_PREVIEW_DIR
try {
    $env:FLOWERPARADISE_CONNECTION_STRING = $null
    & (Join-Path $PSScriptRoot 'Build.ps1') -Tests
    & (Join-Path $PSScriptRoot 'Initialize-Database.ps1') -Server $Server -Database $Database
    if ($LASTEXITCODE -ne 0) { throw 'Database initialization failed.' }
    $env:FLOWERPARADISE_TEST_CONNECTION_STRING = 'Data Source=' + $Server + ';Initial Catalog=' + $Database + ';Integrated Security=True;Connect Timeout=30'
    $env:FLOWERPARADISE_PREVIEW_DIR = Join-Path $PSScriptRoot 'docs\screenshots'
    & (Join-Path $PSScriptRoot 'FlowerParadise.Tests.exe')
    if ($LASTEXITCODE -ne 0) { throw 'Integration checks failed.' }
} finally {
    $env:FLOWERPARADISE_CONNECTION_STRING = $previousConnection
    $env:FLOWERPARADISE_TEST_CONNECTION_STRING = $previousTestConnection
    $env:FLOWERPARADISE_PREVIEW_DIR = $previousPreview
}
