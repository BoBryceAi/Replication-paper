[CmdletBinding()]
param(
    [string]$Date = (Get-Date -Format "yyyy-MM-dd")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    Split-Path -Parent $PSScriptRoot
}

function Get-WorkspaceRoot {
    $repoRoot = Get-RepoRoot
    Split-Path -Parent (Split-Path -Parent $repoRoot)
}

function Get-Tokens {
    param(
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return @()
    }

    return ($Text.ToLowerInvariant() -split '[^a-z0-9]+') | Where-Object { $_ } | Select-Object -Unique
}

function Get-OverlapScore {
    param(
        [string[]]$Left,
        [string[]]$Right
    )

    $score = 0
    foreach ($token in $Left) {
        if ($Right -contains $token) {
            $score++
        }
    }

    return $score
}

function Resolve-TargetPdfName {
    param(
        [string]$Slug,
        [System.IO.DirectoryInfo]$TargetDirectory,
        [System.Collections.Generic.HashSet[string]]$UsedTargetNames
    )

    $existingPdfs = @(Get-ChildItem -Path $TargetDirectory.FullName -File -Filter *.pdf | Sort-Object Name)
    $exactName = "{0}.pdf" -f $Slug
    if ($UsedTargetNames -and $UsedTargetNames.Contains($exactName)) {
        return $exactName
    }

    if ($existingPdfs.Count -eq 0) {
        return $exactName
    }

    $existingNames = @($existingPdfs | ForEach-Object { $_.Name })
    if ($existingNames -contains $exactName) {
        return $exactName
    }

    $slugTokens = Get-Tokens $Slug
    $bestMatch = $null
    $bestScore = -1

    foreach ($pdf in $existingPdfs) {
        if ($UsedTargetNames -and $UsedTargetNames.Contains($pdf.Name)) {
            continue
        }

        $score = Get-OverlapScore -Left $slugTokens -Right (Get-Tokens $pdf.BaseName)
        if ($score -gt $bestScore) {
            $bestScore = $score
            $bestMatch = $pdf
        }
    }

    if ($bestScore -ge 2 -and $bestMatch) {
        return $bestMatch.Name
    }

    return $exactName
}

$repoRoot = Get-RepoRoot
$workspaceRoot = Get-WorkspaceRoot
$batchRoot = Join-Path $workspaceRoot "patent literature\daily_replications\$Date"
$targetRoot = Join-Path $repoRoot "papers\$Date"
$siteUpdateScript = Join-Path $PSScriptRoot "update-site.ps1"

if (-not (Test-Path $batchRoot)) {
    throw "Could not find batch directory: $batchRoot"
}

New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
$targetDirectory = Get-Item -LiteralPath $targetRoot
$usedTargetNames = New-Object 'System.Collections.Generic.HashSet[string]'

$summaryCsv = Join-Path $batchRoot "calculated_batch_summary.csv"
if (Test-Path $summaryCsv) {
    $slugs = @(Import-Csv -LiteralPath $summaryCsv | ForEach-Object { $_.slug } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $paperDirectories = @()
    foreach ($slug in $slugs) {
        $target = Join-Path $batchRoot $slug
        if (Test-Path (Join-Path $target "paper\main.pdf")) {
            $paperDirectories += Get-Item -LiteralPath $target
        }
    }
}
else {
    $paperDirectories = @(Get-ChildItem -Path $batchRoot -Directory | Sort-Object Name | Where-Object {
        Test-Path (Join-Path $_.FullName "paper\main.pdf")
    })
}

if ($paperDirectories.Count -eq 0) {
    throw "No compiled paper/main.pdf files were found in $batchRoot"
}

foreach ($paperDirectory in $paperDirectories) {
    $sourcePdf = Join-Path $paperDirectory.FullName "paper\main.pdf"
    $targetName = Resolve-TargetPdfName -Slug $paperDirectory.Name -TargetDirectory $targetDirectory -UsedTargetNames $usedTargetNames
    $targetPdf = Join-Path $targetRoot $targetName
    Copy-Item -LiteralPath $sourcePdf -Destination $targetPdf -Force
    [void]$usedTargetNames.Add($targetName)
    Write-Host ("Published {0} -> {1}" -f $paperDirectory.Name, $targetName)
}

& $siteUpdateScript

Write-Host ("Finished publishing batch {0}." -f $Date)
