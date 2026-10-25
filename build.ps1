<#
Builds the practice tool for every map (Origins and Mob of the Dead). Run it
through build_single.bat:

    build_single.bat           Release: build, then install one compiled script per map.
    build_single.bat -Source   Development: build, then install the plain source files
                               instead; Plutonium compiles them, so edits only need a
                               map restart.
    build_single.bat -Check    Build into build\ only. Does not touch the game.
    add -Map origins|mob       Only that map (default: every map).
    add -Tools                 Also compile every tools\*.gsc (and install it, unless -Check).

Needs gsc-tool (https://github.com/xensik/gsc-tool/releases, tested with
1.5.1.359) at bin\gsc-tool.exe.

Each map has an entry script in its map folder, so Plutonium only loads it on that
map, named for the tool it starts: scripts\zm\zm_tomb\o-prac-menu.gsc (Origins) and
scripts\zm\zm_prison\m-prac-menu.gsc (Mob). Release and source installs use the same
entry path, so one replaces the other. The previous entry script is backed up to
build\<map>\previous-<entry>.gsc. Installing also moves an older entry named
menu.gsc out of the map folder (to build\<map>\previous-menu.gsc); left there, it
would load a second menu.

The sources are laid out like the install:
  - practice_core\  the menu engine, settings, modes and HUDs every map shares. It
                    never names map code; maps hand it function pointers.
  - origins_menu\   Origins code and modes; oprac.gsh holds its #defines.
  - mob_menu\       Mob of the Dead code and modes; mob.gsh holds its #defines.
A map's entry includes the core and its own folder. Every build checks both forms:
  - Source: every file compiles on its own (from a copy of the install tree in
    build\<map>\source\), and includes each project file whose functions it calls.
    The core may not include a map folder or name maps\mp\zm_* scripts, and a map
    folder may not include another map's folder.
  - Release: the map's files are joined into build\<map>\menu_flat.gsc and compiled
    to one script. Project #includes and #inlines become blank lines (so compile
    errors keep their file and line), the vanilla #includes of every file are
    collected at the top, and the shared headers go in once.
#>
param(
    [switch]$Check,
    [switch]$Source,
    [switch]$Tools,
    [ValidateSet("origins", "mob")]
    [string]$Map
)
$Deploy = -not $Check

$ErrorActionPreference = "Stop"
# Any failure: print one line instead of a PowerShell stack trace.
trap { Write-Host "BUILD FAILED: $_" -ForegroundColor Red; exit 1 }

$Root       = $PSScriptRoot
$BuildDir   = Join-Path $Root "build"
$GscTool    = Join-Path $Root "bin\gsc-tool.exe"
$ScriptsDir = Join-Path $env:LOCALAPPDATA "Plutonium\storage\t6\scripts\zm"
$Core       = "practice_core"

# Every map: its entry folder (the game's map name), entry script and code folder.
$Maps = @(
    [pscustomobject]@{ Name = "origins"; Entry = "zm_tomb";   EntryFile = "o-prac-menu.gsc"; Folder = "origins_menu" },
    [pscustomobject]@{ Name = "mob";     Entry = "zm_prison"; EntryFile = "m-prac-menu.gsc"; Folder = "mob_menu" }
)
$MapFolders = $Maps | ForEach-Object { $_.Folder }

# A map's sources, in release join order: entry script, core utilities, the rest
# of the core, then the map folder, each alphabetically.
function Get-MenuSources($MapInfo) {
    $first = @("menu_utility.gsc", "menu_base.gsc")
    $coreDir = Join-Path $Root $Core
    $coreRest = Get-ChildItem $coreDir -Filter *.gsc | Where-Object { $first -notcontains $_.Name } | Sort-Object Name
    $files = @(Join-Path $Root "$($MapInfo.Entry)\$($MapInfo.EntryFile)")
    $files += $first | ForEach-Object { Join-Path $coreDir $_ }
    $files += $coreRest | ForEach-Object { $_.FullName }
    $files += Get-ChildItem (Join-Path $Root $MapInfo.Folder) -Filter *.gsc | Sort-Object Name | ForEach-Object { $_.FullName }
    return $files
}

function Get-RelativePath($File) { return $File.Substring($Root.Length + 1) }

# "origins_menu\fullgame" for a source file.
function Get-ProjectName($File) {
    $relative = Get-RelativePath $File
    return [IO.Path]::ChangeExtension($relative, $null).TrimEnd('.')
}

function Assert-Ascii($File, $Lines) {
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '[^\x00-\x7F]') { throw "$(Get-RelativePath $File):$($i + 1): non-ASCII character." }
    }
}

# Code with comments removed and strings emptied, for finding names.
function Get-Code($File) {
    $text = [IO.File]::ReadAllText($File)
    return [regex]::Replace($text, '"(?:\\.|[^"\\])*"|//[^\r\n]*|/\*[\s\S]*?\*/', { param($m) if ($m.Value.StartsWith('"')) { '""' } else { '' } })
}

# Every file must #include the project files whose functions it calls; Plutonium
# compiles each source file on its own.
function Test-ProjectIncludes($Files) {
    $owner = @{}
    $code = @{}
    foreach ($file in $Files) {
        $code[$file] = Get-Code $file
        foreach ($m in [regex]::Matches($code[$file], '(?m)^([A-Za-z_]\w*)\s*\([^;{]*\)\s*$')) {
            $name = $m.Groups[1].Value
            if ($owner.ContainsKey($name) -and $owner[$name] -ne $file) {
                throw "$name() is defined in both $(Get-RelativePath $owner[$name]) and $(Get-RelativePath $file)."
            }
            $owner[$name] = $file
        }
    }
    $problems = @()
    foreach ($file in $Files) {
        $included = @{}
        foreach ($m in [regex]::Matches([IO.File]::ReadAllText($file), '(?m)^\s*#include\s+scripts\\zm\\(\w+\\\w+)\s*;')) { $included[$m.Groups[1].Value] = 1 }
        # Calls with a path (maps\...::name) name their own script.
        $plain = [regex]::Replace($code[$file], '[\w\\]+::\w+', '')
        $reported = @{}
        foreach ($m in [regex]::Matches($plain, '::(\w+)|\b(\w+)\s*\(')) {
            $name = if ($m.Groups[1].Success) { $m.Groups[1].Value } else { $m.Groups[2].Value }
            if (-not $owner.ContainsKey($name) -or $owner[$name] -eq $file) { continue }
            $target = Get-ProjectName $owner[$name]
            if (-not $included.ContainsKey($target) -and -not $reported.ContainsKey($target)) {
                $reported[$target] = 1
                $problems += "$(Get-RelativePath $file) calls $name() but does not #include scripts\zm\$target"
            }
        }
    }
    if ($problems.Count) {
        $problems | ForEach-Object { Write-Host "ERROR $_" }
        throw "missing project #includes."
    }
}

# Core never refers to a map; a map never includes another map's folder.
function Test-Dependencies($Files, $MapInfo) {
    $problems = @()
    foreach ($file in $Files) {
        $relative = Get-RelativePath $file
        $text = Get-Code $file
        $isCore = $relative.StartsWith("$Core\")
        foreach ($m in [regex]::Matches([IO.File]::ReadAllText($file), '(?m)^\s*#(?:include|inline)\s+scripts\\zm\\(\w+)\\')) {
            $folder = $m.Groups[1].Value
            if ($isCore -and $folder -ne $Core) { $problems += "$relative (core) includes the map folder $folder" }
            elseif (-not $isCore -and $MapFolders -contains $folder -and $folder -ne $MapInfo.Folder) { $problems += "$relative includes another map's folder $folder" }
        }
        if ($isCore -and $text -match 'maps\\mp\\zm_\w+') { $problems += "$relative (core) names the map script $($Matches[0])" }
    }
    if ($problems.Count) {
        $problems | ForEach-Object { Write-Host "ERROR $_" }
        throw "dependency rule broken."
    }
}

# Copies a map's sources into $Dir laid out like Plutonium's storage\t6 folder.
function Copy-SourceTree($Dir, $MapInfo) {
    if (Test-Path $Dir) { Remove-Item -Recurse -Force $Dir }
    $zm = Join-Path $Dir "scripts\zm"
    foreach ($folder in @($MapInfo.Entry, $Core, $MapInfo.Folder)) {
        $target = Join-Path $zm $folder
        New-Item -ItemType Directory -Force $target | Out-Null
        Get-ChildItem (Join-Path $Root $folder) -File | Where-Object { $_.Extension -eq ".gsc" -or $_.Extension -eq ".gsh" } | Copy-Item -Destination $target
    }
}

# Joins the sources into $OutFile and returns where each one starts in it.
function Join-Sources($Files, $OutFile, $MapInfo) {
    $includes = New-Object System.Collections.Generic.List[string]
    $headers = New-Object System.Collections.Generic.List[string]
    $sections = @()
    foreach ($file in $Files) {
        $lines = @(Get-Content $file)
        Assert-Ascii $file $lines
        $body = New-Object System.Collections.Generic.List[string]
        foreach ($line in $lines) {
            if ($line -match '^\s*#include\s+(\S+?)\s*;') {
                # Project files are all in the joined file; vanilla ones go to the top.
                $path = $Matches[1]
                if ($path -notlike 'scripts\zm\*' -and -not $includes.Contains($path)) { $includes.Add($path) }
                $line = ""
            }
            elseif ($line -match '^\s*#inline\s+scripts\\zm\\(\w+\\\w+)\s*;') {
                # Project headers go in once, at the top.
                if (-not $headers.Contains($Matches[1])) { $headers.Add($Matches[1]) }
                $line = ""
            }
            $body.Add($line)
        }
        $sections += [pscustomobject]@{ File = (Get-RelativePath $file); Lines = $body }
    }

    $out = New-Object System.Collections.Generic.List[string]
    $out.Add("// Generated by build.ps1 from $($MapInfo.Entry)\$($MapInfo.EntryFile),$Core\ and $($MapInfo.Folder)\. Do not edit.")
    foreach ($path in $includes) { $out.Add("#include $path;") }
    foreach ($header in $headers) {
        $headerFile = Join-Path $Root "$header.gsh"
        $lines = @(Get-Content $headerFile)
        Assert-Ascii $headerFile $lines
        $out.Add("")
        $out.Add("// ===== $header.gsh =====")
        $out.AddRange([string[]]$lines)
    }
    $map = @()
    foreach ($section in $sections) {
        $out.Add("")
        $out.Add("// ===== $($section.File) =====")
        $map += [pscustomobject]@{ File = $section.File; Start = $out.Count + 1; Count = $section.Lines.Count }
        $out.AddRange($section.Lines)
    }
    [IO.File]::WriteAllLines($OutFile, $out, [Text.Encoding]::ASCII)
    return $map
}

# "origins_menu\windstart.gsc:120" for a line of the joined file.
function Find-Source($Map, $FlatLine, $FlatName) {
    foreach ($entry in $Map) {
        if ($FlatLine -ge $entry.Start -and $FlatLine -lt $entry.Start + $entry.Count) {
            return "$($entry.File):$($FlatLine - $entry.Start + 1)"
        }
    }
    return "$($FlatName):$FlatLine"
}

# Compiles $File (a path relative to $Folder) from inside $Folder and returns the
# compiled file. With a $Map, errors name the original source file and line.
function Invoke-GscTool($Folder, $File, $Map) {
    Push-Location $Folder
    $ErrorActionPreference = "Continue"
    $output = & $GscTool --mode comp --game t6 --system pc $File 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = "Stop"
    Pop-Location

    foreach ($item in $output) {
        $text = "$item"
        if ($text -notmatch '^\[ERROR\]') { continue }
        if ($Map -and $text -match '^\[ERROR\]:\w+:[^:]+:(\d+):(\d+): (.*)$') {
            $text = "ERROR " + (Find-Source $Map ([int]$Matches[1]) (Join-Path $Folder $File)) + ":$($Matches[2]): $($Matches[3])"
        }
        Write-Host $text
    }
    if ($code -ne 0) { throw "gsc-tool could not compile $File." }
    return Join-Path $Folder ("compiled\t6\" + (Split-Path $File -Leaf))
}

function Install-File($From, $To) {
    New-Item -ItemType Directory -Force (Split-Path $To) | Out-Null
    Copy-Item $From $To -Force
}

if (-not (Test-Path $GscTool)) { throw "gsc-tool not found at $GscTool. See the top of build.ps1." }
New-Item -ItemType Directory -Force $BuildDir | Out-Null
$selected = $Maps | Where-Object { -not $Map -or $_.Name -eq $Map }

foreach ($mapInfo in $selected) {
    $mapBuild = Join-Path $BuildDir $mapInfo.Name
    New-Item -ItemType Directory -Force $mapBuild | Out-Null
    $files = Get-MenuSources $mapInfo

    # Source form: dependency and include checks, then every file on its own.
    Test-Dependencies $files $mapInfo
    Test-ProjectIncludes $files
    $sourceDir = Join-Path $mapBuild "source"
    Copy-SourceTree $sourceDir $mapInfo
    foreach ($file in $files) {
        $relative = "scripts\zm\" + (Get-RelativePath $file)
        Invoke-GscTool $sourceDir $relative $null | Out-Null
    }
    Write-Host "[$($mapInfo.Name)] Checked $($files.Count) source files"

    # Release form: one script.
    $flat = Join-Path $mapBuild $mapInfo.EntryFile
    $joinMap = Join-Sources $files $flat $mapInfo
    $compiled = Invoke-GscTool $mapBuild $mapInfo.EntryFile $joinMap
    Write-Host "[$($mapInfo.Name)] Built $compiled"

    if ($Deploy) {
        $entryName = "$($mapInfo.Entry)\$($mapInfo.EntryFile)"
        $entry = Join-Path $ScriptsDir $entryName
        if (Test-Path $entry) {
            Copy-Item $entry (Join-Path $mapBuild "previous-$($mapInfo.EntryFile)") -Force
            Write-Host "[$($mapInfo.Name)] Backed up the installed $entryName to build\$($mapInfo.Name)\previous-$($mapInfo.EntryFile)"
        }
        # Builds before 2026-10-13 named the entry menu.gsc; both would load.
        $oldMapEntry = Join-Path $ScriptsDir "$($mapInfo.Entry)\menu.gsc"
        if (Test-Path $oldMapEntry) {
            Move-Item $oldMapEntry (Join-Path $mapBuild "previous-menu.gsc") -Force
            Write-Host "[$($mapInfo.Name)] Moved the old $($mapInfo.Entry)\menu.gsc to build\$($mapInfo.Name)\previous-menu.gsc"
        }
        if ($Source) {
            # Replace the whole source folders, so deleted files do not linger.
            foreach ($folder in @($Core, $mapInfo.Folder)) {
                $installed = Join-Path $ScriptsDir $folder
                if (Test-Path $installed) { Remove-Item -Recurse -Force $installed }
                Copy-Item (Join-Path $sourceDir "scripts\zm\$folder") $ScriptsDir -Recurse
            }
            Install-File (Join-Path $sourceDir "scripts\zm\$entryName") $entry
            Write-Host "[$($mapInfo.Name)] Installed the source files in $ScriptsDir ($entryName,$Core\, $($mapInfo.Folder)\)"
        }
        else {
            Install-File $compiled $entry
            Write-Host "[$($mapInfo.Name)] Installed $entry"
        }
    }
}

if ($Deploy) {
    # Older builds installed scripts\zm\menu.gsc, which would load a second menu.
    $oldEntry = Join-Path $ScriptsDir "menu.gsc"
    if (Test-Path $oldEntry) {
        Move-Item $oldEntry (Join-Path $BuildDir "previous-root-menu.gsc") -Force
        Write-Host "Moved the old scripts\zm\menu.gsc to build\previous-root-menu.gsc"
    }
}

if ($Tools) {
    # Each tool is its own script, compiled from a copy in build\tools.
    $toolsBuild = Join-Path $BuildDir "tools"
    New-Item -ItemType Directory -Force $toolsBuild | Out-Null
    foreach ($tool in Get-ChildItem (Join-Path $Root "tools") -Filter *.gsc) {
        Copy-Item $tool.FullName $toolsBuild -Force
        $toolCompiled = Invoke-GscTool $toolsBuild $tool.Name $null
        Write-Host "Built $toolCompiled"
        if ($Deploy) {
            Install-File $toolCompiled (Join-Path $ScriptsDir $tool.Name)
            Write-Host "Installed $(Join-Path $ScriptsDir $tool.Name)"
        }
    }
}
