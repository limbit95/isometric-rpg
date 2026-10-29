param(
    [string]$Godot = "godot"
)
$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

python -m unittest discover -s (Join-Path $ProjectRoot "tests") -p "test_*.py" -v
if ($LASTEXITCODE -ne 0) { throw "Python contract tests failed ($LASTEXITCODE)" }

& $Godot --headless --path $ProjectRoot --import --quit
if ($LASTEXITCODE -ne 0) { throw "Godot import failed ($LASTEXITCODE)" }

& $Godot --headless --path $ProjectRoot --script res://tests/smoke_runner.gd
if ($LASTEXITCODE -ne 0) { throw "STEP0 smoke test failed ($LASTEXITCODE)" }

& $Godot --headless --path $ProjectRoot --script res://tests/combat_smoke_runner.gd
if ($LASTEXITCODE -ne 0) { throw "STEP1 combat smoke test failed ($LASTEXITCODE)" }

Write-Host "STEP1_VERIFICATION_OK"
