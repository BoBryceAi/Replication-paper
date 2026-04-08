[CmdletBinding()]
param()

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

function Find-BestPdfMatch {
    param(
        [pscustomobject]$Row,
        [System.IO.FileInfo[]]$PdfFiles,
        [System.Collections.Generic.HashSet[string]]$UsedNames
    )

    $exactMatch = $PdfFiles | Where-Object {
        -not $UsedNames.Contains($_.Name) -and $_.BaseName -eq $Row.slug
    } | Select-Object -First 1

    if ($exactMatch) {
        return $exactMatch
    }

    $candidateTokens = Get-Tokens ("{0} {1}" -f $Row.slug, $Row.paper)
    $bestMatch = $null
    $bestScore = -1

    foreach ($pdf in $PdfFiles) {
        if ($UsedNames.Contains($pdf.Name)) {
            continue
        }

        $score = Get-OverlapScore -Left $candidateTokens -Right (Get-Tokens $pdf.BaseName)
        if ($score -gt $bestScore) {
            $bestScore = $score
            $bestMatch = $pdf
        }
    }

    if ($bestScore -ge 2) {
        return $bestMatch
    }

    $remaining = @($PdfFiles | Where-Object { -not $UsedNames.Contains($_.Name) })
    if ($remaining.Count -eq 1) {
        return $remaining[0]
    }

    return $null
}

function Format-SizeLabel {
    param(
        [long]$Bytes
    )

    if ($Bytes -ge 1MB) {
        return "{0:N1} MB" -f ($Bytes / 1MB)
    }

    return "{0:N0} KB" -f ($Bytes / 1KB)
}

function Convert-ToDateLabel {
    param(
        [string]$DateText
    )

    try {
        $dateValue = [datetime]::ParseExact($DateText, "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture)
        return $dateValue.ToString("MMMM d, yyyy", [System.Globalization.CultureInfo]::InvariantCulture)
    }
    catch {
        return $DateText
    }
}

function Get-DoubleOrNull {
    param(
        [object]$Value
    )

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return $null
    }

    return [double]$Value
}

function Get-IntOrNull {
    param(
        [object]$Value
    )

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return $null
    }

    return [int64]$Value
}

function Write-TextFile {
    param(
        [string]$Path,
        [string[]]$Lines
    )

    $parent = Split-Path -Parent $Path
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    [System.IO.File]::WriteAllLines($Path, $Lines, [System.Text.UTF8Encoding]::new($false))
}

function Format-HeadlineForReadme {
    param(
        [object]$Estimate,
        [object]$PValue,
        [string]$Term
    )

    if ($null -eq $Estimate) {
        return "PDF published"
    }

    $estimateValue = [double]$Estimate
    $pValue = [double]$PValue

    if ($pValue -lt 0.001) {
        $pText = "< .001"
    }
    elseif ($pValue -lt 0.1) {
        $pText = "{0:N3}" -f $pValue
    }
    else {
        $pText = "{0:N2}" -f $pValue
    }

    return ('`{0} = {1}`; `p = {2}`' -f $Term, [math]::Round($estimateValue, 4), $pText)
}

$repoRoot = Get-RepoRoot
$workspaceRoot = Get-WorkspaceRoot
$publishPapersRoot = Join-Path $repoRoot "papers"
$dailyReplicationRoot = Join-Path $workspaceRoot "patent literature\daily_replications"
$siteDataPath = Join-Path $repoRoot "assets\data\library.json"
$readmePath = Join-Path $repoRoot "README.md"
$repoUrl = "https://github.com/BoBryceAi/Replication-paper"
$siteUrl = "https://bobryceai.github.io/Replication-paper/"

$batchDirectories = @(Get-ChildItem -Path $publishPapersRoot -Directory | Sort-Object Name -Descending)
$batchObjects = @()

foreach ($batchDir in $batchDirectories) {
    $pdfFiles = @(Get-ChildItem -Path $batchDir.FullName -File -Filter *.pdf | Sort-Object Name)
    if ($pdfFiles.Count -eq 0) {
        continue
    }

    $summaryCsv = Join-Path $dailyReplicationRoot (Join-Path $batchDir.Name "calculated_batch_summary.csv")
    $summaryRows = @()
    if (Test-Path $summaryCsv) {
        $summaryRows = @(Import-Csv -LiteralPath $summaryCsv)
    }

    $usedNames = New-Object 'System.Collections.Generic.HashSet[string]'
    $paperObjects = @()

    foreach ($row in $summaryRows) {
        $match = Find-BestPdfMatch -Row $row -PdfFiles $pdfFiles -UsedNames $usedNames
        if ($match) {
            [void]$usedNames.Add($match.Name)
        }

        $paperObject = [ordered]@{
            slug = [string]$row.slug
            title = [string]$row.paper
            date = $batchDir.Name
            pdfName = if ($match) { $match.Name } else { $null }
            pdfUrl = if ($match) { ("papers/{0}/{1}" -f $batchDir.Name, $match.Name).Replace("\", "/") } else { $null }
            rows = Get-IntOrNull -Value $row.rows
            entities = Get-IntOrNull -Value $row.unique_entities
            headlineTerm = [string]$row.headline_term
            headlineEstimate = Get-DoubleOrNull -Value $row.headline_estimate
            headlineP = Get-DoubleOrNull -Value $row.headline_p
            pdfSizeBytes = if ($match) { [int64]$match.Length } else { $null }
            pdfSizeLabel = if ($match) { Format-SizeLabel -Bytes $match.Length } else { $null }
        }

        $paperObjects += [pscustomobject]$paperObject
    }

    foreach ($pdf in ($pdfFiles | Where-Object { -not $usedNames.Contains($_.Name) })) {
        $paperObjects += [pscustomobject]([ordered]@{
            slug = $pdf.BaseName
            title = ($pdf.BaseName -replace '-', ' ')
            date = $batchDir.Name
            pdfName = $pdf.Name
            pdfUrl = ("papers/{0}/{1}" -f $batchDir.Name, $pdf.Name).Replace("\", "/")
            rows = $null
            entities = $null
            headlineTerm = "PDF available"
            headlineEstimate = $null
            headlineP = $null
            pdfSizeBytes = [int64]$pdf.Length
            pdfSizeLabel = Format-SizeLabel -Bytes $pdf.Length
        })
    }

    $rowTotal = [int64](($paperObjects | Where-Object { $null -ne $_.rows } | Measure-Object -Property rows -Sum).Sum)
    $entityTotal = [int64](($paperObjects | Where-Object { $null -ne $_.entities } | Measure-Object -Property entities -Sum).Sum)
    $pdfTotal = [int64](($paperObjects | Where-Object { $null -ne $_.pdfSizeBytes } | Measure-Object -Property pdfSizeBytes -Sum).Sum)
    $significantCount = @($paperObjects | Where-Object { $null -ne $_.headlineP -and $_.headlineP -lt 0.05 }).Count

    $batchObjects += [pscustomobject]([ordered]@{
        date = $batchDir.Name
        dateLabel = Convert-ToDateLabel -DateText $batchDir.Name
        paperCount = $paperObjects.Count
        totalRows = $rowTotal
        totalEntitiesReported = $entityTotal
        totalPdfBytes = $pdfTotal
        totalPdfBytesMb = [math]::Round(($pdfTotal / 1MB), 2)
        significantCount = $significantCount
        papers = @($paperObjects)
    })
}

$latestBatch = $batchObjects | Select-Object -First 1
$generatedAt = (Get-Date).ToUniversalTime()
$summaryObject = [ordered]@{
    totalPapers = @($batchObjects | ForEach-Object { $_.paperCount } | Measure-Object -Sum).Sum
    totalBatches = $batchObjects.Count
    totalRows = @($batchObjects | ForEach-Object { $_.totalRows } | Measure-Object -Sum).Sum
    significantHeadlines = @($batchObjects | ForEach-Object { $_.significantCount } | Measure-Object -Sum).Sum
    totalPdfBytes = @($batchObjects | ForEach-Object { $_.totalPdfBytes } | Measure-Object -Sum).Sum
    generatedAtUtc = $generatedAt.ToString("yyyy-MM-ddTHH:mm:ssZ")
    generatedAtLabel = $generatedAt.ToString("MMMM d, yyyy 'at' HH:mm 'UTC'", [System.Globalization.CultureInfo]::InvariantCulture)
    latestBatchDate = if ($latestBatch) { $latestBatch.date } else { $null }
    latestBatchLabel = if ($latestBatch) { $latestBatch.dateLabel } else { "No batch yet" }
}

$siteObject = [ordered]@{
    site = [ordered]@{
        title = "Can AI Do Strategy Replication?"
        subtitle = "A live archive of AI-assisted, data-backed replication papers in strategy and innovation research."
        repoUrl = $repoUrl
        pagesUrl = $siteUrl
    }
    summary = $summaryObject
    batches = @($batchObjects)
}

Write-TextFile -Path $siteDataPath -Lines @((ConvertTo-Json -Depth 8 -InputObject $siteObject))

$readmeLines = @(
    "# Can AI Do Strategy Replication?",
    "",
    ("Live site: <{0}>" -f $siteUrl),
    "",
    ("Repository: <{0}>" -f $repoUrl),
    "",
    "This repository is the public website and PDF archive for AI-assisted strategy replication papers generated from the local calculated-replication workflow.",
    "",
    "## What the site publishes",
    "",
    "- formal journal-style replication PDFs",
    "- batch-level paper library metadata",
    "- a GitHub Pages front end that refreshes when new batches are published",
    "",
    "## Current site totals",
    "",
    ("- published papers: {0}" -f $summaryObject.totalPapers),
    ("- published batches: {0}" -f $summaryObject.totalBatches),
    ("- analyzed rows across batches: {0:N0}" -f $summaryObject.totalRows),
    ("- headline estimates with p " + "< .05: " + $summaryObject.significantHeadlines),
    ("- latest batch: {0}" -f $summaryObject.latestBatchLabel),
    "",
    "## Latest batch"
)

if ($latestBatch) {
    $readmeLines += ""
    foreach ($paper in $latestBatch.papers) {
        $headlinePart = Format-HeadlineForReadme -Estimate $paper.headlineEstimate -PValue $paper.headlineP -Term $paper.headlineTerm
        $rowLabel = if ($null -ne $paper.rows) { "{0:N0}" -f $paper.rows } else { "NA" }
        $entityLabel = if ($null -ne $paper.entities) { "{0:N0}" -f $paper.entities } else { "NA" }
        $readmeLines += "- [{0}]({1}) - rows: {2}, entities: {3}, {4}" -f $paper.title, $paper.pdfUrl, $rowLabel, $entityLabel, $headlinePart
    }
}
else {
    $readmeLines += "", "- No published batch has been detected yet."
}

$readmeLines += @(
    "",
    "## Local refresh tools",
    "",
    ('- ' + [char]96 + 'tools/publish-batch.ps1' + [char]96 + ' copies compiled PDFs from the workspace into this repository and then refreshes the website.'),
    ('- ' + [char]96 + 'tools/update-site.ps1' + [char]96 + ' rebuilds ' + [char]96 + 'assets/data/library.json' + [char]96 + ' and ' + [char]96 + 'README.md' + [char]96 + ' from the current published batches.'),
    "",
    "## Workflow skill",
    "",
    "- The publishing and manuscript standard is documented at [skills/write-replication-journal-github/SKILL.md](skills/write-replication-journal-github/SKILL.md).",
    "",
    "## Workflow and skill stack",
    "",
    "- Manuscript production follows a paper-first replication process that reads the source paper, maps every major decision point, checks the exact processed local files, and writes the article only after the evidence chain is explicit.",
    "- Every paper must reconstruct the original article's published methodology before interpreting the local rerun, including the original sample, measurement architecture, estimator, and identifying comparison.",
    "- Every paper must name the actual processed local dataset families used in the replication body, such as DISCERN-linked firm panels, PatentView-style patent files, rolling citation-link networks, and CRSP or Compustat-linked controls when those are part of the executable stack.",
    "- Every paper must include a detailed original-versus-replication comparison section covering methodology, data architecture, focal estimated effects, substantive interpretation, and final conclusion rather than only a headline coefficient check.",
    "- The public archive is refreshed when the workflow standard changes, so older published batches can be rewritten to match the current paper standard rather than freezing earlier weaker templates.",
    "- The core GitHub skill is `write-replication-journal-github`, supported by `dgm-method-design`, `dgm-research-positioning`, `citation-management`, `literature-review`, and `peer-review` for stronger structure, citation density, and final manuscript polish."
)

Write-TextFile -Path $readmePath -Lines $readmeLines
Write-Host ("Updated site data for {0} published batch(es)." -f $summaryObject.totalBatches)
