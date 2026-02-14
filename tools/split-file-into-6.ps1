# SplitInto6Parts-Safe.ps1
param(
    [string]$InputFile = "F:\pwnedpasswords_ntlm.txt",
    [int]$Parts = 6,
    [string]$OutDirectory = "F:\",
    [string]$OutPrefix = "output_part_",
    [string]$OutExtension = ".txt"
)

# --- Verify input file exists ---
if (-not (Test-Path $InputFile)) {
    Write-Error "Input file not found: $InputFile"
    exit 1
}

# --- Verify or create output directory ---
if (-not (Test-Path $OutDirectory)) {
    Write-Host "Output directory does not exist; creating: $OutDirectory"
    New-Item -ItemType Directory -Path $OutDirectory | Out-Null
}

# Normalize trailing backslash
if ($OutDirectory[-1] -ne "\") {
    $OutDirectory += "\"
}

# --- PASS 1: Count total lines safely ---
Write-Host "Counting lines (streaming)..."
$lineCount = 0
$fsCount = [System.IO.File]::Open($InputFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
try {
    $readerCount = New-Object System.IO.StreamReader($fsCount, [System.Text.Encoding]::ASCII, $true, 65536)
    try {
        while ($null -ne $readerCount.ReadLine()) {
            $lineCount++
            if (($lineCount % 10000000) -eq 0) {
                Write-Host "Counted $lineCount lines..."
            }
        }
    } finally {
        $readerCount.Close()
    }
} finally {
    $fsCount.Close()
}

if ($lineCount -eq 0) {
    Write-Error "Input file is empty."
    exit 1
}

$linesPerFile = [Math]::Ceiling($lineCount / $Parts)
Write-Host "Total lines: $lineCount"
Write-Host "Each file will contain about $linesPerFile lines"

# --- PASS 2: Split into parts ---
$fsRead = [System.IO.File]::Open($InputFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
try {
    $reader = New-Object System.IO.StreamReader($fsRead, [System.Text.Encoding]::ASCII, $true, 65536)
    try {
        $partIndex = 1
        $linesWritten = 0
        $outFile = "$OutDirectory$OutPrefix$partIndex$OutExtension"
        $writer = New-Object System.IO.StreamWriter($outFile, $false, [System.Text.Encoding]::ASCII, 65536)
        try {
            while ($null -ne ($line = $reader.ReadLine())) {
                $writer.WriteLine($line)
                $linesWritten++

                if ($linesWritten -ge $linesPerFile -and $partIndex -lt $Parts) {
                    $writer.Close()
                    Write-Host "Created $outFile ($linesWritten lines)"

                    $partIndex++
                    $linesWritten = 0
                    $outFile = "$OutDirectory$OutPrefix$partIndex$OutExtension"
                    $writer = New-Object System.IO.StreamWriter($outFile, $false, [System.Text.Encoding]::ASCII, 65536)
                }
            }
        } finally {
            $writer.Close()
            Write-Host "Created $outFile ($linesWritten lines)"
        }
    } finally {
        $reader.Close()
    }
} finally {
    $fsRead.Close()
}

Write-Host "Done — split $InputFile into $partIndex parts."
