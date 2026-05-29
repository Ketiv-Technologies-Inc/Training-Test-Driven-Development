# push-to-github.ps1
# One-shot script: clean up, init, commit, push to the Ketiv training repo.
# Run from this folder in PowerShell:
#   powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1

$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/Ketiv-Technologies-Inc/Training-Test-Driven-Development.git"
$RepoRoot = $PSScriptRoot

Write-Host "==> Working in $RepoRoot" -ForegroundColor Cyan
Set-Location $RepoRoot

# 1. Remove any stale .git directory from prior sandbox attempts
if (Test-Path ".git") {
    Write-Host "==> Removing stale .git directory" -ForegroundColor Yellow
    # Force-remove read-only files (sandbox may have left some)
    Get-ChildItem -Path ".git" -Recurse -Force -ErrorAction SilentlyContinue |
        ForEach-Object { $_.Attributes = 'Normal' }
    Remove-Item ".git" -Recurse -Force
}

# 2. Initialize fresh repo on main
Write-Host "==> git init -b main" -ForegroundColor Cyan
git init -b main | Out-Null

# 3. Configure local identity (override if you want global config instead)
#    Change these to your preferred name/email, or comment them out to inherit global config.
git config user.name  "Addam Boord"
git config user.email "addamboord@gmail.com"

# 4. Stage and commit
Write-Host "==> Staging files" -ForegroundColor Cyan
git add -A

$commitMessage = @"
Initial commit: Unit Testing & TDD training program

Three-session beginner-to-intermediate training covering:
- Session 1: Unit testing fundamentals with xUnit (AAA, Fact, Theory)
- Session 2: Test-Driven Development (Red-Green-Refactor, FIRST)
- Session 3: Test doubles, coverage with Coverlet, CI, anti-patterns

All factual claims verified against Microsoft Learn and xUnit official docs.
Includes program methodology brief and README.
"@

Write-Host "==> Committing" -ForegroundColor Cyan
git commit -m $commitMessage

# 5. Add the remote and push
Write-Host "==> Adding remote origin" -ForegroundColor Cyan
git remote remove origin 2>$null
git remote add origin $RepoUrl

Write-Host "==> Pushing to $RepoUrl" -ForegroundColor Cyan
git push -u origin main

Write-Host "==> Done. View at: https://github.com/Ketiv-Technologies-Inc/Training-Test-Driven-Development" -ForegroundColor Green
