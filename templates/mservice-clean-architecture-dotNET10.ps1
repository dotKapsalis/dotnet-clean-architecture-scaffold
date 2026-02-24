[CmdletBinding(DefaultParameterSetName = 'Run', PositionalBinding=$false)]
param(
    [Parameter(ParameterSetName='Help')]
    [Alias('h')]
    [switch]$Help,

    [Parameter(ParameterSetName='Run', HelpMessage="Name of the solution (e.g. MyCompany.MyProduct)")]
    [ValidateNotNullOrEmpty()]
    [string]$SolutionName,

    [Parameter(ParameterSetName='Run', HelpMessage="Root directory where the Solution folder will be created")]
    [ValidateNotNullOrEmpty()]
    [string]$RootPath,

    [Parameter(ParameterSetName='Run', HelpMessage="Create SqlScripts folders")]
    [switch]$CreateDbFolders = $false
)

$ErrorActionPreference = "Stop"

function Show-Usage {
    Write-Host ""
    Write-Host "Usage: .\mservice-clean-architecture-dotnet10.ps1 -SolutionName <SolutionName> -RootPath <RootPath> [-CreateDbFolders]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Example: .\mservice-clean-architecture-dotnet10.ps1 -SolutionName 'MyCompany.MyProduct' -RootPath 'C:\my-repos' -CreateDbFolders:`$false" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -SolutionName: Name of the solution (e.g. MyCompany.MyProduct)" -ForegroundColor Yellow
    Write-Host "  -RootPath: Root directory where the solution folder will be created" -ForegroundColor Yellow
    Write-Host "  -CreateDbFolders: Optional switch to create SqlScripts folders" -ForegroundColor Yellow
    Write-Host "  -Help (-h): Display this help message" -ForegroundColor Yellow
}

function Copy-TemplateFileToDestinationDir {
    param(
        [Parameter(Mandatory)] [string] $FileName,
        [Parameter(Mandatory)] [string] $DestinationDir
    )

    $source = Join-Path -Path $PSScriptRoot -ChildPath "..\files\$FileName"
    $destination = Join-Path -Path $DestinationDir -ChildPath $FileName

    Write-Host "`nCopying $FileName to solution root $destination ..." -ForegroundColor Yellow

    # use -literalpath to avoid issues with special characters in paths, and check existence with Test-Path before copying
    if (Test-Path -LiteralPath $source) {
        Copy-Item -LiteralPath $source -Destination $destination -Force
        Write-Host "$FileName copied to solution root." -ForegroundColor Green
    }
    else {
        # show the full path without Resolve-Path (which would error when missing)
        $fullSource = [System.IO.Path]::GetFullPath($source)
        Write-Warning "$FileName not found at expected location: $fullSource"
    }
}


if ($Help -or $PSBoundParameters.Count -eq 0) { 
    Show-Usage
    exit 0
}
if (-not $SolutionName) { 
    Write-Host "SolutionName is required!!" -ForegroundColor Red
    Show-Usage
    exit 1
}
if (-not $RootPath) { 
    Write-Host "RootPath is required!!" -ForegroundColor Red
    Show-Usage
    exit 1
}

Write-Host "Validating inputs..."

# Validate RootPath exists and if not, ask the user if they want to create it
if (-not (Test-Path $RootPath)) {
    Write-Warning "RootPath '$RootPath' does not exist."
    $create = Read-Host "Do you want to create it? (Y/N)"
    if ($create -match '^[Yy]$') {
        try {
            New-Item -Path $RootPath -ItemType Directory -Force | Out-Null
            Write-Host "RootPath created successfully." -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to create RootPath. $_"
            exit 1
        }
    }
    else {
        Write-Error "RootPath is required. Exiting."
        exit 1
    }
}

# Repo root (solution directory)
$solutionDir = Join-Path $RootPath $SolutionName

# NEW: sln at repo root
$slnPath = Join-Path $solutionDir "$SolutionName.slnx"

# NEW: src + tests folders
$srcDir   = Join-Path $solutionDir "src"
$testsDir = Join-Path $solutionDir "tests"

Write-Host "`nCreating repo root..." -ForegroundColor Yellow
New-Item -Path $solutionDir -ItemType Directory -Force | Out-Null
New-Item -Path $srcDir -ItemType Directory -Force | Out-Null
New-Item -Path $testsDir -ItemType Directory -Force | Out-Null

Write-Host "`nCreating solution at repo root..." -ForegroundColor Yellow
dotnet new sln -n $SolutionName -o $solutionDir

Write-Host "`nCreating src projects..." -ForegroundColor Yellow
dotnet new classlib -n "$SolutionName.Application"    -o "$srcDir\$SolutionName.Application"    -f net10.0
dotnet new classlib -n "$SolutionName.Infrastructure" -o "$srcDir\$SolutionName.Infrastructure" -f net10.0
dotnet new classlib -n "$SolutionName.Contracts"      -o "$srcDir\$SolutionName.Contracts"      -f net10.0
dotnet new classlib -n "$SolutionName.Domain"         -o "$srcDir\$SolutionName.Domain"         -f net10.0
dotnet new webapi   -n "$SolutionName.API"            -o "$srcDir\$SolutionName.API"            -f net10.0 --no-https --use-controllers

Write-Host "`nCreating test projects..." -ForegroundColor Yellow
# Pick your preferred test template:
# - mstest (default): dotnet new mstest
# - xunit:           dotnet new xunit
# - nunit:           dotnet new nunit
dotnet new xunit -n "$SolutionName.Application.Tests"    -o "$testsDir\$SolutionName.Application.Tests"    -f net10.0
dotnet new xunit -n "$SolutionName.Infrastructure.Tests" -o "$testsDir\$SolutionName.Infrastructure.Tests" -f net10.0
dotnet new xunit -n "$SolutionName.Domain.Tests"         -o "$testsDir\$SolutionName.Domain.Tests"         -f net10.0
dotnet new xunit -n "$SolutionName.API.Tests"            -o "$testsDir\$SolutionName.API.Tests"            -f net10.0

Write-Host "`nAdding projects to solution..." -ForegroundColor Yellow
Get-ChildItem $solutionDir -Recurse -Filter *.csproj |
    ForEach-Object { dotnet sln $slnPath add $_.FullName }

Write-Host "`nAdding references..." -ForegroundColor Yellow
# src references
dotnet add "$srcDir\$SolutionName.API\$SolutionName.API.csproj" reference "$srcDir\$SolutionName.Infrastructure\$SolutionName.Infrastructure.csproj"
dotnet add "$srcDir\$SolutionName.Infrastructure\$SolutionName.Infrastructure.csproj" reference "$srcDir\$SolutionName.Application\$SolutionName.Application.csproj"
dotnet add "$srcDir\$SolutionName.Application\$SolutionName.Application.csproj" reference "$srcDir\$SolutionName.Domain\$SolutionName.Domain.csproj"
dotnet add "$srcDir\$SolutionName.Application\$SolutionName.Application.csproj" reference "$srcDir\$SolutionName.Contracts\$SolutionName.Contracts.csproj"

# test references (typical)
dotnet add "$testsDir\$SolutionName.Application.Tests\$SolutionName.Application.Tests.csproj" reference "$srcDir\$SolutionName.Application\$SolutionName.Application.csproj"
dotnet add "$testsDir\$SolutionName.Infrastructure.Tests\$SolutionName.Infrastructure.Tests.csproj" reference "$srcDir\$SolutionName.Infrastructure\$SolutionName.Infrastructure.csproj"
dotnet add "$testsDir\$SolutionName.Domain.Tests\$SolutionName.Domain.Tests.csproj" reference "$srcDir\$SolutionName.Domain\$SolutionName.Domain.csproj"
dotnet add "$testsDir\$SolutionName.Domain.Tests\$SolutionName.Domain.Tests.csproj" reference "$srcDir\$SolutionName.Contracts\$SolutionName.Contracts.csproj"
dotnet add "$testsDir\$SolutionName.API.Tests\$SolutionName.API.Tests.csproj" reference "$srcDir\$SolutionName.API\$SolutionName.API.csproj"

# Check if the CreateDbFolders parameter was provided, if not ask the user
if (-not $PSBoundParameters.ContainsKey("CreateDbFolders")) {
    Write-Host "`n"
    $answer = Read-Host "Create folder for the database pipelines? (y/n)"
    if ($answer -match "^[Yy]") { 
        $CreateDbFolders = $true 
    }
}
if ($CreateDbFolders) {
    Write-Host "`nCreating database pipeline folders..." -ForegroundColor Yellow
    $sqlPath = Join-Path $solutionDir "SqlScripts\PostDeployment"
    New-Item -ItemType Directory -Force -Path $sqlPath | Out-Null
    New-Item -ItemType File -Path (Join-Path $sqlPath "EnsureErrorCodes.sql") | Out-Null
    Write-Host "Database pipeline folders created." -ForegroundColor Green
}

# Copy files to solution root
Copy-TemplateFileToDestinationDir -FileName ".editorconfig" -DestinationDir $solutionDir
Copy-TemplateFileToDestinationDir -FileName ".gitattributes" -DestinationDir $solutionDir
Copy-TemplateFileToDestinationDir -FileName ".gitignore" -DestinationDir $solutionDir


Write-Host "`nProcess completed!`n" -ForegroundColor Green
