param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile
)

# Split file name and extension
$directory = Split-Path $InputFile
$filename  = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$extension = [System.IO.Path]::GetExtension($InputFile)

# Build new file name with "_uniq"
$outputFile = Join-Path $directory "$filename`_uniq$extension"

# Sort unique and write output
Get-Content $InputFile | Sort-Object -Unique | Out-File $outputFile -Encoding utf8

Write-Host "Unique-sorted file saved to $outputFile"
