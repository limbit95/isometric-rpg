param(
    [string]$Godot = "godot"
)
$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Invoke-GodotChecked {
    param([string[]]$GodotArgs, [string]$CheckName)
    $lines = & $Godot @GodotArgs 2>&1
    $exitCode = $LASTEXITCODE
    $output = $lines | Out-String
    Write-Host $output
    if ($exitCode -ne 0 -or $output.Contains("ERROR:")) {
        throw "$CheckName failed (exit code: $exitCode, engine error logged: $($output.Contains('ERROR:')))"
    }
}

python -m unittest discover -s (Join-Path $ProjectRoot "tests") -p "test_*.py" -v
if ($LASTEXITCODE -ne 0) { throw "Python contract tests failed ($LASTEXITCODE)" }

Invoke-GodotChecked -GodotArgs @("--headless", "--path", $ProjectRoot, "--import", "--quit") -CheckName "Godot import"
Invoke-GodotChecked -GodotArgs @("--headless", "--path", $ProjectRoot, "--script", "res://tests/smoke_runner.gd") -CheckName "STEP0"
Invoke-GodotChecked -GodotArgs @("--headless", "--path", $ProjectRoot, "--script", "res://tests/combat_smoke_runner.gd") -CheckName "STEP1"
Invoke-GodotChecked -GodotArgs @("--headless", "--path", $ProjectRoot, "--script", "res://tests/enemy_ai_smoke_runner.gd") -CheckName "STEP2"
Invoke-GodotChecked -GodotArgs @("--headless", "--path", $ProjectRoot, "--script", "res://tests/skills_smoke_runner.gd") -CheckName "STEP3"
Invoke-GodotChecked -GodotArgs @("--headless", "--path", $ProjectRoot, "--script", "res://tests/progression_inventory_smoke_runner.gd") -CheckName "STEP4"

Write-Host "STEP4_VERIFICATION_OK"
