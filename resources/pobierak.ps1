# =======================
# POBIERAK (PowerShell) – revised version with AI
# Version:
$pobierak_v = "3.531"
# =======================
# --- Runtime configuration & important paths ---
# $recources_main_dir: absolute path to resources folder (script directory).
# $yt_dlp: path to yt-dlp.exe (bundled).
# $ffmpeg: default ffmpeg.exe path (validated later by Resolve-FFmpegPath).
# =======================

#Preferences/settings
#Browser for cookies-from-browser (Windows): 'firefox' | 'chrome' | 'edge'
$BrowserForCookies = 'firefox'

$UnderlineChar = '-'

# ------------------------------------------------------------------------------
# Load required assemblies (System.Windows.Forms) (Forms)
try {
    Add-Type -AssemblyName System.Windows.Forms
} catch {
    Write-Host "Nie można załadować System.Windows.Forms" -ForegroundColor Red
}

# ------------------------------------------------------------------------------
# User context, paths, tools
$logged_usr           = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).Split('\')[1]
$recources_main_dir   = Split-Path $PSCommandPath -Parent
$pobierakbat_main_dir = $recources_main_dir -replace 'Resources',''
$yt_dlp               = "$recources_main_dir\yt-dlp.exe"
$ffmpeg               = "$recources_main_dir\ffmpeg\ffmpeg\bin\ffmpeg.exe"   # domyślnie – później weryfikujemy

# ------------------------------------------------------------------------------
# Configuration / Language
# Language is NOT detected automatically anymore.
# It is read only from:
#   Resources\config.ini
#
# Supported values:
#   Language=pl
#   Language=en

$config_file = Join-Path $recources_main_dir "config.ini"

function Initialize-Config {
    if (-not (Test-Path -LiteralPath $config_file)) {
        @(
            "# Pobierak configuration"
            "# Supported languages: pl, en"
            "Language=pl"
        ) | Set-Content -Path $config_file -Encoding UTF8
    }
}

function Get-ConfigLanguage {
    Initialize-Config

    try {
        $cfg = Get-Content -Path $config_file -ErrorAction Stop

        foreach ($line in $cfg) {
            if ($line -match '^\s*Language\s*=\s*(pl|en)\s*$') {
                return $matches[1].ToLower()
            }
        }
    } catch {}

    # Safe fallback if config is broken
    Set-ConfigLanguage -Lang "en" -Silent
    return "en"
}

function Set-ConfigLanguage {
    param(
        [ValidateSet("pl", "en")]
        [string]$Lang,

        [switch]$Silent
    )

    Initialize-Config

    $content = Get-Content -Path $config_file -ErrorAction SilentlyContinue
    $changed = $false
    $newContent = @()

    foreach ($line in $content) {
        if ($line -match '^\s*Language\s*=') {
            $newContent += "Language=$Lang"
            $changed = $true
        } else {
            $newContent += $line
        }
    }

    if (-not $changed) {
        $newContent += "Language=$Lang"
    }

    $newContent | Set-Content -Path $config_file -Encoding UTF8

    if (-not $Silent) {
        Write-Host ""
        Write-Host "Language saved in config.ini: $Lang" -ForegroundColor Green
        Start-Sleep -Seconds 1
    }
}


function Import-PobierakLanguage {
    param(
        [ValidateSet("pl", "en")]
        [string]$Lang
    )

    $langDir = Join-Path $recources_main_dir "LANG"

    try {
        if ($Lang -eq "pl") {
            $data = Import-LocalizedData -BaseDirectory $langDir -UICulture "pl-PL" -ErrorAction Stop
        } else {
            $data = Import-LocalizedData -BaseDirectory $langDir -UICulture "en-US" -ErrorAction Stop
        }

        if (-not $data) {
            throw "Language data is empty."
        }

        return $data
    }
    catch {
        Write-Host ""
        Write-Host "ERROR: Cannot load language file." -ForegroundColor Red
        Write-Host "Language: $Lang" -ForegroundColor Red
        Write-Host "Directory: $langDir" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Start-Sleep -Seconds 10
        exit 1
    }
}

function Show-LanguageDialog {	
  $items = @(
        @{ Code = "pl"; Label = "Polski / Polish" }
        @{ Code = "en"; Label = "English / Angielski" }
    )


    $current = $script:language
    $index = 0

    for ($i = 0; $i -lt $items.Count; $i++) {
        if ($items[$i].Code -eq $current) {
            $index = $i
            break
        }
    }

    while ($true) {
		clear
        Write-Host ""
        Write-Host "----------------------------------------------" -ForegroundColor Cyan
        Write-Host " Select language / Wybierz jezyk" -ForegroundColor Cyan
        Write-Host "----------------------------------------------" -ForegroundColor Cyan

        for ($i = 0; $i -lt $items.Count; $i++) {
            if ($i -eq $index) {
                Write-Host (" > {0}" -f $items[$i].Label) -ForegroundColor Black -BackgroundColor Cyan
            } else {
                Write-Host ("   {0}" -f $items[$i].Label) -ForegroundColor White
            }
        }

        Write-Host "----------------------------------------------" -ForegroundColor Cyan
        Write-Host " Up/Down - move | Enter - OK | Esc - cancel" -ForegroundColor Cyan
        Write-Host "----------------------------------------------" -ForegroundColor Cyan
        Write-Host ""

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 {
                if ($index -gt 0) {
                    $index--
                } else {
                    $index = $items.Count - 1
                }
            }
            40 {
                if ($index -lt ($items.Count - 1)) {
                    $index++
                } else {
                    $index = 0
                }
            }
            13 {
                return $items[$index].Code
            }
            27 {
                return $null
            }
        }
    }
}

function Change-Language {
    $selectedLang = Show-LanguageDialog

    if ($null -eq $selectedLang) {
        return
    }

    Set-ConfigLanguage -Lang $selectedLang

    $script:language = $selectedLang
    $script:text_msg = Import-PobierakLanguage -Lang $script:language

    
	Write-Host $text_msg.lang_menu0 -ForegroundColor Green
  
    Start-Sleep -Seconds 2
}

$script:language = Get-ConfigLanguage
$script:text_msg = Import-PobierakLanguage -Lang $script:language

#---------------------------------------------------------------------------------------------
# --- Function: ConvertTo-YtDlpVersionObject ---
# Purpose: Convert yt-dlp version string like 2025.06.09 to a [version] object for safe comparison.
function ConvertTo-YtDlpVersionObject {
    param(
        [Parameter(Mandatory)]
        [string]$VersionString
    )

    $clean = ($VersionString.Trim() -replace '[^\d\.]', '')
    $parts = $clean.Split('.') | Where-Object { $_ -match '^\d+$' }

    if (-not $parts -or $parts.Count -eq 0) {
        return $null
    }

    while ($parts.Count -lt 4) {
        $parts += "0"
    }

    if ($parts.Count -gt 4) {
        $parts = $parts[0..3]
    }

    try {
        return [version]($parts -join '.')
    }
    catch {
        return $null
    }
}

# --- Function: Get-YtDlpExeVersion ---
# Purpose: Run yt-dlp.exe --version and return the detected version string.
function Get-YtDlpExeVersion {
    param(
        [Parameter(Mandatory)]
        [string]$ExePath
    )

    if (-not (Test-Path -LiteralPath $ExePath)) {
        return $null
    }

    try {
        $ver = & $ExePath --version 2>$null | Select-Object -First 1

        if ([string]::IsNullOrWhiteSpace($ver)) {
            return $null
        }

        return $ver.Trim()
    }
    catch {
        return $null
    }
}

# --- Function: Get-LatestYtDlpGithubVersion ---
# Purpose: Get the latest yt-dlp release version from GitHub API without downloading yt-dlp.exe.
function Get-LatestYtDlpGithubVersion {
    $apiUrl = "https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"

    try {
        # Enable TLS 1.2 for older Windows PowerShell environments.
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $client = New-Object System.Net.WebClient
        $client.Headers.Add("User-Agent", "Pobierak-Version-Check")
        $client.Headers.Add("Accept", "application/vnd.github+json")

        $json = $client.DownloadString($apiUrl)

        if ([string]::IsNullOrWhiteSpace($json)) {
            return $null
        }

        $data = $json | ConvertFrom-Json

        if ($null -eq $data -or [string]::IsNullOrWhiteSpace($data.tag_name)) {
            return $null
        }

        return ($data.tag_name.Trim() -replace '^v', '')
    }
    catch {
        return $null
    }
    finally {
        if ($client) {
            $client.Dispose()
        }
    }
}

#####################################################################################################
# --- Function: ConvertTo-YtDlpVersionObject ---
# Purpose: Convert yt-dlp version string like 2025.06.09 to a [version] object for safe comparison.
function ConvertTo-YtDlpVersionObject {
    param(
        [Parameter(Mandatory)]
        [string]$VersionString
    )

    $clean = ($VersionString.Trim() -replace '[^\d\.]', '')
    $parts = $clean.Split('.') | Where-Object { $_ -match '^\d+$' }

    if (-not $parts -or $parts.Count -eq 0) {
        return $null
    }

    while ($parts.Count -lt 4) {
        $parts += "0"
    }

    if ($parts.Count -gt 4) {
        $parts = $parts[0..3]
    }

    try {
        return [version]($parts -join '.')
    }
    catch {
        return $null
    }
}

# --- Function: Get-YtDlpExeVersion ---
# Purpose: Run yt-dlp.exe --version and return the detected version string.
function Get-YtDlpExeVersion {
    param(
        [Parameter(Mandatory)]
        [string]$ExePath
    )

    if (-not (Test-Path -LiteralPath $ExePath)) {
        return $null
    }

    try {
        $ver = & $ExePath --version 2>$null | Select-Object -First 1

        if ([string]::IsNullOrWhiteSpace($ver)) {
            return $null
        }

        return $ver.Trim()
    }
    catch {
        return $null
    }
}

# ------------------------------------------------------------------------------
# Sound
function play_sound {
    try {
        $PlayWav = New-Object System.Media.SoundPlayer
        $PlayWav.SoundLocation = "$recources_main_dir\Bottle.wav"
        $PlayWav.PlaySync()
    } catch {}
}

# ------------------------------------------------------------------------------
# Locate ffmpeg.exe
function Resolve-FFmpegPath {
    param([string]$Root = "$recources_main_dir\ffmpeg")
    if (Test-Path $ffmpeg) { return $ffmpeg }
    $exe = Get-ChildItem -Path $Root -Recurse -File -Filter ffmpeg.exe -ErrorAction SilentlyContinue |
           Select-Object -First 1 -ExpandProperty FullName
    if ($exe) { return $exe }
    return $null
}

# ------------------------------------------------------------------------------
# PIDs of helper processes (bez regex-Replace na ToString())
$process_bak_primary_id = Get-CimInstance Win32_Process -Filter "CommandLine LIKE '%pobierak_primary.ps1%'" -ErrorAction SilentlyContinue |
                          Select-Object -ExpandProperty ProcessId -ErrorAction SilentlyContinue
$process_bak_id         = Get-CimInstance Win32_Process -Filter "CommandLine LIKE '%pobierak_bak.ps1%'" -ErrorAction SilentlyContinue |
                          Select-Object -ExpandProperty ProcessId -ErrorAction SilentlyContinue
# ------------------------------------------------------------------------------
# --- Function: internal_info ---
# Purpose: Print diagnostic information about missing executables and running backup processes.
# Params: [int] missing_exe - ignored input; updates $global:missing_exe (0..2).
# Side effects: Writes warnings to host; sets $global:missing_exe.
function internal_info([int]$missing_exe) {
    $test_ff = "$recources_main_dir\ffmpeg\ffmpeg\bin\ffmpeg.exe"
    $test_yt = "$recources_main_dir\yt-dlp.exe"

    if (($process_bak_id -ne $null) -or ($process_bak_primary_id -ne $null)) {
        $ULine = $UnderlineChar * ($text_msg.criticalupdateerror1.Length + $text_msg.criticalupdateerror2.Length)
        Write-Host $ULine -ForegroundColor Red
        Write-Host $text_msg.criticalupdateerror1
        Write-Host $text_msg.criticalupdateerror2 -ForegroundColor Red
        Write-Host $ULine -ForegroundColor Red
    }

    $missing_ffmpg = 0
    if (Test-Path $test_ff) {
        $missing_ffmpg = 0
    } else {
        $ULine = $UnderlineChar * $text_msg.updpath.Length
        Write-Host $ULine -ForegroundColor Red
        Write-Host $text_msg.warning -ForegroundColor Red
        Write-Host $text_msg.ffmpglib
        Write-Host $text_msg.updpath -ForegroundColor Red
        Write-Host $ULine -ForegroundColor Red
        $missing_ffmpg = 1
    }

    $missing_ytdlp = 0
    if (Test-Path $test_yt) {
        $missing_ytdlp = 0
    } else {
        $ULine = $UnderlineChar * $text_msg.updpath.Length
        Write-Host $ULine -ForegroundColor Red
        Write-Host $text_msg.warning -ForegroundColor Red
        Write-Host $text_msg.ytdlpexe
        Write-Host $text_msg.updpath -ForegroundColor Red
        Write-Host $ULine -ForegroundColor Red
        $missing_ytdlp = 1
    }

    $global:missing_exe = $missing_ytdlp + $missing_ffmpg
}

# ------------------------------------------------------------------------------
# GUI: file selection warning
function warning_select_file {
    [System.Windows.Forms.MessageBox]::Show($text_msg.selectfile,'WARNING') | Out-Null
}

# ------------------------------------------------------------------------------
# Free space – CIM
function Get-FreeSpace {
    param([string]$path = $output_directory)
    $vol = Get-CimInstance Win32_Volume -ErrorAction SilentlyContinue |
           Where-Object { $path -and ($_ -and ($path -like "$($_.Name)*")) } |
           Sort-Object Name -Descending |
           Select-Object -First 1
    if ($vol -and $vol.FreeSpace) { return [math]::Round(($vol.FreeSpace/1GB), 2) }
    return 0
}

# ------------------------------------------------------------------------------
# Folder selection

function Select-Folder {
    [CmdletBinding()]
    param(
        [string]$Description = "Select Folder",
        # You can pass either a SpecialFolder name (e.g. 'MyComputer') or a path
        [string]$RootFolder  = "MyComputer"
    )

    # Ensure STA (needed for WinForms)
    if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
        throw "Select-Folder must run in an STA thread. Start PowerShell with -STA or call from a script host that is STA."
    }

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $owner = New-Object System.Windows.Forms.Form
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog

    try {
        # --- Hidden, topmost owner ---
        $owner.StartPosition  = 'CenterScreen'
        $owner.Size           = New-Object System.Drawing.Size(1,1)
        $owner.ShowInTaskbar  = $false
        $owner.FormBorderStyle= 'FixedToolWindow'
        $owner.TopMost        = $true
        $owner.Opacity        = 0
        $owner.Show()   # Create a handle so it can be a proper owner

        # --- Configure dialog ---
        $dialog.Description = $Description  # (use your $text_msg.selectdir if you prefer)
        $dialog.ShowNewFolderButton = $true

        # Root folder: allow either SpecialFolder or a file system path as a starting point
        try {
            $dialog.RootFolder = [System.Environment+SpecialFolder]::$RootFolder
        }
        catch {
            if (Test-Path $RootFolder) {
                # If RootFolder is a path, seed SelectedPath instead
                $dialog.SelectedPath = (Resolve-Path $RootFolder).Path
            }
            else {
                # Fallback to Desktop if unknown string
                $dialog.RootFolder = [System.Environment+SpecialFolder]::Desktop
            }
        }

        while ($true) {
            $result = $dialog.ShowDialog($owner)
            if ($result -eq [System.Windows.Forms.DialogResult]::OK -and
                -not [string]::IsNullOrWhiteSpace($dialog.SelectedPath)) {
                return $dialog.SelectedPath
            }
            else {
                $res = [System.Windows.Forms.MessageBox]::Show(
                    $owner,
                    "Cancel directory selection?",
                    "Pobierak",
                    [System.Windows.Forms.MessageBoxButtons]::YesNo,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )
                if ($res -eq [System.Windows.Forms.DialogResult]::Yes) { return $null }
            }
        }
    }
    finally {
        if ($dialog) { $dialog.Dispose() }
        if ($owner -and -not $owner.IsDisposed) { $owner.Close(); $owner.Dispose() }
    }
}


# ------------------------------------------------------------------------------
# --- Function: Select-File ---
# Purpose: Display an OpenFileDialog restricted to .txt by default and return the chosen file.
# Params: [string] Directory - initial directory.
# Returns: Selected file path or $null.
function Select-File {
    param([string]$Directory = $PWD)
    $dialog = [System.Windows.Forms.OpenFileDialog]::new()
    $dialog.InitialDirectory  = (Resolve-Path $Directory).Path
    $dialog.RestoreDirectory  = $true
    $dialog.Filter            = "Txt files (*.txt)|*.txt|All files (*.*)|*.*"
    $dialog.CheckFileExists   = $true
    $dialog.Title             = "Select a file with links"
    $result = $dialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.FileName
    }
    return $null
}

# ------------------------------------------------------------------------------
# --- Function: Normalize-YouTubeLink ---
# Purpose: Normalize various YouTube URL forms to canonical watch?v=ID URLs; ignores channels/users.
# Params: [string] Url - input URL.
# Returns: Canonicalized URL or $null if not applicable.
Add-Type -AssemblyName System.Web
function Normalize-YouTubeLink {
    param([Parameter(Mandatory)][string]$Url)

    try { $u = [Uri]$Url } catch { return $null }
    $qs = [System.Web.HttpUtility]::ParseQueryString($u.Query)

    if ($u.AbsoluteUri -match '/channel/|/c/|/user/') { return $null }

    if ($qs['list']) {
        if ($qs['v']) { return "https://www.youtube.com/watch?v=$($qs['v'])" } else { return $null }
    }

    if ($qs['v']) { return "https://www.youtube.com/watch?v=$($qs['v'])" }

    if ($u.Host -like 'youtu.be' -and $u.AbsolutePath.Trim('/')) {
        return "https://www.youtube.com/watch?v=$($u.AbsolutePath.Trim('/'))"
    }

    return $Url
}

# ------------------------------------------------------------------------------
# --- Function: filter_links ---
# Purpose: Normalize a single URL and append it to resources\songs_out.txt if valid.
function filter_links([string]$testlink) {
    $out = "$recources_main_dir\songs_out.txt"
    if (-not (Test-Path $out)) { New-Item -Path $out -ItemType File -Force | Out-Null }

    $normalized = Normalize-YouTubeLink -Url $testlink
    if ($null -ne $normalized) {
        $normalized | Add-Content -Path $out
    }
}

# ------------------------------------------------------------------------------
# --- Function: audio_quality ---
# Purpose: Prompt for MP3 bitrate (128k or 320k).
# Returns: [string] "128K" or "320K".

function audio_quality {
    do {
        Write-Host ""
        Start-Sleep -Milliseconds 300
        Write-Host $text_msg.quality0 -ForegroundColor Green
        $q = Read-Host -Prompt $text_msg.quality1
        $q = ($q.Trim()).ToUpper()
    } while ($q -ne "128K" -and $q -ne "320K")
    return [string]$q
}
# ------------------------------------------------------------------------------
# --- Function: audio_0_1 ---
# Purpose: Yes/No choice for audio download (1=yes, 2=no).
# Returns: [int] 1 or 2.
function audio_0_1 {
    do {
        Start-Sleep -Milliseconds 300
        Write-Host ""
        Write-Host $text_msg.audio010 -ForegroundColor Yellow
        $ans = Read-Host -Prompt $text_msg.audio011
        [int]$ans = $ans
    } while ($ans -ne 1 -and $ans -ne 2)
    return [int]$ans
}
# ------------------------------------------------------------------------------
# --- Function: video_0_1 ---
# Purpose: Yes/No choice for video download (1=yes, 2=no).
# Returns: [int] 1 or 2.
function video_0_1 {
    do {
        Start-Sleep -Milliseconds 300
        Write-Host ""
        Write-Host $text_msg.video010 -ForegroundColor Yellow
        $ans = Read-Host -Prompt $text_msg.video011
        [int]$ans = $ans
    } while ($ans -ne 1 -and $ans -ne 2)
    return [int]$ans
}
# ------------------------------------------------------------------------------
# --- Function: video_format ---
# Purpose: Prompt for output video container (avi/mp4).
# Returns: [string] "avi" or "mp4".
function video_format {
    do {
        Start-Sleep -Milliseconds 300
        Write-Host ""
        Write-Host $text_msg.videoformat0 -ForegroundColor Green
        $fmt = Read-Host -Prompt $text_msg.videoformat1
        $fmt = ($fmt.Trim()).ToLower()
    } while ($fmt -ne "avi" -and $fmt -ne "mp4")
    return [string]$fmt
}
# ------------------------------------------------------------------------------
# --- Function: playlist_range ---
# Purpose: Ask the user to provide a playlist range (from..to) or skip.
# Params: [ref] rangeOut - returns an array: [yesNo, from?, to?].

function playlist_range([ref]$rangeOut) {
    $arr = @()

    # Ask: 1 (use range) or 2 (all)
    do {
        Start-Sleep -Milliseconds 300
        Write-Host ""
        Write-Host $text_msg.playlist_range0 -ForegroundColor Yellow
        $ynRaw = Read-Host
        $yn = 0
    } while (-not [int]::TryParse($ynRaw, [ref]$yn) -or ($yn -notin 1, 2))

    $arr += [int]$yn

    if ($yn -eq 1) {
        do {
            Start-Sleep -Milliseconds 300
            Write-Host ""
            Write-Host $text_msg.playlist_range1 -ForegroundColor Yellow
            $fromRaw = Read-Host
            Write-Host $text_msg.playlist_range2 -ForegroundColor Yellow
            $toRaw = Read-Host

            $from = 0; $to = 0
            $okFrom = [int]::TryParse($fromRaw, [ref]$from)
            $okTo   = [int]::TryParse($toRaw,   [ref]$to)
        } until ($okFrom -and $okTo)
		
        $arr += $from
        $arr += $to
    }

    # Return a flat array like: @( <1-or-2>, <from?>, <to?> )
    $rangeOut.Value = $arr
}


# ------------------------------------------------------------------------------
# --- Function: ytdlp_download_audio ---
# Purpose: Call yt-dlp to extract MP3 audio with the requested bitrate.
# Params: track, quality, output_directory, ffmpegPath.

function ytdlp_download_audio([string]$track, [string]$quality, [string]$output_directory, [string]$ffmpegPath) {
    $args = @(
        '--ignore-errors'
        '--ffmpeg-location', $ffmpegPath
        '--format', 'bestaudio'
        '--audio-format', 'mp3'
        '--extract-audio'
        '--audio-quality', $quality
        '--output', "$output_directory\%(title)s.%(ext)s"
        $track
    )
    & $yt_dlp @args
}
# ------------------------------------------------------------------------------
# --- Function: ytdlp_download_video ---
# Purpose: Call yt-dlp to download best video+audio and merge to selected container.
# Params: track, video_format, output_directory, ffmpegPath.
function ytdlp_download_video([string]$track, [string]$video_format, [string]$output_directory, [string]$ffmpegPath) {
    $args = @(
        '--ignore-errors'
        '--ffmpeg-location', $ffmpegPath
        '-f', 'bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best'
        '--merge-output-format', $video_format
        '--no-playlist'
        '--output', "$output_directory\%(title)s.%(ext)s"
        $track
    )
    & $yt_dlp @args
}

# ------------------------------------------------------------------------------
# 1) Manual URL input -> audio
# --- Function: download_song ---
# Purpose: Interactive flow to paste individual URLs, choose bitrate and output folder, then download audio.
function download_song {
    Clear-Host
    if ($missing_exe -gt 0) {
        Write-Host ""
        Write-Host $text_msg.optionwithoutexe0 -ForegroundColor Red
        Write-Host $text_msg.optionwithoutexe1 -ForegroundColor Red
        Start-Sleep -Seconds 4
        updates_menu
        return
    } else {
        Write-Host $text_msg.downloadsongintro -ForegroundColor Yellow
    }

    $outList = "$recources_main_dir\songs_out.txt"
    if (Test-Path $outList) { Remove-Item $outList -Force }

    do {
        Start-Sleep -Milliseconds 300
        Write-Host ""
        Write-Host $text_msg.downloadsonginfo0 -ForegroundColor Green
        Write-Host $text_msg.downloadsonginfo1 -ForegroundColor Green
        $s = Read-Host -Prompt $text_msg.downloadsonginfo2
        $s = $s.Trim()
        if ($s -and $s -ne 'q') { filter_links $s }
    } until ($s -eq 'q')

    [string]$quality = audio_quality

    $source = Get-Content -Path $outList -ErrorAction SilentlyContinue | Where-Object { $_ -and $_.Trim() }
    [int]$lines_var = $source.Count
    if ($lines_var -eq 0) {
        Write-Host "No links to download." -ForegroundColor Yellow
        return
    }

    $output_directory = Select-Folder
    if (-not $output_directory) { return }

    $ffmpegPath = Resolve-FFmpegPath
    if (-not $ffmpegPath) { Write-Host "ffmpeg.exe not found" -ForegroundColor Red; return }

    $free_space = Get-FreeSpace $output_directory
    Start-Sleep -Seconds 1
    Write-Host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
    Start-Process explorer.exe -ArgumentList $output_directory | Out-Null
    [int]$song_count = 0
    foreach ($track in $source) {
        $song_count++
        ytdlp_download_audio -track $track -quality $quality -output_directory $output_directory -ffmpegPath $ffmpegPath
        $lines_var--
    }

    Remove-Item -Path $outList -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewLine
}

# ------------------------------------------------------------------------------
# 2) Download from file (list of URLs) -> audio
# --- Function: download_from_list ---
# Purpose: Load URLs from a text file, choose bitrate and output folder, then download audio.
function download_from_list {
    Clear-Host
    if ($missing_exe -gt 0) {
        Write-Host ""
        Write-Host $text_msg.optionwithoutexe0 -ForegroundColor Red
        Write-Host $text_msg.optionwithoutexe1 -ForegroundColor Red
        Start-Sleep -Seconds 4
        updates_menu
        return
    } else {
        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host $text_msg.downloadfromlistintro -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 1
    }

    warning_select_file
    $selected_file_var = Select-File
    if (-not $selected_file_var) { return }

    $outList = "$recources_main_dir\songs_out.txt"
    if (Test-Path $outList) { Remove-Item $outList -Force }

    $d = Get-Content -Path $selected_file_var -ErrorAction SilentlyContinue | Where-Object { $_ -and $_.Trim() }
    foreach ($line in $d) { filter_links $line }

    [string]$quality = audio_quality

    $output_directory = Select-Folder
    if (-not $output_directory) { return }

    $ffmpegPath = Resolve-FFmpegPath
    if (-not $ffmpegPath) { Write-Host "ffmpeg.exe not found" -ForegroundColor Red; return }

    $free_space = Get-FreeSpace $output_directory
    Start-Sleep -Seconds 1
    Write-Host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
    Start-Process explorer.exe -ArgumentList $output_directory | Out-Null

    $source = Get-Content -Path $outList | Where-Object { $_ -and $_.Trim() }
    [int]$lines_var = $source.Count
    [int]$song_count = 0

    foreach ($track in $source) {
        $song_count++
        ytdlp_download_audio -track $track -quality $quality -output_directory $output_directory -ffmpegPath $ffmpegPath
        $lines_var--
    }

    Remove-Item -Path $outList -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewLine
}

# ------------------------------------------------------------------------------
# 3) Playlist -> audio (+ range)

# --- Function: download_playlist ---
# Purpose: Download audio from a YouTube playlist (optionally a sub-range).
function download_playlist {
    Clear-Host
    if ($missing_exe -gt 0) {
        Write-Host ""
        Write-Host $text_msg.optionwithoutexe0 -ForegroundColor Red
        Write-Host $text_msg.optionwithoutexe1 -ForegroundColor Red
        Start-Sleep -Seconds 4
        updates_menu
        return
    } else {
        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host $text_msg.downloadplaylistintro -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 1
    }

    $range = $null; playlist_range ([ref]$range)
    $playlist_range_yes_no = [int]$range[0]

    Write-Host $text_msg.downloadplaylistinfo0 -ForegroundColor Yellow
    Write-Host $text_msg.downloadplaylistinfo1 -ForegroundColor Yellow
    Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta
    Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor Green
    $playlist_ID_yt = Read-Host -Prompt $text_msg.downloadplaylistinfo2

    [string]$quality = audio_quality
    $output_directory = Select-Folder
    if (-not $output_directory) { return }

    $ffmpegPath = Resolve-FFmpegPath
    if (-not $ffmpegPath) { Write-Host "ffmpeg.exe not found" -ForegroundColor Red; return }

    $free_space = Get-FreeSpace $output_directory
    Start-Sleep -Seconds 1
    Write-Host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
    Start-Process explorer.exe -ArgumentList $output_directory | Out-Null
	
	$args = @(
		'--ignore-errors'
		'--ffmpeg-location', $ffmpegPath
		'--format','bestaudio'
		'--audio-format','mp3'
		'--extract-audio'
		'--audio-quality', $quality
		'--yes-playlist'
		'--output', "$output_directory\%(title)s.%(ext)s"
		$playlist_ID_yt
	)	
    if ($playlist_range_yes_no -eq 1) {
        $from = $range[1]; $to = $range[2]
        $args = @(
			'--ignore-errors'
			'--ffmpeg-location', $ffmpegPath
			'--playlist-items', "$from-$to"
			'--format','bestaudio'
			'--audio-format','mp3'
			'--extract-audio'
			'--audio-quality', $quality
			'--yes-playlist'
			'--output', "$output_directory\%(title)s.%(ext)s"
			$playlist_ID_yt
		)
    }

    & $yt_dlp @args
    Write-Host ""
    Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewLine
}

# ------------------------------------------------------------------------------
# 4) Channel -> audio
# --- Function: download_channel ---
# Purpose: Download audio from a YouTube channel by Channel ID.
function download_channel {
    Clear-Host
    if ($missing_exe -gt 0) {
        Write-Host ""
        Write-Host $text_msg.optionwithoutexe0 -ForegroundColor Red
        Write-Host $text_msg.optionwithoutexe1 -ForegroundColor Red
        Start-Sleep -Seconds 4
        updates_menu
        return
    } else {
        Start-Sleep -Seconds 1
        Write-Host $text_msg.downloadchannelintro -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 1
    }

    Write-Host $text_msg.downloadchannelinfo0 -ForegroundColor Yellow
    Write-Host $text_msg.downloadchannelinfo1 -ForegroundColor Yellow
    $channel_ID_yt_raw = Read-Host -Prompt $text_msg.downloadchannelinfo2
    [string]$channel_ID_yt = "https://www.youtube.com/channel/$channel_ID_yt_raw"

    [string]$quality = audio_quality
    $output_directory = Select-Folder
    if (-not $output_directory) { return }

    $ffmpegPath = Resolve-FFmpegPath
    if (-not $ffmpegPath) { Write-Host "ffmpeg.exe not found" -ForegroundColor Red; return }

    Start-Process explorer.exe -ArgumentList $output_directory | Out-Null

    $free_space = Get-FreeSpace $output_directory
    Start-Sleep -Seconds 1
    Write-Host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
    Start-Sleep -Seconds 2

    $args = @(
        '-ciw'
        '--extract-audio'
        '--audio-format','mp3'
        '--ffmpeg-location', $ffmpegPath
        '--audio-quality', $quality
        '--output', "$output_directory\%(title)s.%(ext)s"
        $channel_ID_yt
    )
    & $yt_dlp @args

    Write-Host ""
    Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewLine
}

# ------------------------------------------------------------------------------
# 5) List (file/terminal) -> audio and/or  wideo
# --- Function: download_movie_and_or_music_from_list ---
# Purpose: Mixed mode: from a list (file or console), download video and optionally audio as MP3.
function download_movie_and_or_music_from_list {
    Clear-Host
    if ($missing_exe -gt 0) {
        Write-Host ""
        Write-Host $text_msg.optionwithoutexe0 -ForegroundColor Red
        Write-Host $text_msg.optionwithoutexe1 -ForegroundColor Red
        Start-Sleep -Seconds 4
        updates_menu
        return
    } else {
        Start-Sleep -Seconds 1
        Write-Host $text_msg.fun5intro -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 1
    }

    $outList = "$recources_main_dir\songs_out.txt"
    if (Test-Path $outList) { Remove-Item $outList -Force }

    do {
        Start-Sleep -Milliseconds 300
        Write-Host ""
        Write-Host $text_msg.fun5listorterminal0 -ForegroundColor Yellow
        $list_console = Read-Host -Prompt $text_msg.fun5listorterminal1
        [int]$list_console = $list_console
    } while ($list_console -ne 1 -and $list_console -ne 2)

    if ($list_console -eq 1) {
        warning_select_file
        $selected_file_var = Select-File
        if (-not $selected_file_var) { return }
        $sourceIn = Get-Content -Path $selected_file_var | Where-Object { $_ -and $_.Trim() }
        foreach ($line in $sourceIn) { filter_links $line }
    } elseif ($list_console -eq 2) {
        do {
            Start-Sleep -Milliseconds 300
            Write-Host ""
            Write-Host $text_msg.downloadsonginfo0 -ForegroundColor Green
            Write-Host $text_msg.downloadsonginfo1 -ForegroundColor Green
            $link = Read-Host -Prompt $text_msg.downloadsonginfo2
            $link = $link.Trim()
            if ($link -and $link -ne 'q') { filter_links $link }
        } until ($link -eq 'q')
    }

    $source = Get-Content -Path $outList -ErrorAction SilentlyContinue | Where-Object { $_ -and $_.Trim() }
    if (-not $source -or $source.Count -eq 0) { Write-Host "No links." -ForegroundColor Yellow; return }

    $video_format = video_format
    $audio_yes_no = audio_0_1
    if ($audio_yes_no -eq 1) { [string]$quality = audio_quality }

    $output_directory = Select-Folder
    if (-not $output_directory) { return }

    $ffmpegPath = Resolve-FFmpegPath
    if (-not $ffmpegPath) { Write-Host "ffmpeg.exe not found" -ForegroundColor Red; return }

    $free_space = Get-FreeSpace $output_directory
    Start-Sleep -Seconds 1
    Write-Host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Start-Process explorer.exe -ArgumentList $output_directory | Out-Null

    [int]$lines_var  = $source.Count
    [int]$song_count = 0

    foreach ($track in $source) {
        $song_count++
        if ($audio_yes_no -eq 1) {
            ytdlp_download_audio -track $track -quality $quality -output_directory $output_directory -ffmpegPath $ffmpegPath
            ytdlp_download_video -track $track -video_format $video_format -output_directory $output_directory -ffmpegPath $ffmpegPath
        } else {
            ytdlp_download_video -track $track -video_format $video_format -output_directory $output_directory -ffmpegPath $ffmpegPath
        }
        $lines_var--
    }

    if (Test-Path $outList) { Remove-Item -Path $outList -Force }
    Write-Host ""
    Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewLine
}

# ------------------------------------------------------------------------------
# 6) List (PLAYLIST/CHANNEL) -> audio and/or wideo
# --- Function: download_movie_and_or_music_from_list_PLAYLIST_AND_CHANNEL ---
# Purpose: Accept playlist or channel URLs and download video and optionally audio.
function download_movie_and_or_music_from_list_PLAYLIST_AND_CHANNEL {
    Clear-Host
    if ($missing_exe -gt 0) {
        Write-Host ""
        Write-Host $text_msg.optionwithoutexe0 -ForegroundColor Red
        Write-Host $text_msg.optionwithoutexe1 -ForegroundColor Red
        Start-Sleep -Seconds 4
        updates_menu
        return
    } else {
        Start-Sleep -Seconds 1
        Write-Host $text_msg.fun6intro -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 1
    }

    $songsTxt = "$recources_main_dir\songs.txt"
    if (Test-Path $songsTxt) { Remove-Item $songsTxt -Force }

    do {
        Start-Sleep -Milliseconds 300
        Write-Host ""
        Write-Host $text_msg.downloadplaylistinfo0 -ForegroundColor Yellow
        Write-Host $text_msg.downloadplaylistinfo1 -ForegroundColor Yellow
        Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta
        Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor Green
        Write-Host ""
        Write-Host $text_msg.downloadchannelinfo0 -ForegroundColor Yellow
        Write-Host $text_msg.downloadchannelinfo1 -ForegroundColor Yellow
        Write-Host $text_msg.downloadchannelinfo2 -ForegroundColor Yellow
        Write-Host ""
        $s = Read-Host -Prompt $text_msg.downloadsonginfo2
        $s = $s.Trim()
        if ($s -and $s -ne 'q') { $s | Add-Content -Path $songsTxt }
    } until ($s -eq 'q')

    $video_format = video_format
    $audio_yes_no = audio_0_1
    $source       = Get-Content -Path $songsTxt | Where-Object { $_ -and $_.Trim() }

    $output_directory = Select-Folder
    if (-not $output_directory) { return }
    Start-Process explorer.exe -ArgumentList $output_directory | Out-Null

    $ffmpegPath = Resolve-FFmpegPath
    if (-not $ffmpegPath) { Write-Host "ffmpeg.exe not found" -ForegroundColor Red; return }

    $free_space = Get-FreeSpace $output_directory
    Start-Sleep -Seconds 1
    Write-Host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
    Start-Sleep -Seconds 2

    if ($audio_yes_no -eq 1) {
        [string]$quality = audio_quality
        foreach ($track in $source) {
            $argsA = @(
                '--ignore-errors'
                '--ffmpeg-location', $ffmpegPath
                '--extract-audio','--audio-format','mp3'
                '--output', "$output_directory\%(title)s.%(ext)s"
                '--audio-quality', $quality
                $track
            )
            & $yt_dlp @argsA

            $argsV = @(
                '--ignore-errors'
                '--ffmpeg-location', $ffmpegPath
                '-f','bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best'
                '--merge-output-format', $video_format
                '--output', "$output_directory\%(title)s.%(ext)s"
                $track
            )
            & $yt_dlp @argsV
        }
    } else {
        foreach ($track in $source) {
            $argsV = @(
                '--ignore-errors'
                '--ffmpeg-location', $ffmpegPath
                '-f','bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best'
                '--merge-output-format', $video_format
                '--output', "$output_directory\%(title)s.%(ext)s"
                $track
            )
            & $yt_dlp @argsV
        }
    }

    Remove-Item -Path $songsTxt -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewLine
}

# ------------------------------------------------------------------------------
# 7) Private playlists – cookies-from-browser (Windows)
# --- Function: download_from_cookie ---
# Purpose: Use browser cookies to access private playlists; supports range/video/audio options.
function download_from_cookie {
    Clear-Host
    if ($missing_exe -gt 0) {
        Write-Host ""
        Write-Host $text_msg.optionwithoutexe0 -ForegroundColor Red
        Write-Host $text_msg.optionwithoutexe1 -ForegroundColor Red
        Start-Sleep -Seconds 4
        updates_menu
        return
    } else {
        Start-Sleep -Seconds 1
        Write-Host $text_msg.downloadfromcookieintro -ForegroundColor Yellow
        Write-Host ""
        Start-Sleep -Seconds 1
    }

    Write-Host ""
    Write-Host $text_msg.downloadfromcookiewarn3 -ForegroundColor Yellow
    Start-Sleep -Seconds 2

    $range = $null; playlist_range ([ref]$range)
    $playlist_range_yes_no = [int]$range[0]

    Write-Host $text_msg.downloadplaylistinfo0 -ForegroundColor Yellow
    Write-Host $text_msg.downloadplaylistinfo1 -ForegroundColor Yellow
    Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta
    Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor Green
    $playlist_ID_yt = Read-Host -Prompt $text_msg.downloadplaylistinfo2

    $video_yes_no = video_0_1
    if ($video_yes_no -eq 1) {
        Start-Sleep -Milliseconds 300
        $video_format = video_format
        Start-Sleep -Milliseconds 300
        $audio_yes_no = audio_0_1
    }

    if (($audio_yes_no -eq 1) -or ($video_yes_no -eq 2)) {
        [string]$quality = audio_quality
    }

    $output_directory = Select-Folder
    if (-not $output_directory) { return }
    Start-Process explorer.exe -ArgumentList $output_directory | Out-Null
    $ffmpegPath = Resolve-FFmpegPath
    if (-not $ffmpegPath) { Write-Host "ffmpeg.exe not found" -ForegroundColor Red; return }

    $free_space = Get-FreeSpace $output_directory
    Start-Sleep -Seconds 1
    Write-Host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
    Start-Sleep -Seconds 2

    # AUDIO (if selected)
    if ($video_yes_no -eq 2 -or $audio_yes_no -eq 1) {
        $argsA = @(
            '--ignore-errors'
            '--ffmpeg-location', $ffmpegPath
            '--extract-audio','--audio-format','mp3'
            '--output', "$output_directory\%(title)s.%(ext)s"
            '--audio-quality', $quality
            '--cookies-from-browser', $BrowserForCookies
            $playlist_ID_yt
        )
        if ($playlist_range_yes_no -eq 1) {
            $from = $range[1]; $to = $range[2]
            $argsA = @(
            '--ignore-errors'
            '--ffmpeg-location', $ffmpegPath
			'--playlist-items', "$from-$to"
            '--extract-audio','--audio-format','mp3'
            '--output', "$output_directory\%(title)s.%(ext)s"
            '--audio-quality', $quality
            '--cookies-from-browser', $BrowserForCookies
            $playlist_ID_yt
			)	
        }
        & $yt_dlp @argsA
        Write-Host ""
        Write-Host $text_msg.downloadfromcookieaudio2 -ForegroundColor Yellow
    }

    # VIDEO (if selected)
    if ($video_yes_no -eq 1) {
        $argsV = @(
            '--ignore-errors'
            '--ffmpeg-location', $ffmpegPath
            '-f','bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best'
            '--merge-output-format', $video_format
            '--output', "$output_directory\%(title)s.%(ext)s"
            '--cookies-from-browser', $BrowserForCookies
            $playlist_ID_yt
        )
        if ($playlist_range_yes_no -eq 1) {
            $from = $range[1]; $to = $range[2]
            $argsV = @(
            '--ignore-errors'
            '--ffmpeg-location', $ffmpegPath
			'--playlist-items', "$from-$to"
            '-f','bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best'
            '--merge-output-format', $video_format
            '--output', "$output_directory\%(title)s.%(ext)s"
            '--cookies-from-browser', $BrowserForCookies
            $playlist_ID_yt
			)
        }
        & $yt_dlp @argsV
        Write-Host ""
        Write-Host $text_msg.downloadfromcookievideo1 -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewLine
}

# ------------------------------------------------------------------------------
# 8) Updates – functions (IWR zamiast curl/BITS fallback)

# --- Function: check_pobierak_version ---
# Purpose: Download latest project ZIP from GitHub, compare versions, and optionally stage an update.
# Returns: 1 to install, 2 to skip, or exits with rc=3 on update.

function check_pobierak_version {
    Clear-Host
    $path_to_temp = "$recources_main_dir\temp"
    if (-not (Test-Path -PathType Container $path_to_temp)) {
        New-Item -ItemType Directory -Path $path_to_temp | Out-Null
    } else {
        Remove-Item $path_to_temp -Force -Recurse
        New-Item -ItemType Directory -Path $path_to_temp | Out-Null
    }

    $zipPath = Join-Path $path_to_temp 'pobierak.zip'
    Invoke-WebRequest -Uri "https://github.com/pagend0s/pobierak4windows/archive/refs/heads/main.zip" -OutFile $zipPath

    Expand-Archive -Path $zipPath -DestinationPath "$path_to_temp\pobierak" -Force

    $pob_present_line = Select-String -Path "$recources_main_dir\pobierak.ps1" -Pattern "pobierak_v" | Select-Object -First 1
    $version_present  = $pob_present_line.Line.Split('=')[1] -replace '"','' -replace ' ',''
    [double]$version_present_double = [string]$version_present

    $pob_downloaded_line = Select-String -Path "$path_to_temp\pobierak\pobierak4windows-main\resources\pobierak.ps1" -Pattern "pobierak_v" | Select-Object -First 1
    $version_downloaded  = $pob_downloaded_line.Line.Split('=')[1] -replace '"','' -replace ' ',''
    [double]$version_downloaded_double = [string]$version_downloaded

    $install_or_not = 2
    if ($version_downloaded_double -gt $version_present_double) {
        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host $text_msg.checkpobierakversion00 " $version_downloaded_double" -ForegroundColor Green
        Write-Host ""
        Start-Sleep -Seconds 1

       
	if ($script:language -eq "pl") {
		$text_msg_upd = Import-LocalizedData -BaseDirectory "$path_to_temp\pobierak\pobierak4windows-main\resources\LANG\" -UICulture "pl-PL"
	} else {
		$text_msg_upd = Import-LocalizedData -BaseDirectory "$path_to_temp\pobierak\pobierak4windows-main\resources\LANG\" -UICulture "en-US"
	}
	
	Write-Host $text_msg_upd.checkpobierakversion10 -ForegroundColor Green

	$updNews = $null

	foreach ($item in @($text_msg_upd)) {
   		if ($item -is [System.Collections.IDictionary]) {

        	$hasNewsKeys = $item.Keys | Where-Object { $_ -match '^news\d+$' }

        	if ($hasNewsKeys) {
           		$updNews = $item
            	break
        	}
    	}
	}

	if ($null -ne $updNews) {
    	$updNews.Keys |
        	Where-Object { $_ -match '^news(\d+)$' } |
        	Sort-Object {
            	if ($_ -match '^news(\d+)$') {
                	[int]$matches[1]
            	} else {
                	999
            	}
        	} |
        	ForEach-Object {
            	$newsKey = $_

            	if ($newsKey -match '^news(\d+)$') {
                	$newsNumber = [int]$matches[1]
                	$newsValue = [string]$updNews[$newsKey]

                	# Skip news00 if it contains version number
                	if ($newsNumber -gt 0 -and -not [string]::IsNullOrWhiteSpace($newsValue)) {
                    	Write-Host "- $newsValue" -ForegroundColor Green
                	}
            	}
        	}
	}
	else {
    	Write-Host "No news entries found in language data." -ForegroundColor Yellow
	}

	


    do {
        	Write-Host ""
            Start-Sleep -Seconds 1
            Write-Host $text_msg.checkpobierakversion01 -ForegroundColor Green
            Write-Host $text_msg.checkpobierakversion02 -ForegroundColor Green
            $install_or_not = Read-Host
            [int]$install_or_not = $install_or_not
        } while ($install_or_not -ne 1 -and $install_or_not -ne 2)
    } else {
        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host $text_msg.checkpobierakversion03 -ForegroundColor Red
        Write-Host ($text_msg.checkpobierakversion04 + " $version_present") -ForegroundColor Red
        Remove-Item $path_to_temp -Force -Recurse
        Write-Host ""
        Start-Sleep -Seconds 3
        return 2
    }

    if ($install_or_not -eq 1) {
        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host $text_msg.checkpobierakversionupd01

        if ($process_bak_id) {
            Copy-Item -Path "$recources_main_dir\pobierak_bak.ps1" "$recources_main_dir\pobierak_primary.ps1" -Force
        }

        $path_2_pob_pri = "$recources_main_dir\pobierak_primary.ps1"
        if (Test-Path $path_2_pob_pri) {
            if (-not $process_bak_id -and -not $process_bak_primary_id) {
                Remove-Item "$recources_main_dir\pobierak_primary.ps1" -Force
            }
        }

        Copy-Item -Path "$recources_main_dir\pobierak.ps1" "$recources_main_dir\pobierak_bak.ps1" -Force
        Copy-Item -Path "$path_to_temp\pobierak\pobierak4windows-main\resources\pobierak.ps1" "$recources_main_dir\pobierak.ps1" -Force
        Copy-Item -Path "$path_to_temp\pobierak\pobierak4windows-main\*" "$pobierakbat_main_dir\" -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host $text_msg.checkpobierakversionupd02
        Remove-Item $path_to_temp -Force -Recurse

        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host $text_msg.checkpobierakversionupd03
        Write-Host ""
        Start-Sleep -Seconds 5
        Exit 3
    } else {
        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host $text_msg.checkpobierakversion03 -ForegroundColor Red
        Write-Host ($text_msg.checkpobierakversion04 + " $version_present") -ForegroundColor Red
        Remove-Item $path_to_temp -Force -Recurse
        Write-Host ""
        Start-Sleep -Seconds 3
    }
    return $install_or_not
}

# --- Function: download_ffmpeg ---
# Purpose: Download a prebuilt ffmpeg ZIP, extract to resources\ffmpeg, clean up ZIP.
function download_ffmpeg {
	param (
        [int]$daao
    )
    # Target directories
    $ffRoot    = Join-Path $recources_main_dir 'ffmpeg'           	# ...\ffmpeg
    $finalDest = Join-Path $ffRoot 'ffmpeg'                        	# ...\ffmpeg\ffmpeg
    $zipPath   = Join-Path $ffRoot 'ffmpeg.zip'                    	# Download ZIP to ...\ffmpeg\ffmpeg.zip
    $tempExtract = Join-Path $ffRoot '__tmp_extract'               	# Temporary extraction directory

    # Clean up previous installations
    if (Test-Path -LiteralPath $ffRoot) { 
        Remove-Item -LiteralPath $ffRoot -Recurse -Force 
    }

    Write-Host ""
    Start-Sleep -Seconds 1
    Write-Host $text_msg.ffmpgupd00

    # Prepare destination directories
    New-Item -ItemType Directory -Force -Path $ffRoot     | Out-Null
    New-Item -ItemType Directory -Force -Path $finalDest  | Out-Null

    # Download ZIP (BITS) to ...\ffmpeg\ffmpeg.zip
    try {
        Start-BitsTransfer `
            -Source "https://github.com/GyanD/codexffmpeg/releases/download/8.0/ffmpeg-8.0-essentials_build.zip" `
            -Destination $zipPath
    } catch {
        Write-Host "Error downloading FFmpeg. Check your network/URL." -ForegroundColor Red
        return
    }

    Start-Sleep -Seconds 1
    Write-Host ""
    # Keep your two-message format
    Write-Host $text_msg.ffmpgupd01, $text_msg.ffmpgupd02 -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Seconds 1

    try {
        # Clean destination directory (contents only)
        Get-ChildItem -LiteralPath $finalDest -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        # Temporary directory
        if (Test-Path -LiteralPath $tempExtract) {
            Remove-Item -LiteralPath $tempExtract -Recurse -Force
        }
        New-Item -ItemType Directory -Force -Path $tempExtract | Out-Null
        # Extract ZIP to temporary directory
        Expand-Archive -Path $zipPath -DestinationPath $tempExtract -Force

        # Determine root to move:
        #  - if there is exactly one directory and no files at the top level in temp, flatten it (skip that directory),
        #  - otherwise move everything from tempExtract.
        $topDirs = Get-ChildItem -LiteralPath $tempExtract -Force | Where-Object { $_.PSIsContainer }
        $topFilesCount = (Get-ChildItem -LiteralPath $tempExtract -File -Force | Measure-Object).Count

        if ($topDirs.Count -eq 1 -and $topFilesCount -eq 0) {
            $innerRoot = $topDirs[0].FullName
        } else {
            $innerRoot = $tempExtract
        }

        # Move contents (without the first/top folder) to ...\ffmpeg\ffmpeg
        Get-ChildItem -LiteralPath $innerRoot -Force | ForEach-Object {
            Move-Item -LiteralPath $_.FullName -Destination $finalDest -Force
        }

        # Cleanup temporary files/folders
        if (Test-Path -LiteralPath $tempExtract) {
            Remove-Item -LiteralPath $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
        }

        # Remove only this one ZIP (not all *.zip!)
        if (Test-Path -LiteralPath $zipPath) {
            Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue
        }

        # Quick verification
        $ffmpegExe = Join-Path $finalDest 'bin\ffmpeg.exe'
        if (Test-Path -LiteralPath $ffmpegExe) {
            Write-Host "FFmpeg installed: $finalDest" -ForegroundColor Green
        } else {
            Write-Warning "Warning: $ffmpegExe not found. Contents have been moved to: $finalDest (archive structure might have been different)."
        }

        # Final message (with newline)
        Write-Host "$($text_msg.ffmpgupd03)`n$($text_msg.ffmpgupd04)" -ForegroundColor Green
    }
    catch {
        Write-Host " Error during FFmpeg installation/extraction: $($_.Exception.Message)" -ForegroundColor Red
        # Attempt to clean up temporary files/folders
        if (Test-Path -LiteralPath $tempExtract) {
            Remove-Item -LiteralPath $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
        }
        return
    }
	if ($daao -ne 1){
		Start-Sleep -Seconds 3
		Exit 3
	}
}

# --- Function: download_yt_dlp ---
# Purpose: Download latest yt-dlp.exe into resources.
function download_yt_dlp {
	param (
        [int]$daao
    )

    Write-Host ""
    Start-Sleep -Seconds 1
    Write-Host $text_msg.ytdlpupd00 -ForegroundColor Green
    Start-BitsTransfer -Source "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -Destination "$recources_main_dir\yt-dlp.exe" #DOWNLOAD YT-DPL
    Write-Host $text_msg.ytdlpupd01 -ForegroundColor Green
	if ($daao -ne 1) {
		Start-Sleep -Seconds 3
		Exit 3
	}
}

##########################################################################################################
# --- Function: Test-YtDlpStartupVersion ---
# Purpose:
#   Run before the main menu is displayed.
#   If yt-dlp.exe is missing, skip the check and continue to the menu.
#   If the local yt-dlp.exe is older than the latest GitHub release,
#   show a warning and allow the user to update now or continue to the menu.
function Test-YtDlpStartupVersion {
    $localYtDlp = $yt_dlp

    # Safety switch:
    # If yt-dlp.exe is missing, do not block startup.
    # The main menu already shows information about missing required files.
    if (-not (Test-Path -LiteralPath $localYtDlp)) {
        return
    }

    try {
        $localVersionRaw = Get-YtDlpExeVersion -ExePath $localYtDlp
        if ([string]::IsNullOrWhiteSpace($localVersionRaw)) {
            return
        }

        $latestVersionRaw = Get-LatestYtDlpGithubVersion
        if ([string]::IsNullOrWhiteSpace($latestVersionRaw)) {
            return
        }

        $localVersionObj = ConvertTo-YtDlpVersionObject -VersionString $localVersionRaw
        $latestVersionObj = ConvertTo-YtDlpVersionObject -VersionString $latestVersionRaw

        if ($null -eq $localVersionObj -or $null -eq $latestVersionObj) {
            return
        }

        if ($localVersionObj -lt $latestVersionObj) {
            Clear-Host

            Write-Host ""
            Write-Host "------------------------------------------------------------" -ForegroundColor Red
            Write-Host $text_msg.warn_ytdlp00 -ForegroundColor Red
            Write-Host "------------------------------------------------------------" -ForegroundColor Red
            Write-Host ""
            Write-Host $text_msg.warn_ytdlp01 "$localVersionRaw" -ForegroundColor Yellow
            Write-Host $text_msg.warn_ytdlp02 "$latestVersionRaw" -ForegroundColor Green
            Write-Host ""
            Write-Host $text_msg.warn_ytdlp03 -ForegroundColor Red
            Write-Host $text_msg.warn_ytdlp04 -ForegroundColor Red
            Write-Host ""
            Write-Host $text_msg.warn_ytdlp05 -ForegroundColor Green
            Write-Host $text_msg.warn_ytdlp06 -ForegroundColor Yellow
            Write-Host ""

            do {
                $choiceRaw = Read-Host -Prompt $text_msg.warn_ytdlp07
                $choice = 0
                $ok = [int]::TryParse($choiceRaw, [ref]$choice)
            } until ($ok -and ($choice -eq 1 -or $choice -eq 2))

            if ($choice -eq 1) {
                # Use the existing update function.
                # Parameter -daao 1 prevents download_yt_dlp from calling Exit 3.
                download_yt_dlp -daao 1

                Write-Host ""
                Write-Host $text_msg.warn_ytdlp08 -ForegroundColor Green
                Start-Sleep -Seconds 2
            }
        }
    }
    catch {
        # If there is no internet connection, GitHub is unavailable,
        # or the version cannot be checked, do not block the application.
        return
    }
}
###############################################################################################

# --- Function: download_all_at_once ---
# Purpose: Run version check, download ffmpeg and yt-dlp, then request restart (rc=3).
function download_all_at_once {
	$down_all_at_one = 1
    $install_or_not = check_pobierak_version
    download_ffmpeg -daao $down_all_at_one
    download_yt_dlp -daao $down_all_at_one
    Write-Host ""
    $text_msg.allinone00 | Out-Host
    Start-Sleep -Seconds 1
    $text_msg.checkpobierakversionupd03 | Out-Host
    Write-Host ""
    Start-Sleep -Seconds 5
    Exit 3
}

# --- Function: previous_version ---
# Purpose: Restore previous pobierak.ps1 from backup if the user chooses so.
function previous_version {
    do {
        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host $text_msg.previousversion00 -ForegroundColor Yellow
        $prev = Read-Host -Prompt $text_msg.checkpobierakversion02
        [int]$prev = $prev
    } while ($prev -ne 1 -and $prev -ne 2)

    if ($prev -eq 1) {
        Start-Sleep -Seconds 1
        Write-Host ""
        Write-Host $text_msg.previousversion01 -ForegroundColor Green
        Start-Sleep -Seconds 1
        Write-Host ""
        Copy-Item -Path "$recources_main_dir\pobierak_bak.ps1" "$recources_main_dir\pobierak.ps1" -Force
        Start-Sleep -Seconds 1
        Write-Host ""
        Write-Host $text_msg.previousversion02 -ForegroundColor Green
        Start-Sleep -Seconds 1
        Write-Host ""
        Start-Process "$pobierakbat_main_dir\pobierak.bat" | Out-Null
        Start-Sleep -Seconds 1
        Exit 0
    } else {
        Write-Host $text_msg.previousversion03 -ForegroundColor Red
        Start-Sleep -Seconds 3
        main_menu
    }
}

# --- Function: Show_updates_Menu ---
# Purpose: Render the updates menu banner and contextual warnings.
function Show_updates_Menu {
    Clear-Host
    Write-Host ("{0}{1}" -f (' ' * ([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2))), $text_msg.updmenu00) -ForegroundColor Green -NoNewline
    Write-Host "$pobierak_v" -ForegroundColor Yellow

    if ($missing_exe -gt 0) {
        $ULine = $UnderlineChar * ($text_msg.optionwithoutexe2.Length + $text_msg.optionwithoutexe3.Length)
        Write-Host $ULine -ForegroundColor Red
        Write-Host $text_msg.optionwithoutexe2 -ForegroundColor Red
        Write-Host $text_msg.optionwithoutexe3 -ForegroundColor Red
        Write-Host $ULine -ForegroundColor Red
    }

    Write-Host ""
    Write-Host $text_msg.updmenu01 -ForegroundColor Magenta
    Write-Host ""
    Write-Host $text_msg.updmenu02 -ForegroundColor Magenta
    Write-Host ""
    Write-Host $text_msg.updmenu03 -ForegroundColor Magenta
    Write-Host ""
    Write-Host $text_msg.updmenu04 -ForegroundColor Yellow
    Write-Host ""
    Write-Host $text_msg.updmenu05 -ForegroundColor Magenta
    Write-Host ""
    Write-Host $text_msg.updmenu06 -ForegroundColor White
}

# --- Function: updates_menu ---
# Purpose: Updates submenu loop handling actions 1..6.
function updates_menu {
    do {
        Show_updates_Menu
        Start-Sleep -Seconds 1
        Write-Host ""
        do {
            Write-Host $text_msg.updmenu07 -ForegroundColor Green
            $selection_update = Read-Host -Prompt $text_msg.updmenu08
            [int]$selection_update = $selection_update
        } until ($selection_update -gt 0 -and $selection_update -lt 7)

        switch ($selection_update) {
            1 { check_pobierak_version | Out-Null }
            2 { download_ffmpeg }
            3 { download_yt_dlp }
            4 { download_all_at_once }
            5 { previous_version }
            6 { main_menu; return }
        }
        Pause
    } until ($selection_update -ne 6 -and $selection_update -gt 0)
}

# ------------------------------------------------------------------------------
# --- Function: Split-CommandLine ---
# Purpose: Windows-native command line splitter using CommandLineToArgvW.
# Params: [string] Line - raw command line.
# Returns: [string[]] argv-compatible array.
function Split-CommandLine {
    param([Parameter(Mandatory)][string]$Line)

    # Windows-native split (zachowuje cudzysłowy i spacje jak w argv)
    $count = 0
    $ptr = [Win32.Native]::CommandLineToArgvW($Line, [ref]$count)
    if ($ptr -eq [IntPtr]::Zero) { return @() }

    try {
        $result = New-Object string[] $count
        for ($i=0; $i -lt $count; $i++) {
            $argPtr = [System.Runtime.InteropServices.Marshal]::ReadIntPtr($ptr, $i * [IntPtr]::Size)
            $result[$i] = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($argPtr)
        }
        return $result
    } finally {
        [void][Win32.Native]::LocalFree($ptr)
    }
}

# --- Dev mode for yt-dlp -------------------------------------------------------
# --- Function: youtube_dlp_dev ---
# Purpose: A small REPL to run yt-dlp with arbitrary arguments; supports help/quit shortcuts.
function youtube_dlp_dev {
    Clear-Host
    Write-Host $text_msg.ytdlpdevintro01 -ForegroundColor Yellow
    Write-Host $text_msg.ytdlpdevintro02 -ForegroundColor Yellow
    Write-Host $text_msg.ytdlpdevintro03 -ForegroundColor Yellow

    while ($true) {
        Write-Host ""
        Start-Sleep -Milliseconds 200

        $line = Read-Host -Prompt $text_msg.ytdlpdev01
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        # Helper commands
        if ($line -match '^(quit|exit)$') { break }
        if ($line -match '^(help|--help)$') { & $yt_dlp --help; continue }

        # Split into argv
        $args = Split-CommandLine -Line $line
        if (-not $args -or $args.Count -eq 0) { continue }

        # If the user typed 'yt-dlp' or an executable path at the beginning – remove it
        $firstLeaf = (Split-Path $args[0] -Leaf)
        if ($firstLeaf -match '^yt-dlp(\.exe)?$') {
            if ($args.Count -gt 1) { $args = $args[1..($args.Count-1)] } else { $args = @() }
        }

        try {
            # Run in the same console to see stdout/stderr
            & $yt_dlp @args
        }
        catch {
            Write-Host "yt-dlp failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host $text_msg.ytdlpdev02 -ForegroundColor Green
}


# ------------------------------------------------------------------------------
# MAIN MENU
# --- Function: main_menu ---
# Purpose: Main application loop displaying menu and dispatching choices.
function main_menu {
    function Show-Menu {
        Clear-Host
        Write-Host ("{0}{1}" -f (' ' * ([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2))), $text_msg.mainmenu00) -ForegroundColor Green -NoNewline
        Write-Host "$pobierak_v" -ForegroundColor Yellow
        Write-Host ""
        internal_info 0
        play_sound
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu01)" -ForegroundColor Magenta
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu02)" -ForegroundColor Yellow
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu03)" -ForegroundColor Magenta
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu04)" -ForegroundColor Yellow
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu05)" -ForegroundColor Magenta
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu06)" -ForegroundColor Yellow
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu07)" -ForegroundColor Magenta
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu08)" -ForegroundColor Red
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu09)" -ForegroundColor White	
		Write-Host ""
		Write-Host "`t$($text_msg.mainmenu10)" -ForegroundColor White	
        

    }

    do {
        Show-Menu
        Start-Sleep -Seconds 1
        Write-Host ""
        do {
            Write-Host $text_msg.mainmenu98 -ForegroundColor Green
            $selection = Read-Host -Prompt $text_msg.mainmenu99
            [int]$selection = $selection
        } until ($selection -gt 0 -and $selection -lt 12)

        switch ($selection) {
            1 { download_song }
            2 { download_from_list }
            3 { download_playlist }
            4 { download_channel }
            5 { download_movie_and_or_music_from_list }
            6 { download_movie_and_or_music_from_list_PLAYLIST_AND_CHANNEL }
            7 { download_from_cookie }
            8 { updates_menu }
			9 { Change-Language }
            10 { [Environment]::Exit(0) }
			11 { youtube_dlp_dev }
        }
        Pause
    } until ($selection -eq 11)
}

# ------------------------------------------------------------------------------
# Start
#main_menu

try {
    Test-YtDlpStartupVersion
    main_menu
}
catch {
    Write-Host ""
    Write-Host "FATAL ERROR in pobierak.ps1" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "ScriptStackTrace:" -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace
    exit 1
}
