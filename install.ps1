# Saucebase bootstrap installer (Windows) — https://install.saucebase.dev
#
#   irm https://install.saucebase.dev/install.ps1 | iex
#
# Ensures PHP + Composer (via php.new), installs the global `saucebase` CLI,
# then runs `saucebase new`. The only global tools it touches are PHP and Composer.
#
# `iex` does not forward arguments, so run `saucebase new my-app` yourself after,
# or just let the CLI prompt for the project name.

$ErrorActionPreference = 'Stop'

# php.new one-liner kept in sync with the CLI's own prerequisite hints:
# packages/installer/src/Console/Commands/NewCommand.php -> displayPrerequisiteHints()

$hasPhp = Get-Command php -ErrorAction SilentlyContinue
$hasComposer = Get-Command composer -ErrorAction SilentlyContinue

if ($hasPhp -and $hasComposer) {
    Write-Host "PHP and Composer already present — skipping php.new."
} else {
    Write-Host "Installing PHP and Composer via php.new..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://php.new/install/windows'))

    # php.new edits the registry PATH; refresh this session so composer is found.
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + `
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

Write-Host "Installing the Saucebase CLI..."
composer global require saucebase/installer

# Make `saucebase` callable in this session.
$composerBin = composer global config bin-dir --absolute 2>$null
if ($composerBin) {
    $env:Path = "$composerBin;$env:Path"
}

saucebase new @args