param(
    [string]$Godot = "godot"
)
$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

python -m unittest discover -s (Join-Path $ProjectRoot "tests") -p "test_*.py" -v
if ($LASTEXITCODE -ne 0) { throw "Python structure test failed ($LASTEXITCODE)" }

& $Godot --headless --path $ProjectRoot --import --quit
if ($LASTEXITCODE -ne 0) { throw "Godot import failed ($LASTEXITCODE)" }

& $Godot --headless --path $ProjectRoot --script res://tests/smoke_runner.gd
if ($LASTEXITCODE -ne 0) { throw "Godot smoke test failed ($LASTEXITCODE)" }

Write-Host "STEP0_VERIFICATION_OK"
