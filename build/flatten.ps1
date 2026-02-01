param(
    [Parameter(Mandatory=$true)][string]$ProjectRoot,
    [Parameter(Mandatory=$true)][string]$BuildDir
)

# Paths
$outFile = Join-Path $BuildDir "menu_flat.gsc"
$menuFile = Join-Path $ProjectRoot "zm_tomb\menu.gsc"
$origins  = Join-Path $ProjectRoot "origins_menu"

if (Test-Path $outFile) { Remove-Item $outFile -Force }

$writer = [System.IO.StreamWriter]::new($outFile, $false, [System.Text.Encoding]::ASCII)

try {
    # menu
    $writer.WriteLine("// ===== BEGIN menu.gsc =====")
    Get-Content $menuFile | Where-Object { $_ -notmatch '^\s*#include\s+scripts\\zm\\origins_menu\\' } | ForEach-Object {
        $writer.WriteLine($_)
    }

    # utility + base
    foreach ($f in @("menu_utility.gsc","menu_base.gsc")) {
        $fp = Join-Path $origins $f
        if (Test-Path $fp) {
            $writer.WriteLine()
            $writer.WriteLine("// ===== BEGIN $f =====")
            Get-Content $fp | Where-Object { $_ -notmatch '^\s*#include\b' } | ForEach-Object { $writer.WriteLine($_) }
        }
    }

    # modes
    Get-ChildItem "$origins\*.gsc" |
        Where-Object { $_.Name -notin @("menu_utility.gsc","menu_base.gsc") } |
        Sort-Object Name |
        ForEach-Object {
            $writer.WriteLine()
            $writer.WriteLine("// ===== BEGIN $($_.Name) =====")
            Get-Content $_.FullName | Where-Object { $_ -notmatch '^\s*#include\b' } | ForEach-Object { $writer.WriteLine($_) }
        }
} finally {
    $writer.Close()
}

Write-Host "Flatten complete: $outFile"
