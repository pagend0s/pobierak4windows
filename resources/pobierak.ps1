$pobierak_v = "3.1"
#GET SYS LANG
function get_lang(){
	$regkey = "HKCU:\Control Panel\Desktop"
	$name = "PreferredUILanguages"
	$get_lang = (Get-ItemProperty $regkey).PSObject.Properties.Name -contains $name
	if ( $get_lang -eq $false )
		{
			$lang = (Get-WinUserLanguageList).LocalizedName
		}
	else
		{
			$lang = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' PreferredUILanguages).PreferredUILanguages[0]
		}
	return $lang
}
#$sys_lang = "Polski"
[string]$language = get_lang
#SYS LANG IF PL THEN PL IF OTHER THEN EN

if (( $language -eq "pl-PL" ) -or ( $language -eq "Polski"))
    {
        $sys_lang = "PL"
    }
else
    {
        $sys_lang = "EN"
    }
	
#VAR OF CURRENTLY LOGGED USER
$logged_usr = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).Split('\')[1]

#CLEAR MAIN VAR
$recources_main_dir = $null
$pobierakbat_main_dir = $null
$yt_dlp = $null
$ffmpeg = $null
$process_bak_primary_id = $null
$process_bak_id = $null

#GET POBIERAK PROCESS PID IF ACTIV FOR EVENTUALLY ERROR DETECTION
$process_bak_primary_id = Get-CimInstance Win32_Process | where commandline -match 'pobierak_primary.ps1'  | Select ProcessId | ForEach-Object {$_ -replace '\D',''}
$process_bak_id = Get-CimInstance Win32_Process | where commandline -match 'pobierak_bak.ps1'  | Select ProcessId | ForEach-Object {$_ -replace '\D',''}

#SET MAIN DIR 
$recources_main_dir =  Split-Path $PSCommandPath -Parent
#SET RECOURCES DIR
$pobierakbat_main_dir =  $recources_main_dir -replace 'Resources',''
#SET YT-DLP LOCATION
$yt_dlp = "$recources_main_dir\yt-dlp.exe"
#SET ffmpeg LOCATION
$ffmpeg = "$recources_main_dir\ffmpeg\bin\ffmpeg.exe"

function play_sound(){
	
	$PlayWav=New-Object System.Media.SoundPlayer

	$PlayWav.SoundLocation="$recources_main_dir\Bottle.wav"

	$PlayWav.playsync()
	
}


#FUNCTION TO DISPLAY MAIN INFORMATION IN FIRST MENU
Function internal_info(){
	#YTDLP EXE EXIST ?
	if (Test-Path $yt_dlp) 
		{
			if ( $sys_lang -eq "PL" )
				{
					$yt_dlp_ver_1 = $(write-host "AKTUALNA WERSJA YOUTUBE-DLP: " -NoNewLine -ForegroundColor yellow ) + $( Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--version" )
				}
			else
				{
					$yt_dlp_ver_1 = $(write-host "CURRENT VERSION OF YOUTUBE-DLP: " -NoNewLine -ForegroundColor yellow ) + $( Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--version" )
				}
		}
	#RESOURCES TEST ARRAY VAR
	$recources_test= @()
	$recources_test[0]
	#VARIABLES FOR TEST IF NECESSARY EXE EXISTS
	$test_resource_ffmpeg_if_exist = "$recources_main_dir\ffmpeg"
	$test_resource_yt_dlp_if_exist = "$recources_main_dir\yt-dlp.exe"
	#IF TEST VER ARE EMPTY THEN IS NO ERROR ELSE THERE IS A PROBLEM WITH MAIN SCRIPT
	if (( $process_bak_id -eq $null -and $process_bak_primary_id -eq $null ))
		{
			$critical_update_error = " "		
		}
	else
		{
			if ( $sys_lang -eq "PL" )
				{
					$critical_update_error = ( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "PO AKTUALIZACJI WYKRYTO BLAD KRYTYCZNY. SPROBUJ SKONTAKTOWAC SIE Z PAGEND0SEM " ) -ForegroundColor RED )
				}
			else
				{
					$critical_update_error = ( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "THERE HAS BEEN A CRITICAL ERROR DETECTED AFTER THE UPDATE. TRY TO CONTACT WITH PAGEND0S " ) -ForegroundColor RED )
				}			
			$recources_test += ," $critical_update_error" #ADD TO ARRAY INFO ABOUT CRITICAL ERROR IF EXIST
		}
	#TEST IF FFMPEG IS ALREADY DOWNLOADED
	if (Test-Path $test_resource_ffmpeg_if_exist) 
		{
			$resource_ffmpeg = " "
			$recources_test += ," $resource_ffmpeg"                   
		}
	else
		{
			if ( $sys_lang -eq "PL" )
				{
					$warning_missing_resource = ( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "UWAGA UWAGA UWAGA" ) -ForegroundColor RED )
					$resource_ffmpeg = ( $(write-host " ! BIBLIOTEKA FFMPEG NIE JEST SCIAGNIETA !." -ForegroundColor Red ) + $( write-host " W CELU POPRAWNEGO DZIALANIA POBIERAKA UZYJ OPCJI NR 8 I Z MENU AKTUALIZACJI OPCJE NR 2 LUB 4" -ForegroundColor Red ) + $( write-host ""; ))            
				}
			else
				{
					$warning_missing_resource = ( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "WARNING WARNING WARNING" ) -ForegroundColor RED )
					$resource_ffmpeg = ( $(write-host " ! THE FFMPEG LIBRARY IS NOT DOWNLOADED !." -ForegroundColor Red ) + $( write-host " FOR THE CORRECT FUNCTIONING OF POBIERAK, USE OPTION NO.8 AND FROM THE UPDATE MENU OPTIONS NO.2 OR NO.4" -ForegroundColor Red ) + $( write-host ""; ) )					
				}
						
			$recources_test += ," $warning_missing_resource"
			$recources_test += ," $resource_ffmpeg"
		}
	#TEST IF YTDLP IS ALREADY DOWNLOADED
	if (Test-Path $test_resource_yt_dlp_if_exist) 
		{
			$resource_yt_dlp = " "
			$recources_test += ," $resource_yt_dlp"                   
		}
	else
		{
			if ( $sys_lang -eq "PL" )
				{
					$warning_missing_resource = ( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "UWAGA UWAGA UWAGA" ) -ForegroundColor RED )
					$resource_yt_dlp = ( $(write-host " ! YOUTUBE-DLP NIE JEST POBRANY !." -ForegroundColor Red ) + $( write-host " W CELU POPRAWNEGO DZIALANIA POBIERAKA UZYJ OPCJI NR 8 I Z MENU AKTUALIZACJI OPCJE NR 3 LUB 4" -ForegroundColor Red ) + $( write-host ""; ) )
				}
			else
				{
					$warning_missing_resource = ( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "WARNING WARNING WARNING" ) -ForegroundColor RED )
					$resource_yt_dlp = ( $(write-host " ! YOUTUBE-DLP IS NOT DOWNLOADED !." -ForegroundColor Red ) + $( write-host " FOR THE CORRECT FUNCTIONING OF POBIERAK, USE OPTION NO.8 AND FROM THE UPDATE MENU OPTIONS NO.3 OR NO.4" -ForegroundColor Red ) + $( write-host ""; ) )
				}
			$recources_test += ," $warning_missing_resource"
			$recources_test += ," $resource_yt_dlp"
		}
	#RETURN INFO ABOUT DETECTED ERRORS OR NOT
	Return ,$recources_test

}
#GUI NOTIFICATION ABOUT THE NEED TO SELECT A FILE CONTAINING LINKS TO YT
Function warning_select_file(){
	if ( $sys_lang -eq "PL" )
		{
			#LOAD GUI WINDOW IN CONSTRUCT BLOCK
			[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null;
			#PROMT MESSAGE
			[System.Windows.Forms.MessageBox]::Show('WYBIERZ DOCELOWY PLIK Z WKLEJONYMI LINKAMI Z YOUTUBE','WARNING')
		}
	else
		{	#LOAD GUI WINDOW IN CONSTRUCT BLOCK
			[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null;
			#PROMT MESSAGE
			[System.Windows.Forms.MessageBox]::Show('CHOOSE YOUR TARGET FILE WITH LINKS FROM YOUTUBE','WARNING')			
		}
}
#FUNCTION TO CALCULATE AVAILABLE SPACE IN A TARGET DIR FOR DOWNLOADED MULTIMEDIA
function Get-FreeSpace {
    Param(
        $path = $output_directory #PATH TO CHOOSEN DIR
    );
    [double]$free = Get-WmiObject Win32_Volume -Filter "DriveType=3" |
            Where-Object { $path -like "$($_.Name)*" } |
            Sort-Object Name -Desc |
            Select-Object -First 1 FreeSpace |
            ForEach-Object { $_.FreeSpace / (1024*1024*1024) }
            
    return ([math]::round($free,2))
}
#FUNCTION TO POINT THE DESTINATION DIR FOR DOWNLOADED MULTIMEDIA WITH WINDOWS FILE EXPLORER GUI
Function Select-Folder
{
	param([string]$Description="Select Folder",[string]$RootFolder="Desktop")

	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null 
	if ( $sys_lang -eq "PL" )
		{
			$objForm = New-Object System.Windows.Forms.FolderBrowserDialog
			$Description = "WSKARZ MIEJSCE DOCELOWE DLA SCIAGNIETYCH MULTIMEDIOW"
			$objForm.Rootfolder = $RootFolder
			$objForm.Description = $Description
			$Show = $objForm.ShowDialog()
			If ($Show -eq "OK")
				{
					Return $objForm.SelectedPath
				}
			Else
				{
					Write-Error "Operation cancelled by user."
				}
		}
	else
		{  
			$objForm = New-Object System.Windows.Forms.FolderBrowserDialog
			$Description = "SET THE DESTINATION FOR DOWNLOADED MULTIMEDIA FILES"
			$objForm.Rootfolder = $RootFolder
			$objForm.Description = $Description
			$Show = $objForm.ShowDialog()
			If ($Show -eq "OK")
				{
					Return $objForm.SelectedPath
				}
			Else
				{
					Write-Error "Operation cancelled by user."
				}
		}
    }
#FUNCTION TO SELECT FILE WITH LINKS TO DOWNLOAD WITH WINDOWS FILE EXPLORER GUI
 function Select-File {
    param([string]$Directory = $PWD)

    $dialog = [System.Windows.Forms.OpenFileDialog]::new()

    $dialog.InitialDirectory = (Resolve-Path $Directory).Path
    $dialog.RestoreDirectory = $true

    $result = $dialog.ShowDialog()

    if($result -eq [System.Windows.Forms.DialogResult]::OK){
        return $dialog.FileName
  }
}
#FILTER OUT ENTERED OR PARSED LINK AND SEARCH FOR PLAYLIST OR CHANNEL IN IT
function filter_links(){
	if ( $sys_lang -eq "PL" )
		{
			$ignore_link = 0
			#SEARCH PATTERN FOR PLAYLIST
			$yt_link_filter_plli = $testlink | Select-String -pattern "&list"
			#FILTER YT LINK TO FIND REFERENCESS TO CHANNEL OR PLAYLISTS
			$yt_link_filter_channel = $testlink | Select-String -pattern "channel"				
			#SEARCH PATTERN FOR CHANNEL AND &ab_channel	
			$yt_link_filter_ab_channel = $testlink | Select-String -pattern "&ab_channel"
			#IF &ab_channel IS DETECTED - CORRECT IT TO DOWNLOAD ONE TRACK LINK
			if (( $yt_link_filter_ab_channel -ne $null ) -and ( $yt_link_filter_plli -eq $null ))
				{
					$pattern = '(?<=\=).+?(?=\&)'	#SEARCH FOR PATTERN: START = AND &
					$singel_link_after_filter = [regex]::Matches($yt_link_filter_ab_channel, $pattern).Value | Select-Object -First 1 #SELECT FIRST MATH AFTER PATTERN
					$correct_single_link = "https://www.youtube.com/watch?v=$singel_link_after_filter" #PASTE TO https://www.youtube.com/watch?v= THE FIRST MATCH
					write-host "--------------------------------------------------------------------------"
					Start-Sleep -Milliseconds 500
					write-host "W LINKU POBIERAK ODKRYŁ ODNIESIENIE DO CAŁEGO KANAŁU!" -ForegroundColor Red
					write-host ""
					Start-Sleep -Milliseconds 500
					$(write-host "ZOSTANIE ON SKORYGOWANY DO: " -ForegroundColor Green -nonewline ) + $( write-host "$correct_single_link" -ForegroundColor YELLOW ; )
					write-host ""
					Start-Sleep -Milliseconds 500
					write-host "JESLI CHODZI CI O SCIAGNIECIE CALEJ PLAYLISTY TO UZYJ OPCJI Z MENU NR: 4 LUB 6" -ForegroundColor Magenta
					write-host "--------------------------------------------------------------------------"
					$correct_single_link >> "$recources_main_dir\songs_out.txt"
					$ignore_link = 1
				}
			#IF channel IS DETECTED - IGNORE THE LINK
			if (( $yt_link_filter_channel -ne $null ) -and ($yt_link_filter_ab_channel -eq $null ))
				{
					write-host "--------------------------------------------------------------------------------------------------------"
					Start-Sleep -Milliseconds 500
					write-host "W LINKU ZNAJDUJE SIE PODFOLDER CHANNEL CO BEDZIE SKUTKOWALO SCIAGNIECIEM CALEGO KANALU!" -ForegroundColor Red
					write-host ""
					Start-Sleep -Milliseconds 500
					write-host "ZOSTANIE ON ZIGNOROWANY." -ForegroundColor Red
					write-host ""
					Start-Sleep -Milliseconds 500
					write-host "JESLI MAM SCIAGNAC POJEDYNCZA SCIEZKE AUDIO TO WSKAZ LINK BEZ CZESCI (PODFOLDERU) = channel = ." -ForegroundColor Magenta
					write-host ""
					Start-Sleep -Milliseconds 500
					write-host "W PRZECIWNYM RAZIE UZYJ OPCJI NR 4 LUB 6 Z MENU." -ForegroundColor Green
					write-host "--------------------------------------------------------------------------------------------------------"
					$ignore_link = 1
				}
			if ($yt_link_filter_plli -ne $null )
				{
					#IF THE PLAYLIST IS DETECTED, CORRECT IT TO DOWNLOAD ONE TRACK LINK
					$pattern = '(?<=\=).+?(?=\&)'	#SEARCH FOR PATTERN: START = AND &
					$singel_link_after_filter = [regex]::Matches($yt_link_filter_plli, $pattern).Value | Select-Object -First 1	#SELECT FIRST MATH AFTER PATTERN
					$correct_single_link = "https://www.youtube.com/watch?v=$singel_link_after_filter"
					write-host "--------------------------------------------------------------------------"
					Start-Sleep -Milliseconds 500
					write-host "W LINKU WYKRYLEM ODNOSNIK DO CALEJ PLAYLISTY !" -ForegroundColor Red
					write-host ""
					Start-Sleep -Milliseconds 500
					$(write-host "ZOSTANIE ON SKORYGOWANY DO: " -ForegroundColor Green -nonewline ) + $( write-host "$correct_single_link" -ForegroundColor YELLOW ; )
					write-host ""
					Start-Sleep -Milliseconds 500
					write-host "JESLI CHODZI CI O SCIAGNIECIE CALEJ PLAYLISTY TO UZYJ OPCJI Z MENU NR: 3 LUB 6" -ForegroundColor Magenta
					write-host "--------------------------------------------------------------------------"
					$correct_single_link >> "$recources_main_dir\songs_out.txt"
					$ignore_link = 1
				}
			#IF NONE OF ABOVE ARE DETECTED - WRITE LINK TO FILE
			if	(( $ignore_link -ne 1  ))
				{
					$testlink >>	"$recources_main_dir\songs_out.txt"
				}
							
		}	
	else
		{
			#SEARCH PATTERN FOR PLAYLIST
			$ignore_link = 0
			#FILTER YT LINK TO FIND REFERENCESS PLAYLISTS
			$yt_link_filter_plli = $testlink | Select-String -pattern "&list"
			#FILTER YT LINK TO FIND REFERENCESS TO CHANNEL
			$yt_link_filter_channel = $testlink | Select-String -pattern "channel"
			#SEARCH PATTERN FOR &ab_channel
			$yt_link_filter_ab_channel = $testlink | Select-String -pattern "&ab_channel"
			#IF &ab_channel IS DETECTED AND NO PLAYLIST - CORRECT IT TO DOWNLOAD ONE TRACK LINK
				if (( $yt_link_filter_ab_channel -ne $null ) -and ( $yt_link_filter_plli -eq $null ) )
					{
						$pattern = '(?<=\=).+?(?=\&)'
						$singel_link_after_filter = [regex]::Matches($yt_link_filter_ab_channel, $pattern).Value | Select-Object -First 1
						$correct_single_link = "https://www.youtube.com/watch?v=$singel_link_after_filter"
						write-host "--------------------------------------------------------------------------"
						Start-Sleep -Milliseconds 500
						write-host "IN THE LINK, POBIERAK DISCOVERED THE REFERENCE TO THE ENTIRE CHANNEL!" -ForegroundColor Red
						write-host ""
						Start-Sleep -Milliseconds 500
						$(write-host "IT WILL BE CORRECTED TO: " -ForegroundColor Green -nonewline ) + $( write-host "$correct_single_link" -ForegroundColor YELLOW ; )
						write-host ""
						Start-Sleep -Milliseconds 500
						write-host "IF YOU WANT TO DOWNLOAD THE ENTIRE CHANNEL, USE THE OPTIONS FROM THE MENU NO: 4 OR 6" -ForegroundColor Magenta
						write-host "--------------------------------------------------------------------------"
						$correct_single_link >> "$recources_main_dir\songs_out.txt"
						$ignore_link = 1
												
					}
				#IF channel IS DETECTED - IGNORE THE LINK
				if (( $yt_link_filter_channel -ne $null ) -and ($yt_link_filter_ab_channel -eq $null ))
					{
						write-host "--------------------------------------------------------------------------------------------------------"
						Start-Sleep -Milliseconds 500
						write-host "THERE IS A CHANNEL SUBFOLDER IN THE LINK, WHICH WILL DOWNLOAD THE ENTIRE CHANNEL!" -ForegroundColor Red
						write-host ""
						Start-Sleep -Milliseconds 500
						write-host "THIS LINK WILL BE IGNORED BECAUSE IT CANNOT BE CORRECTED" -ForegroundColor Red
						write-host ""
						Start-Sleep -Milliseconds 500
						write-host "IF POBIERAK SHOULD DOWNLOAD A SINGLE AUDIO, PASTE LINK WITHOUT A PART (SUBFOLDER) = channel =." -ForegroundColor Magenta
						write-host ""
						Start-Sleep -Milliseconds 500
						write-host "OTHERWISE USE OPTION 4 OR 6 FROM THE MENU." -ForegroundColor Green
						write-host "--------------------------------------------------------------------------------------------------------"
						$ignore_link = 1
					}
				if ($yt_link_filter_plli -ne $null )
					{
						$pattern = '(?<=\=).+?(?=\&)'
						$singel_link_after_filter = [regex]::Matches($yt_link_filter_plli, $pattern).Value | Select-Object -First 1
						$correct_single_link = "https://www.youtube.com/watch?v=$singel_link_after_filter"
						write-host "--------------------------------------------------------------------------"
						Start-Sleep -Milliseconds 500
						write-host "IN THE LINK, POBIERAK DISCOVERED THE REFERENCE TO THE ENTIRE PLAYLIST!" -ForegroundColor Red
						write-host ""
						Start-Sleep -Milliseconds 500
						$(write-host "IT WILL BE CORRECTED TO: " -ForegroundColor Green -nonewline ) + $( write-host "$correct_single_link" -ForegroundColor YELLOW ; )
						write-host ""
						Start-Sleep -Milliseconds 500
						write-host "IF YOU WANT TO DOWNLOAD THE ENTIRE PLAYLIST, USE THE OPTIONS FROM THE MENU NO: 3 OR 6" -ForegroundColor Magenta
						write-host "--------------------------------------------------------------------------"
						$correct_single_link >> "$recources_main_dir\songs_out.txt"
						$ignore_link = 1
					}
				#IF NONE OF ABOVE ARE DETECTED = LINK IS OK - WRITE LINK TO FILE
				if	(( $ignore_link -ne 1 ))
					{
						$testlink >>	"$recources_main_dir\songs_out.txt"
					}
		}
	
}
#FUNCTION TO GET AUDIO QUALITY
function audio_quality(){
	if ( $sys_lang -eq "PL" )
		{
			do
				{	#GET INPUT WITH AUDIO QUALITY OUT VALUES - 128 kbps or 320 kbps
					Write-Host ""
					SLEEP 1
					[string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 320K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
				}while(($quality -ne "128K"  ) -and ($quality -ne "320K"))
		}
	else
		{
				
			do
				{	#GET INPUT WITH AUDIO QUALITY OUT VALUES - 128 kbps or 320 kbps
					Write-Host ""
					SLEEP 1
					[string]$quality = $(Write-Host "ENTER THE VALUE FOR THE QUALITY IN WHICH THE SONG WILL BE CONVERTED. " -ForegroundColor green -NoNewLine) + $(Write-Host "CORRECT VALUES ARE: 128K OR 320K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
				}while(($quality -ne "128K"  ) -and ($quality -ne "320K"))
			write-host "JAKOSC : $quality"
		}
	return [string]$quality
	
}
##############################################################################
#1 FUNCTION TO DOWNLOAD FROM LINKS BY ENTERING THEM IN CONSOLE ONE BY ONE #1 #
##############################################################################
function download_song(){
cls
	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			sleep 1
			Write-Host "WYBRALES OPCJE NUMER 1. POBIERANIE AUDIO Z YT ZA POMOCA POJEDYNCZYCH LINKOW SKOPIOWANYCH DO TERMINALA." -ForegroundColor Yellow
		}
	else
		{
			write-host ""
			sleep 1
			Write-Host "YOU HAVE CHOOSEN OPTIONS NUMBER 1. DOWNLOADING AUDIO FROM YT USING SINGLE LINKS COPIED INTO THE TERMINAL." -ForegroundColor Yellow
		}
	#TEST IF OLD  LIST WITH LINK EXIST - IF SO - THEN REMOVE
	$path2song_list_single = "$recources_main_dir\songs_out.txt"
	If (Test-Path $path2song_list_single)
		{
			Remove-Item -Path $path2song_list_single
		}
	if ( $sys_lang -eq "PL" )
		{
			#DO LOOP FOR ENTER LINKS FROM YOUTUBE
			do
				{
					SLEEP 1
					#GET INPUT WITH YT LINK
					Write-Host ""
					[string]$s = $(Write-Host "PODAJ KOMPLETNY LINK Z YOUTUBE NP (https://www.youtube.com/watch?v=XmaaSK19jGQ)" -ForegroundColor green) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor green) + $(Write-Host "W CELU PRZEZWANIA WPISZ q i WSCISNIJ enter: " -ForegroundColor red; Read-Host)
					if ( $s -eq "q" )
						{
						}
					else
						{
							#VAR WITH YT LINK TO FILTER REFERENCES TO A CHANNEL OR PLAYLIST
							$testlink = "$s"
							filter_links $testlink							
						}
				}until($s -eq "q"  )

			[string]$quality = audio_quality
			
			#VAR WITH ENTERED YT LINKS
			$c = Get-Content -Path "$recources_main_dir\songs_out.txt" | Where { $_ }
            ##$c = $c.trim() -ne ""
			#LINES COUNTER
			$lines_var = Get-Content "$recources_main_dir\songs_out.txt" | Where { $_ }
			##$lines_var = $lines_var.trim() -ne ""
    		[int]$lines_var = $lines_var.Count
			#PATH TO OUTPUT DIR
			$output_directory = Select-Folder
			$free_space = Get-FreeSpace
			sleep 1
			write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
			sleep 2
			#SHOW OWER EXPLORER THE TARGET DIR
			Start explorer.exe $output_directory
			[int]$lines_var+=1
			[int]$xyz=1
			#MAIN LOOP TO DOWNLOAD ENTERED AND CORRECTED SONGS FROM YT LINKS
			ForEach ($a in $c) 
				{
					$song_left = [int]$xyz++ #COUNTER FOR SONGS TO DOWNLOAD
					[int]$lines_var-= 1 #SUB - HOW MANY LEFT
					write-host "ZACIAGANIE AUDIO LINK NR: $song_left . POZOSTALO: $lines_var ." -ForegroundColor yellow
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $a"
				}
			#REMOVE PATH WITH SONG LIST CREATED AFTER DOWNLOAD LOOP
			Remove-Item -Path "$recources_main_dir\songs_out.txt" -Force

			write-host ""
			Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
		}
	else
		{	#DO LOOP FOR ENTERED LINKS FROM YOUTUBE
			do
				{
					SLEEP 1
					#GET INPUT WITH YT LINK
					Write-Host ""
					[string]$s = $(Write-Host "ENTER THE COMPLETE LINK FROM YOUTUBE E.G. (https://www.youtube.com/watch?v=XmaaSK19jGQ)" -ForegroundColor green) + $(Write-Host "SIMPLY: COPY FROM THE BROWSER AND PRESS THE RIGHT KEY ON THE TERMINAL." -ForegroundColor green) + $(Write-Host "TO INTERRUPT, ENTER q and PRESS enter: " -ForegroundColor red; Read-Host)
					if ( $s -eq "q" )
						{
						}
					else
						{	#VAR WITH YT LINK TO FILTER REFERENCES TO A CHANNEL OR PLAYLIST
							$testlink = "$s"
							filter_links $testlink			
						}         

				}until($s -eq "q"  )

			[string]$quality = audio_quality
			#VAR WITH ENTERED YT LINKS
			$c = Get-Content -Path "$recources_main_dir\songs_out.txt" | Where { $_ }
			#LINES COUNTER
			$lines_var = Get-Content "$recources_main_dir\songs_out.txt" | Where { $_ }
			[int]$lines_var = $lines_var.Count
			#PATH TO OUTPUT DIR
			$output_directory = Select-Folder
			$free_space = Get-FreeSpace
			sleep 1
			write-host = "FREE SPACE IN TARGET DIRECTORY: $free_space GB." -ForegroundColor Yellow
			sleep 2
			#SHOW OWER WINDWOS EXPLORER THE TARGET DIR
			Start explorer.exe $output_directory
			#[int]$lines_var+=1
			[int]$xyz=1

			#MAIN LOOP TO DOWNLOAD ENTERED AND CORRECTED SONGS FROM YT LINKS
			ForEach ($a in $c) 
				{
					$song_left = [int]$xyz++	#COUNTER FOR SONGS TO DOWNLOAD
					[int]$lines_var-= 1	#SUB - HOW MANY LEFT
					write-host "PULLING AN AUDIO LINK NR: $song_left . REMAIN: $lines_var ." -ForegroundColor yellow
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $a"
				}
			#REMOVE PATH WITH SONG LIST CREATED AFTER DOWNLOAD LOOP
			Remove-Item -Path "$recources_main_dir\songs_out.txt" -Force

			write-host ""
			Write-Host "THE DOWNLOAD PROCESS IS DONE." -ForegroundColor Green -NoNewline
		
		}

}
#######################################################################
#2 FUNCTION TO DOWNLOAD FROM LINKS WHICH ARE ALREADY SAVED IN FILE #2 #
#######################################################################
Function download_from_list(){
    cls
	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			sleep 1
			Write-Host "	WYBRALES OPCJE NUMER 2. POBIERANIE AUDIO Z YT ZA POMOCA LINKOW ZNAJDUJACYCH SIE W PLIKU." -ForegroundColor Yellow
			write-host ""
			sleep 1
		}
	else
		{
			write-host ""
			sleep 1
			Write-Host "	YOU HAVE CHOOSEN OPTIONS NUMBER 2. DOWNLOADING AUDIO FROM YT USING LINKS FROM A FILE." -ForegroundColor Yellow
			write-host ""
			sleep 1
		}
	#GET A PATH TO FILE FROM THE EXPLORER GUI THAT CONTAINS PREVIOUS SAVED LINKS TO YT INTO VAR $selected_file_var
    warning_select_file
    $selected_file_var = Select-File
	#REMOVE EMPTY LINES IF EXIST
    $d = Get-Content -Path $selected_file_var | Where { $_ }
	##$d = $d.trim() -ne ""
                           
	foreach ( $line in $d )
		{
			$testlink = $line
			filter_links 
		}
	#GET AUDIO QUALITY
	[string]$quality = audio_quality

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder
	#GET FREE SPACE
	$free_space = Get-FreeSpace
	if ( $sys_lang -eq "PL" )
		{
			sleep 1
			write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	else
		{
			sleep 1
			write-host = "FREE SPACE IN TARGET DIRECTORY: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	#SHOW OWER WINDWOS EXPLORER THE TARGET DIR
    Start explorer.exe $output_directory
	#LINES COUNTER
	$lines_var = Get-Content "$recources_main_dir\songs_out.txt" | Where { $_ }
	##$lines_var = $lines_var.trim() -ne ""
	[int]$lines_var = $lines_var.Count
	
    #[int]$lines_var+=1
    $xyz=0
	
	#$selected_file_var POINTET TO songs_out.txt
	$selected_file_var = "$recources_main_dir\songs_out.txt"
	#PARSE FILE CONTENT
	$d = Get-Content -Path $selected_file_var
	#REMOVE EMPTY LINES IF EXIST
	$d = $d.trim() -ne ""
	#MAIN LOOP FOR DOWNLOAD
	ForEach ($h in $d) 
		{
			[int]$lines_var-= 1
			$xyz++
			if ( $sys_lang -eq "PL" )
				{
					write-host " "
					write-host "ZACIAGANIE AUDIO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
				}
			else
				{
					write-host " "
					write-host "PULLING AN AUDIO LINK NR: $xyz . REMAIN: $lines_var ." -ForegroundColor yellow
				}
			Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $h"
		}
		
	Remove-Item -Path "$recources_main_dir\songs_out.txt"
	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
		}
	else
		{
			write-host ""
			Write-Host "THE DOWNLOAD PROCESS IS DONE." -ForegroundColor Green -NoNewline
		}				
}
###########################################
#3 FUNCTION TO DOWNLOAD WHOLE PLAYLIST #3 #
###########################################
Function download_playlist(){
    cls
	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			sleep 1
			Write-Host "WYBRALES OPCJE NUMER 3. POBIERANIE AUDIO Z PLAYLISTY." -ForegroundColor Yellow
		}
	else
		{
			write-host ""
			sleep 1
			Write-Host "YOU HAVE CHOOSEN OPTIONS NUMBER 3. DOWNLOADING AUDIO FROM YT PLAYLIST" -ForegroundColor Yellow
		}
		
	if ( $sys_lang -eq "PL" )
		{
			
			Write-Host ""
			SLEEP 1
			[string]$playlist_ID_yt = $(Write-Host "W CELU SCIAGNIECIA CALEY PLYLISTY NIEZBEDNY JEST JEJ IDENTYFIKATOR" -ForegroundColor yellow) + $(Write-Host "IDENTYFIKATOR PLAYLISTY ZOSTAL ZAZNACZONY NA ZIELONO W PRZYKLADOWYM LINKU PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)  + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CZESC ID Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; Read-Host)
		}
	else
		{
			Write-Host ""
			SLEEP 1
			[string]$playlist_ID_yt = $(Write-Host "IN ORDER TO DOWNLOAD THE ENTIRE PLAYLIST, ITS IDENTIFIER IS NECESSARY." -ForegroundColor yellow) + $(Write-Host "THE PLAYLIST ID WAS MARKED IN GREEN IN THE EXAMPLE LINK BELOW." -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)  + $(Write-Host "SIMPLY: COPY THE ID PART FROM THE BROWSER AND PRESS THE RIGHT KEY IN THE TERMINAL. " -ForegroundColor yellow; Read-Host)
		}
    #GET AUDIO QUALITY
	[string]$quality = audio_quality

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder
	$free_space = Get-FreeSpace
	if ( $sys_lang -eq "PL" )
		{
			sleep 1
			write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	else
		{
			sleep 1
			write-host = "FREE SPACE IN TARGET DIRECTORY: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	#SHOW OWER WINDWOS EXPLORER THE TARGET DIR
    Start explorer.exe $output_directory
	#MAIN DOWNLOAD PROCESS
    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --yes-playlist --output ""$output_directory""\%(title)s.%(ext)s $playlist_ID_yt "

	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
		}
	else
		{
			write-host ""
			Write-Host "THE DOWNLOAD PROCESS IS DONE." -ForegroundColor Green -NoNewline
		}		
}
##########################################
#4 FUNCTION TO DOWNLOAD WHOLE CHANNEL #4 #
##########################################
Function download_channel(){
	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			sleep 1
			Write-Host "WYBRALES OPCJE NUMER 4. POBIERANIE AUDIO Z CALEGO KANALU YT." -ForegroundColor Yellow
		}
	else
		{
			write-host ""
			sleep 1
			Write-Host "YOU HAVE CHOOSEN OPTIONS NUMBER 4. DOWNLOADING AUDIO FROM WHOLE YT CHANNEL" -ForegroundColor Yellow
		}
    cls
	Write-Host ""
	SLEEP 1
	if ( $sys_lang -eq "PL" )
		{
			[string]$channel_ID_yt = $(Write-Host "W CELU SCIAGNIECIA CALEGO KANALU  NIEZBEDNY JEST LINK ZAWIERAJACY PODFOLDER --- channel --- W LINKU" -ForegroundColor yellow) + $(Write-Host "PRZYKLADOWY LINK ZNAJDUJE SIE PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "channel" -NoNewline -ForegroundColor green) + $(Write-Host "/UC0C1W6nV0Rv6QkvAAE_AgXg" -ForegroundColor Magenta ) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CALY LINK Z PODFOLDEREM --- channel --- Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; Read-Host)
		}
	else
		{
			[string]$channel_ID_yt = $(Write-Host "IN ORDER TO DOWNLOAD AN ENTIRE CHANNEL, A YT LINK CONTAINING A SUBFOLDER --- channel --- IS NECESSARY." -ForegroundColor yellow) + $(Write-Host "AN EXAMPLE OF A LINK IS BELOW:" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "channel" -NoNewline -ForegroundColor green) + $(Write-Host "/UC0C1W6nV0Rv6QkvAAE_AgXg" -ForegroundColor Magenta ) + $(Write-Host "SIMPLY: COPY AN ENTIRE LINK WITH A SUBFOLDER --- channel --- FROM THE BROWSER AND PRESS THE RIGHT KEY IN THE TERMINAL: " -ForegroundColor yellow; Read-Host)
		}
     #GET AUDIO QUALITY
	[string]$quality = audio_quality
    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder
	#SHOW OWER WINDWOS EXPLORER THE TARGET DIR
    Start explorer.exe $output_directory
	#GET FREE SPACE
	$free_space = Get-FreeSpace
	if ( $sys_lang -eq "PL" )
		{
			sleep 1
			write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	else
		{
			sleep 1
			write-host = "FREE SPACE IN TARGET DIRECTORY: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	#MAIN DOWNLOAD PROCESS
    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "-ciw --extract-audio --audio-format mp3 --ffmpeg-location ""$ffmpeg"" --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $channel_ID_yt "
	
	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
		}
	else
		{
			write-host ""
			Write-Host "THE DOWNLOAD PROCESS IS DONE." -ForegroundColor Green -NoNewline
		}

}
##############################################################################################################
#5 FUNCTION TO DOWNLOAD VIDEO OR AUDIO FROM SINGLE LINKS ENTERED IN THE TERMINAL OR ALREADY PREPARED LIST #5 #
##############################################################################################################
Function download_movie_and_or_music_from_list(){
cls
	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			sleep 1
			Write-Host "WYBRALES OPCJE NUMER 5. POBIERANIE VIDEO I/LUB AUDIO POPRZEZ LINKI WPISYWANE Z PLIKU LUB WPISYWANE W CONSOLE." -ForegroundColor Yellow
		}
	else
		{
			write-host ""
			sleep 1
			Write-Host "YOU HAVE CHOOSED THE OPTION NUMBER 5. DOWNLOADING VIDEO AND/OR AUDIO VIA LINKS SAVED IN A FILE OR ENTERED IN TERMINAL." -ForegroundColor Yellow
		}
	
	$path2song_list_select_file = "$recources_main_dir\songs_out.txt"
	If (Test-Path $path2song_list_select_file)
		{
			Remove-Item -Path $path2song_list_select_file
		}
	if ( $sys_lang -eq "PL" )
		{
		do
			{
				SLEEP 1
				write-host ""
				Write-Host "CHCESZ SCIAGNAC VIDEO/AUDO Z JUZ PRZYGOTWANEJ LISTY CZY WPISAC KILKA LINKOW W CONSOLE ? " -ForegroundColor Yellow
				[int]$list_console = Read-Host "PODAJ CYFRE: 1 = LISTA ; 2 = CONSOLA:"
			}while(($list_console -ne 1  ) -and ($list_console -ne 2))
	}
	else
		{
			do
			{
				SLEEP 1
				write-host ""
				Write-Host "YOU WANT TO DOWNLOAD VIDEO / AUDIO FROM AN ALREADY PREPARED LIST OR TO ENTER A FEW LINKS IN THE TERMINAL ?" -ForegroundColor Yellow
				[int]$list_console = Read-Host "ENTER NUMBER: 1 = YT LINKS FROM FILE ; 2 = TERMINAL: "
			}while(($list_console -ne 1  ) -and ($list_console -ne 2))
		}

	if ( $list_console -eq 1)
		{
			#TXT FILE WITH SAVED YT LINKS
			warning_select_file
			$selected_file_var = Select-File
			#GET LINKS FROM THE TXT FILE
			#Get-Content -Path $selected_file_var

			$d = Get-Content -Path $selected_file_var | Where { $_ }
			##$d = $d.trim() -ne ""
			foreach ( $line in $d )
				{
					$testlink = $line
					filter_links	#FILTER PARSED LINKS FROM FILE					
				}
			
			$d = Get-Content -Path "$recources_main_dir\songs_out.txt"
			##$d = $d.trim() -ne ""
		}
	elseif ( $list_console -eq 2)
		{
			do
				{
					if ( $sys_lang -eq "PL" )
						{
							SLEEP 1
							#GET INPUT WITH YT LINK
							Write-Host ""
							[string]$line = $(Write-Host "PODAJ KOMPLETNY LINK Z YOUTUBE NP (https://www.youtube.com/watch?v=XmaaSK19jGQ)" -ForegroundColor green) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor green) + $(Write-Host "W CELU PRZEZWANIA WPISZ q i WSCISNIJ enter: " -ForegroundColor red; Read-Host)
							if ( $line -eq "q" )
								{
								}
							else
								{ 
									$testlink = $line
									filter_links #FILTER ENTERED LINKS
								} 
						}									
					else
						{
							SLEEP 1
							#GET INPUT WITH YT LINK
							Write-Host ""
							[string]$line = $(Write-Host "ENTER THE COMPLETE LINK FROM YOUTUBE E.G. (https://www.youtube.com/watch?v=XmaaSK19jGQ)" -ForegroundColor green) + $(Write-Host "SIMPLY: COPY FROM THE BROWSER AND PRESS THE RIGHT KEY ON THE TERMINAL." -ForegroundColor green) + $(Write-Host "TO INTERRUPT, ENTER q and PRESS enter: " -ForegroundColor red; Read-Host)
							if ( $line -eq "q" )
								{
								}
							else
								{	
									$testlink = $line
									filter_links
								} #FILTER ENTERED LINKS									
						}
									
				}until($line -eq "q"  )
		}
	#SET PATH FOR LINK LIST
	$c = Get-Content -Path "$recources_main_dir\songs_out.txt" | Where { $_ }
	if ( $sys_lang -eq "PL" )
		{
			do
				{
					SLEEP 1
					write-host ""
					$viedo_format = $(Write-Host "W JAKIM FORMACIE MA BYC SCIAGNIETY VIDEO." -ForegroundColor green ) + $(Write-Host " PRAWIDLOWE TO: avi ; mp4 " -ForegroundColor yellow ; Read-Host)
				}while(($viedo_format -ne "avi") -and ($viedo_format -ne "mp4"))
			do
				{
					SLEEP 1
					write-host ""
					Write-Host "CZY CHCESZ RAZEM Z VIDEO SCIAGNAC ROWNIEZ ODDZIELNIE SCIEZKE AUDIO W FORMACIE MP3 ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
					[int]$audio_yes_no = Read-Host "Enter number from 1-2"
				}while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))
		}
	else
		{
			do
				{
					SLEEP 1
					write-host ""
					$viedo_format = $(Write-Host "IN WHAT FORMAT THE VIDEO SHOULD BE DOWNLOADED." -ForegroundColor green ) + $(Write-Host " SUPPORTED ARE: avi ; mp4 " -ForegroundColor yellow ; Read-Host)
				}while(($viedo_format -ne "avi") -and ($viedo_format -ne "mp4"))
			do
				{
					SLEEP 1
					write-host ""
					Write-Host "DO YOU WANT TO DOWNLOAD THE AUDIO TRACK SEPARATED AS MP3 ALSO WITH VIDEO ?: PRESS 1 = YES .. 2 = NO " -ForegroundColor Yellow
					[int]$audio_yes_no = Read-Host "Enter number from 1-2"
				}while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))
		}
    if ( $audio_yes_no -eq 1 )
        {
			#GET AUDIO QUALITY
			[string]$quality = audio_quality
		}
	#PATH TO OUTPUT DIR
	$output_directory = Select-Folder
	
	$free_space = Get-FreeSpace
	if ( $sys_lang -eq "PL" )
		{
			sleep 1
			write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	else
		{
			sleep 1
			write-host = "FREE SPACE IN TARGET DIRECTORY: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}		
	Start explorer.exe $output_directory
	
	if ( $list_console -eq 1)
	{
		$xyz=0				
		$d = Get-Content -Path "$recources_main_dir\songs_out.txt" | Where { $_ }
		#$d = $d.trim() -ne ""
		$lines_var = Get-Content -Path "$recources_main_dir\songs_out.txt" | Where { $_ }
								
		#$lines_var = $lines_var.trim() -ne ""
		[int]$lines_var = $lines_var.Count	
		#[int]$lines_var+=1
		if ( $sys_lang -eq "PL" )
			{
				if ( $audio_yes_no -eq 1 )
					{			
						ForEach ($a in $d) 
							{
								[int]$lines_var-= 1
								$xyz++
								write-host " "
								write-host "ZACIAGANIE AUDIO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
								Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
								write-host " "
								write-host "ZACIAGANIE VIDEO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor cyan
								write-host " "
								Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
							}
					}
				if ( $audio_yes_no -eq 2 )
					{			
						ForEach ($a in $d) 
							{
								[int]$lines_var-= 1
								$xyz++
								write-host " "
								write-host "ZACIAGANIE VIDEO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
								write-host " "
								Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --no-playlist --output ""$output_directory""\%(title)s.%(ext)s $a"
							}
					}
			}
		else
			{
				if ( $audio_yes_no -eq 1 )
					{			
						ForEach ($a in $d) 
							{
								[int]$lines_var-= 1
								$xyz++
								write-host " "
								write-host "PULLING AN AUDIO LINK NR: $xyz . REMAIN: $lines_var." -ForegroundColor yellow
								Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
								write-host " "
								write-host "PULLING AN VIDEO LINK NR: $xyz . REMAIN: $lines_var" -ForegroundColor cyan
								write-host " "
								Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
							}
					}
				if ( $audio_yes_no -eq 2 )
					{			
						ForEach ($a in $d) 
							{
								[int]$lines_var-= 1
								$xyz++
								write-host " "
								write-host "PULLING AN VIDEO LINK NR: $xyz . REMAIN: $lines_var." -ForegroundColor yellow
								write-host " "
								Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --no-playlist --output ""$output_directory""\%(title)s.%(ext)s $a"
							}
					}
			}
	}
	if ( $list_console -eq 2)
		{
	
			$lines_var = Get-Content "$recources_main_dir\songs_out.txt" | Where { $_ } 
			#$lines_var = $lines_var.trim() -ne ""
			[int]$lines_var = $lines_var.Count	
			#[int]$lines_var+=1
			$xyz=0
			if ( $sys_lang -eq "PL" )
				{
					if ( $audio_yes_no -eq 1 )
						{
							ForEach ($a in $c) 
								{
									[int]$lines_var-= 1
									$xyz++
									write-host " "
									write-host "ZACIAGANIE AUDIO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
									write-host " "
									write-host "ZACIAGANIE VIDEO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor cyan
									write-host " "
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
								}
						}
					if ( $audio_yes_no -eq 2 )
						{
							ForEach ($a in $c)
								{
									[int]$lines_var-= 1
									$xyz++
									write-host " "
									write-host "ZACIAGANIE VIDEO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
									write-host " "
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --no-playlist --output ""$output_directory""\%(title)s.%(ext)s $a"					
								}
						}
				}
			else
				{
					if ( $audio_yes_no -eq 1 )
						{
							ForEach ($a in $c) 
								{
									[int]$lines_var-= 1
									$xyz++
									write-host " "
									write-host "PULLING AN AUDIO LINK NR: $xyz . REMAIN: $lines_var." -ForegroundColor yellow
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
									write-host " "
									write-host "PULLING AN VIDEO LINK NR: $xyz . REMAIN: $lines_var ." -ForegroundColor cyan
									write-host " "
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
								}
						}
					if ( $audio_yes_no -eq 2 )
						{
							ForEach ($a in $c)
								{
									[int]$lines_var-= 1
									$xyz++
									write-host " "
									write-host "PULLING AN VIDEO LINK NR: $xyz . REMAIN: $lines_var ." -ForegroundColor yellow
									write-host " "
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --no-playlist --output ""$output_directory""\%(title)s.%(ext)s $a"					
								}
						}
					
				}
     	
		}
    	
	If (Test-Path "$recources_main_dir\songs_out.txt")
		{
			Remove-Item -Path "$recources_main_dir\songs_out.txt"
		}
	
    if ( $sys_lang -eq "PL" )
		{
			write-host ""
			Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
		}
	else
		{
			write-host ""
			Write-Host "THE DOWNLOAD PROCESS IS DONE." -ForegroundColor Green -NoNewline
		}

}
###########################################################
#6 DOWNLOADING AUDIO OR VIDEO FROM PLAYLIST OR CHANNEL #6 #
###########################################################
Function download_movie_and_or_music_from_list_PLAYLIST_AND_CHANNEL(){
cls
	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			sleep 1
			Write-Host "WYBRALES OPCJE NUMER 6. POBIERANIE VIDEO I/LUB AUDIO Z KOMPLETNEJ PLAYLISTY LUB KANALU ." -ForegroundColor Yellow
		}
	else
		{
			write-host ""
			sleep 1
			Write-Host "YOU CHOOSE THE OPTIONS NUMBER 6. DOWNLOADING VIDEO AND / OR AUDIO FROM A COMPLETE PLAYLIST OR CHANNEL." -ForegroundColor Yellow
		}
	If (Test-Path "$recources_main_dir\songs.txt")
		{
			Remove-Item -Path "$recources_main_dir\songs.txt"
		}
		
	if ( $sys_lang -eq "PL" )
		{
			do
				{
					SLEEP 1
					Write-Host ""
					$(Write-Host "W CELU SCIAGNIECIA CALEY PLYLISTY NIEZBEDNY JEST JEJ IDENTYFIKATOR" -ForegroundColor yellow) + $(Write-Host "IDENTYFIKATOR PLAYLISTY ZOSTAL ZAZNACZONY NA ZIELONO W PRZYKLADOWYM LINKU PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)  + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CZESC ID Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; )
					write-host ""
					$(Write-Host "W CELU SCIAGNIECIA CALEGO KANALU  NIEZBEDNY JEST LINK ZAWIERAJACY PODFOLDER --- channel --- W LINKU" -ForegroundColor yellow) + $(Write-Host "PRZYKLADOWY LINK ZNAJDUJE SIE PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "channel" -NoNewline -ForegroundColor green) + $(Write-Host "/UC0C1W6nV0Rv6QkvAAE_AgXg" -ForegroundColor Magenta ) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CALY LINK Z PODFOLDEREM --- channel --- Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; )
					[string]$s = $(write-host "PODAJ LINK. W CELU ZAKONCZENIA WCISNIJ q I ZATWIERDZ POPRZEZ ENTER: " ) + $(Read-Host ; )
					if ( $s -eq "q" )
						{
							}else{$s >> "$recources_main_dir\songs.txt"}          
				}until($s -eq "q"  )
		}
	else
		{
			do
				{
					SLEEP 1
					Write-Host ""
					$(Write-Host "IN ORDER TO DOWNLOAD THE ENTIRE PLAYLIST, ITS IDENTIFIER IS NECESSARY." -ForegroundColor yellow) + $(Write-Host "THE PLAYLIST ID WAS MARKED IN GREEN IN THE EXAMPLE LINK BELOW." -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)  + $(Write-Host "SIMPLY: COPY THE ID PART FROM THE BROWSER AND PRESS THE RIGHT KEY IN THE TERMINAL. " -ForegroundColor yellow; )
					write-host ""
					$(Write-Host "IN ORDER TO DOWNLOAD AN ENTIRE CHANNEL, A YT LINK CONTAINING A SUBFOLDER --- channel --- IS NECESSARY." -ForegroundColor yellow) + $(Write-Host "AN EXAMPLE OF A LINK IS BELOW:" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "channel" -NoNewline -ForegroundColor green) + $(Write-Host "/UC0C1W6nV0Rv6QkvAAE_AgXg" -ForegroundColor Magenta ) + $(Write-Host "SIMPLY: COPY AN ENTIRE LINK WITH A SUBFOLDER --- channel --- FROM THE BROWSER AND PRESS THE RIGHT KEY IN THE TERMINAL: " -ForegroundColor yellow; )
					[string]$s = $(write-host "ENTER THE LINK. TO FINISH PRESS q AND CONFIRM WITH ENTER: " ) + $(Read-Host ; )
					if ( $s -eq "q" )
						{
							}else{$s >> "$recources_main_dir\songs.txt"}          
				}until($s -eq "q"  )
		}
	if ( $sys_lang -eq "PL" )
		{
			do
				{
					SLEEP 1
					write-host ""
					$viedo_format = $(Write-Host "W JAKIM FORMACIE MA BYC SCIAGNIETY VIDEO." -ForegroundColor green ) + $(Write-Host " PRAWIDLOWE TO: avi ; mp4 " -ForegroundColor yellow ; Read-Host)
				}while(($viedo_format -ne "avi") -and ($viedo_format -ne "mp4"))
			do
				{
					SLEEP 1
					write-host ""
					Write-Host "CZY CHCESZ RAZEM Z VIDEO SCIAGNAC ROWNIEZ ODDZIELNIE SCIEZKE AUDIO W FORMACIE MP3 ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
					[int]$audio_yes_no = Read-Host "Enter number from 1-2"
				}while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))
			if ( $audio_yes_no -eq 1 )
        {
			#GET AUDIO QUALITY
			[string]$quality = audio_quality
		}
		}
	else
		{
			do
				{
					SLEEP 1
					write-host ""
					$viedo_format = $(Write-Host "IN WHAT FORMAT THE VIDEO SHOULD BE DOWNLOADED." -ForegroundColor green ) + $(Write-Host " SUPPORTED ARE: avi ; mp4 " -ForegroundColor yellow ; Read-Host)
				}while(($viedo_format -ne "avi") -and ($viedo_format -ne "mp4"))
			do
				{
					SLEEP 1
					write-host ""
					Write-Host "DO YOU WANT TO DOWNLOAD THE AUDIO TRACK SEPARATED AS MP3 ALSO WITH VIDEO ?: PRESS 1 = YES .. 2 = NO " -ForegroundColor Yellow
					[int]$audio_yes_no = Read-Host "Enter number from 1-2"
				}while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))
		}
	
	$c = Get-Content -Path "$recources_main_dir\songs.txt" | Where { $_ }
	#PATH TO OUTPUT DIR
	$output_directory = Select-Folder
	Start explorer.exe $output_directory
	$free_space = Get-FreeSpace
	
	if ( $sys_lang -eq "PL" )
		{
			sleep 1
			write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	else
		{
			sleep 1
			write-host = "FREE SPACE IN TARGET DIRECTORY: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}		
		
	if ( $audio_yes_no -eq 1 )
		{
			if ( $sys_lang -eq "PL" )
				{
					ForEach ($a in $c)
						{	
							write-host " "
							write-host "ZACIAGANIE AUDIO." -ForegroundColor yellow
							Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $a"
							write-host " "
							write-host "ZACIAGANIE VIDEO." -ForegroundColor cyan
							write-host " "
							Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --output ""$output_directory""\%(title)s.%(ext)s $a"
						}
				}
			else
				{
					ForEach ($a in $c)
						{
							write-host " "
							write-host "PULLING AN AUDIO" -ForegroundColor yellow
							Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $a"
							write-host " "
							write-host "PULLING AN VIDEO" -ForegroundColor cyan
							write-host " "
							Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --output ""$output_directory""\%(title)s.%(ext)s $a"
						}
					Remove-Item -Path "$recources_main_dir\songs.txt"	
				}
			
		}	
	elseif ( $audio_yes_no -eq 2 )
		{
			if ( $sys_lang -eq "PL" )
				{
					ForEach ($a in $c)
						{
							[int]$lines_var-= 1
							$xyz++
							write-host " "
							write-host "ZACIAGANIE VIDEO." -ForegroundColor yellow
							write-host " "
							Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --output ""$output_directory""\%(title)s.%(ext)s $a"	
						}					
				}	
			else
				{
					ForEach ($a in $c)
						{
							[int]$lines_var-= 1
							$xyz++
							write-host " "
							write-host "PULLING AN VIDEO" -ForegroundColor yellow
							write-host " "
							Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --output ""$output_directory""\%(title)s.%(ext)s $a"	
						}
						
				}
		}
		Remove-Item -Path "$recources_main_dir\songs.txt"
		
	
     if ( $sys_lang -eq "PL" )
		{
			write-host ""
			Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
		}
	else
		{
			write-host ""
			Write-Host "THE DOWNLOAD PROCESS IS DONE." -ForegroundColor Green -NoNewline
		}
}
###############################################
#7 DOWNLOAD FROM PRIVATE PLAYLIST = COOKIES #7#
###############################################
function download_from_cookie(){
cls
	if ( $sys_lang -eq "PL" )
		{
			write-host ""
			sleep 1
			Write-Host "	WYBRALES OPCJE NUMER 7. MOZLIWOSC WYBORU: VIDEO TAK/NIE - I/LUB AUDIO Z PRYWATNEJ LISTY." -ForegroundColor Yellow
		}
	else
		{
			write-host ""
			sleep 1
			Write-Host "	YOU CHOOSE THE OPTIONS NUMBER 7. AVAILABLE CHOICES: VIDEO YES / NO - AND / OR AUDIO FROM PRIVATE LIST" -ForegroundColor Yellow
		}
	$path2song_list_single = "$recources_main_dir\songs.txt"
	If (Test-Path $path2song_list_single)
		{
			Remove-Item -Path $path2song_list_single
		}
	if ( $sys_lang -eq "PL" )
		{
			do
				{
					SLEEP 1
					write-host ""
					Write-Host "PODAJ JAKA PRZEGLADARKE UZYWASZ, CHODZI O TA GDZIE AKTUALNIE ZNAJDUJE SIE PLAYLISTA Z ZALOGOWANEGO KONTA YOUTUBE." -ForegroundColor Yellow
					SLEEP 1
					write-host ""
					Write-Host "OBSLUGIWANE PRZEGLADARKI TO: chrome ; edge ; firefox." -ForegroundColor Yellow
					SLEEP 1
					write-host ""
					Write-Host "! PRZY WYBORZE PRZEGLADARKI ZALECA SIE ROZWAGE. POBIERAK (YOUTUBE-DLP) BEDZIE MIAL DOSTEP DO CALEGO PROFILU! " -ForegroundColor Red
					SLEEP 1
					write-host ""
					Write-Host "! ZALECAM ZALOGOWANIE SIE DO YOUTUBE NA PRZEGLADARCE KTOREJ NIE UZYWA SIE NA CODZIEN I WSKAZANIE WLASNIE JEJ! " -ForegroundColor Red
					SLEEP 1
					write-host ""
					$web_browser = Read-Host "Podaj poprawna wartosc: chrome LUB edge LUB firefox : "
				}while(($web_browser -ne 'chrome')  -and ($web_browser -ne 'firefox') -and  ($web_browser -ne 'edge'))
		}
	else
		{
			do
				{
					SLEEP 1
					write-host ""
					Write-Host "ENTER WHAT BROWSER YOU ARE USING, IT IS WHERE THE PLAYLIST FROM THE LOGGED IN YOUTUBE ACCOUNT IS CURRENTLY." -ForegroundColor Yellow
					SLEEP 1
					write-host ""
					Write-Host "SUPPORTED BROWSERS: chrome; edge; firefox." -ForegroundColor Yellow
					SLEEP 1
					write-host ""
					Write-Host "BE CAREFUL WHEN CHOOSING YOUR BROWSER. POBIERAK (YOUTUBE-DLP) WILL HAVE ACCESS TO THE ENTIRE PROFILE!" -ForegroundColor Red
					SLEEP 1
					write-host ""
					Write-Host "!I RECOMMEND LOG IN TO YOUTUBE ON A BROWSER WHICH YOU DO NOT USE ON EVERYDAY!" -ForegroundColor Red
					SLEEP 1
					write-host ""
					$web_browser = Read-Host "ENTER THE CORRECT VALUE: chrome LUB edge LUB firefox : "
				}while(($web_browser -ne 'chrome')  -and ($web_browser -ne 'firefox') -and  ($web_browser -ne 'edge'))
		}

	SLEEP 1
    Write-Host ""
	if ( $web_browser -eq "firefox" )
		{
			$dir_4_borowser_cookies = "C:\Users\$logged_usr\AppData\Roaming\Mozilla\Firefox\Profiles"
			$latest_profile = Get-ChildItem -Path $dir_4_borowser_cookies | Sort-Object LastAccessTime -Descending | Select-Object -First 1
			#$latest_profile
		}
	elseif ( $web_browser -eq "edge" )
		{
		
			$dir_4_borowser_cookies = "C:\Users\$logged_usr\AppData\Local\Microsoft\Edge\User Data\Default"
			#$latest_profile = Get-ChildItem -Path $dir_2_fox_profile | Sort-Object LastAccessTime -Descending | Select-Object -First 1
			$latest_profile = $dir_4_borowser_cookies
		
		}
	if ( $web_browser -eq "chrome" )
		{
			$dir_4_borowser_cookies = "C:\Users\$logged_usr\AppData\Local\Google\Chrome\User Data\Default"
			#$latest_profile = Get-ChildItem -Path $dir_2_fox_profile | Sort-Object LastAccessTime -Descending | Select-Object -First 1
			$latest_profile = $dir_4_borowser_cookies		
		}
		
	if ( $sys_lang -eq "PL" )
		{
			do
				{
					SLEEP 1
					Write-Host ""
					[string]$playlist_ID_yt = $(Write-Host "W CELU SCIAGNIECIA CALEY PLYLISTY NIEZBEDNY JEST LINK Z IDENTYFIKATOREM" -ForegroundColor yellow) + $(Write-Host "IDENTYFIKATOR PLAYLISTY ZOSTAL ZAZNACZONY NA ZIELONO W PRZYKLADOWYM LINKU PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)  + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CZESC ID Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow ) + $(Write-Host "ABY ZAKONCZYC WPISZ q I ZATWIERDZ POPRZEZ ENTER:" -ForegroundColor yellow; Read-Host)
						if ( $playlist_ID_yt -eq "q" )
							{
							}else{$playlist_ID_yt >> "$recources_main_dir\songs.txt"}
				}until($playlist_ID_yt -eq "q"  )
		}
	else
		{
			do
				{
					SLEEP 1
					Write-Host ""
					[string]$playlist_ID_yt = $(Write-Host "IN ORDER TO DOWNLOAD AN ENTIRE PLYLIST, A LINK WITH AN IDENTIFIER IS NECESSARY" -ForegroundColor yellow) + $(Write-Host "THE PLAYLIST ID IS MARKED IN GREEN IN THE EXAMPLE LINK BELOW" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)  + $(Write-Host "SIMPLY: COPY THE ID PART FROM THE BROWSER AND PRESS THE RIGHT KEY IN THE TERMINAL." -ForegroundColor yellow ) + $(Write-Host "TO EXIT, ENTER q AND CONFIRM WITH ENTER: " -ForegroundColor yellow; Read-Host)
						if ( $playlist_ID_yt -eq "q" )
							{
							}else{$playlist_ID_yt >> "$recources_main_dir\songs.txt"}
				}until($playlist_ID_yt -eq "q"  )
		}
		

	If (Test-Path $path2song_list_single)
		{
			$entered_playlist_console = Get-Content -Path "$recources_main_dir\songs.txt"	| Where { $_ }
		}	
	
	if ( $sys_lang -eq "PL" )
		{
	
			do
				{
					SLEEP 1
					write-host ""
					Write-Host "CHCESZ SCIAGNAC VIDEO ? " -ForegroundColor Yellow
					SLEEP 1
					Write-Host ""
					[int]$video_yes_no = Read-Host "PODAJ CYFRE: 1 = TAK ; 2 = NIE : "
				}while(($video_yes_no -ne 1  ) -and ($video_yes_no -ne 2))
	
			if ( $video_yes_no -eq 1 )
				{	
					do
						{
							SLEEP 1
							write-host ""
							[string]$viedo_format = $(Write-Host "W JAKIM FORMACIE MA BYC SCIAGNIETY VIDEO." -ForegroundColor green ) + $(Write-Host " PRAWIDLOWE TO: avi ; mp4 " -ForegroundColor yellow ; Read-Host)
						}while(($viedo_format -ne "avi") -and ($viedo_format -ne "mp4"))
				}
		
		
			if ( $video_yes_no -eq 1 )
				{
					do
					{
						SLEEP 1
						write-host ""
						Write-Host "CZY CHCESZ RAZEM Z VIDEO SCIAGNAC ROWNIEZ SCIEZKE AUDIO ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
						[int]$audio_yes_no = Read-Host "Enter number from 1-2"
					}while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))
				}
    
			if (( $audio_yes_no -eq 1 ) -or ( $video_yes_no -eq 2 ))
				{
					#GET AUDIO QUALITY
					[string]$quality = audio_quality
		
				}
		}
	else
		{
			do
				{
					SLEEP 1
					write-host ""
					Write-Host "YOU WANT TO DOWNLOAD VIDEO ? " -ForegroundColor Yellow
					SLEEP 1
					Write-Host ""
					[int]$video_yes_no = Read-Host "ENTER A NUMBER: 1 = YES ; 2 = NO "
				}while(($video_yes_no -ne 1  ) -and ($video_yes_no -ne 2))
	
			if ( $video_yes_no -eq 1 )
				{	
					do
						{
							SLEEP 1
							write-host ""
							[string]$viedo_format = $(Write-Host "IN WHAT FORMAT THE VIDEO SHOULD BE DOWNLOADED." -ForegroundColor green ) + $(Write-Host " CORRECT VALUES ARE: avi ; mp4 " -ForegroundColor yellow ; Read-Host)
						}while(($viedo_format -ne "avi") -and ($viedo_format -ne "mp4"))
				}
		
		
			if ( $video_yes_no -eq 1 )
				{
					do
					{
						SLEEP 1
						write-host ""
						Write-Host "DO YOU WANT TO DOWNLOAD AUDIO ALSO WITH VIDEO ?: PRESS 1 = YES .. 2 = NO" -ForegroundColor Yellow
						[int]$audio_yes_no = Read-Host "Enter number from 1-2"
					}while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))
				}
    
			if (( $audio_yes_no -eq 1 ) -or ( $video_yes_no -eq 2 ))
				{
					#GET AUDIO QUALITY
					[string]$quality = audio_quality
		
				}
		}

	#PATH TO OUTPUT DIR
	$output_directory = Select-Folder
	Start explorer.exe $output_directory
	
	$free_space = Get-FreeSpace
	if ( $sys_lang -eq "PL" )
		{
			sleep 1
			write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	else
		{
			sleep 1
			write-host = "FREE SPACE IN TARGET DIRECTORY: $free_space GB." -ForegroundColor Yellow
			sleep 2
		}
	if ( $sys_lang -eq "PL" )
		{
			if ( $video_yes_no -eq 1)
				{
					if ( $audio_yes_no -eq 1 )
						{
							ForEach ($x in $entered_playlist_console) 
								{	
									write-host " "
									write-host "NAJPIERW ZOSTANIE SCIAGNIETE AUDIO " -ForegroundColor yellow
									write-host "SCIAGANIE AUDIO W TOKU.." -ForegroundColor yellow
									write-host " "
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --extract-audio --audio-format mp3 --output ""$output_directory""\%(title)s.%(ext)s --audio-quality ""$qualit"" --cookies-from-browser ""$web_browser"":""$latest_profile"" $x"
									write-host " "
									write-host "SCIAGANIE AUDIO ZAKONCZONE! " -ForegroundColor yellow
									write-host "SCIAGANIE VIDEO W TOKU.." -ForegroundColor yellow
									write-host " "
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format""  --output ""$output_directory""\%(title)s.%(ext)s $a --cookies-from-browser ""$web_browser"":""$latest_profile"" $x"
									write-host " "
									write-host "SCIAGANIE VIDEO ZAKONCZONE! " -ForegroundColor yellow
								}
						}
			if ( $audio_yes_no -eq 2 )
				{
					ForEach ($x in $entered_playlist_console)
					{
						write-host " "
						write-host "SCIAGANIE VIDEO W TOKU.." -ForegroundColor cyan
						write-host " "
						Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format""  --output ""$output_directory""\%(title)s.%(ext)s $a --cookies-from-browser ""$web_browser"":""$latest_profile"" $x"
						write-host " "
						write-host "SCIAGANIE VIDEO ZAKONCZONE! " -ForegroundColor cyan
					}
				}
				}	
	
			if ( $video_yes_no -eq 2)
				{		
					ForEach ($y in $entered_playlist_console) 
						{
							write-host " "
					write-host "SCIAGANIE AUDIO W TOKU.." -ForegroundColor yellow
					write-host " "
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --extract-audio --audio-format mp3 --output ""$output_directory""\%(title)s.%(ext)s --audio-quality ""$qualit"" --cookies-from-browser ""$web_browser"":""$latest_profile"" $y"
					write-host " "
					write-host "SCIAGANIE AUDIO ZAKONCZONE! " -ForegroundColor yellow
						}
			

	
				}   
			write-host ""
			Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
			Remove-Item -Path "$recources_main_dir\songs.txt"
		}
	else
		{
			if ( $video_yes_no -eq 1)
				{
					if ( $audio_yes_no -eq 1 )
						{
							ForEach ($x in $entered_playlist_console) 
								{	
									write-host " "
									write-host "AUDIO WILL BE DOWNLOADED FIRST " -ForegroundColor yellow
									write-host "DOWNLOADING AUDIO IN PROGRESS.." -ForegroundColor yellow
									write-host " "
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --extract-audio --audio-format mp3 --output ""$output_directory""\%(title)s.%(ext)s --audio-quality ""$qualit"" --cookies-from-browser ""$web_browser"":""$latest_profile"" $x"
									write-host " "
									write-host "AUDIO DOWNLOAD COMPLETED!" -ForegroundColor yellow
									write-host "VIDEO DOWNLOAD IN PROGRESS.." -ForegroundColor yellow
									write-host " "
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format""  --output ""$output_directory""\%(title)s.%(ext)s $a --cookies-from-browser ""$web_browser"":""$latest_profile"" $x"
									write-host " "
									write-host "VIDEO DOWNLOAD FINISHED!" -ForegroundColor yellow
								}
						}
					if ( $audio_yes_no -eq 2 )
						{
							ForEach ($x in $entered_playlist_console)
								{
									write-host " "
									write-host "VIDEO DOWNLOAD IN PROGRESS.." -ForegroundColor cyan
									write-host " "
									Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format""  --output ""$output_directory""\%(title)s.%(ext)s $a --cookies-from-browser ""$web_browser"":""$latest_profile"" $x"
									write-host " "
									write-host "VIDEO DOWNLOAD FINISHED!" -ForegroundColor cyan
								}
						}
				}	
	
			if ( $video_yes_no -eq 2)
				{		
					ForEach ($y in $entered_playlist_console) 
						{
							write-host " "
					write-host "DOWNLOADING AUDIO IN PROGRESS.." -ForegroundColor yellow
					write-host " "
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --extract-audio --audio-format mp3 --output ""$output_directory""\%(title)s.%(ext)s --audio-quality ""$qualit"" --cookies-from-browser ""$web_browser"":""$latest_profile"" $y"
					write-host " "
					write-host "AUDIO DOWNLOAD COMPLETED!" -ForegroundColor yellow
						}
			

	
				}   
			write-host ""
			Write-Host "WHOLE DOWNLOADING PROCESS IS FINISHED" -ForegroundColor Green -NoNewline
			Remove-Item -Path "$recources_main_dir\songs.txt"
		}
	
}
##############################
#8 UPDATES MENU FUNCTIONS #8 #
##############################
Function updates_menu(){
	############################################################
	#1 CHECK THE POBIERAK VER AND AFTER APPROVAL UPDATE IT # 1 #
	############################################################
    Function check_pobierak_version(){ #1 FUNCTION TO CHECK IF NEW VERSION OF POBIERAK IS AVAILABLE #1

        cls
        $path_to_temp = "$recources_main_dir\temp"
		#IF BEFORE WAS AN TEMP DIR IN RESOURCES WITH SHOULD NOT HAPPEN THEN REMOVE IT AND THE CONTENT IF NOT PRESENT THEN CREATE IT
        If(!(test-path -PathType container $path_to_temp))
            {
                New-Item -ItemType Directory -Path $path_to_temp
            }
        else
            {
                Remove-Item $path_to_temp -Force -Recurse
                New-Item -ItemType Directory -Path $path_to_temp
            }
		#CURL POBIERAK FROM GITHUB REPO
        curl -o $path_to_temp\pobierak.zip https://github.com/pagend0s/pobierak4windows/archive/refs/heads/main.zip
		#EXTRACT DOWNLOADED ZIP WITH POBIERAK INTO ./RESOURCES/TEMP/..
        Get-ChildItem $path_to_temp\pobierak.zip -Filter *.zip | Expand-Archive -DestinationPath $path_to_temp\pobierak\ -Force
		#GET PRESENT VERSION OF POBIERAK
        $pobierak_v_present = Get-ChildItem $recources_main_dir\pobierak.ps1 | Select-String "pobierak_v" | Select-Object -First 1 
		#GET DOWNLOADED AND EXTRACTED VERSION OF POBIERAK
        $version_v_downloaded = Get-ChildItem $path_to_temp\pobierak\pobierak4windows-main\resources\pobierak.ps1 | Select-String "pobierak_v" | Select-Object -First 1 
		#CHANGE VERSION NUMBER FROM STRING TO DOUBLE VAR
        $version_present = $pobierak_v_present.Line.Split('=')[1] -replace '"','' -replace ' ',''
        [double]$version_present_double = [string]$version_present
		#CHANGE VERSION NUMBER FROM STRING TO DOUBLE VAR
        $pobierak_downloaded = $version_v_downloaded.Line.Split('=')[1] -replace '"','' -replace ' ',''
        [double]$pobierak_downloaded_double = [string]$pobierak_downloaded
		
		if ( $sys_lang -eq "PL" )
			{
				if ( $pobierak_downloaded_double -gt $version_present_double  )
					{
						Write-Host ""
						SLEEP 1
						write-host "JEST DOSTEPNA NOWA WERSJA pobieraka: $pobierak_downloaded_double "  -ForegroundColor green
						Write-Host ""
						SLEEP 1
						$whats_new = (( Get-Content $path_to_temp\pobierak\pobierak4windows-main\resources\whats_new_pl.txt  | Out-String) -replace "`n", "`r`n" )
						$whats_new = $(Write-Host "NOWSZA WERSJA OBEJMUJE NASTEPUJACE ZMIANY: " -ForegroundColor green) + $( Write-Host "$whats_new" -ForegroundColor magenta )
						$whats_new
						do
							{
								Write-Host ""
								SLEEP 1
								Write-Host "CZY CHCESZ JA ZAINSTALOWAC ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
								$instal_or_not = Read-Host "WPROWADZ NUMER: 1-2"
							}while(([int]$instal_or_not -ne 1  ) -and ([int]$instal_or_not -ne 2))
					}
				else
					{
						Write-Host ""
						SLEEP 1
						write-host "BRAK NOWEJ WERSJI POBIERAKA" -ForegroundColor red
						Remove-Item $path_to_temp -Force -Recurse
                        Write-Host ""
                        SLEEP 1
                        Write-Host "OBECNA WERSJA TO: $version_present "
                        SLEEP 3
                        SLEEP 5
                        if ( $selection_update -eq 1 )
                            {
                                main_menu
                            }
					}
			}
		else
			{
				if ( $pobierak_downloaded_double -gt $version_present_double  ) #IF VERSION OF DOWNLOADED POBIERAK IS HIGHER AS THE PRESENT THEN INFORM ABOUT IT
					{
						Write-Host ""
						SLEEP 1
						write-host "A NEW VERSION OF POBIERAK IS AVAILABLE: $pobierak_downloaded_double "  -ForegroundColor green
						Write-Host ""
						SLEEP 1
						$whats_new = (( Get-Content $path_to_temp\pobierak\pobierak4windows-main\resources\whats_new_en.txt  | Out-String) -replace "`n", "`r`n" )
						$whats_new = $(Write-Host "THE NEWER VERSION INCLUDES THE FOLLOWING CHANGES: " -ForegroundColor green) + $( Write-Host "$whats_new" -ForegroundColor magenta )
						$whats_new
						do
							{
								Write-Host ""
								SLEEP 1
								Write-Host "DO YOU WANT TO UPDATE ?: PRESS 1 = YES .. 2 = NO" -ForegroundColor Yellow
								$instal_or_not = Read-Host "ENTER THE CORRECT VALUE: 1-2"
							}while(([int]$instal_or_not -ne 1  ) -and ([int]$instal_or_not -ne 2))
					}
				else
					{
						Write-Host ""
						SLEEP 1
						write-host "THERE IS NO NEWER VERSION OF POBIERAK AT THE MOMENT." -ForegroundColor red
						Remove-Item $path_to_temp -Force -Recurse
                        Write-Host ""
                        SLEEP 1
                        Write-Host "PRESENT VERSION IS: $version_present "
                        SLEEP 3
                        SLEEP 5
							if ( $selection_update -eq 1 )
                                {
                                    main_menu
                                }
                        
					}
			}
        if ( $instal_or_not -eq 1 )
            {
				if ( $sys_lang -eq "PL" )
					{
						Write-Host ""
						SLEEP 1
						Write-Host "AKTUALIZACJA POBIERAKA W TOKU."
					}
				else
					{
						Write-Host ""
						SLEEP 1
						Write-Host "UPDATING POBIERAK IN PROGRESS."
					}
				#IF ARE PROBLEMS WITH THE OLD VERSION THEN COPIE pobierak_bak.ps1 AND RENAME TO pobierak_primary.ps1
                if ( $process_bak_id -ne $null )
                    {
                        Copy-Item  -Path $recources_main_dir\pobierak_bak.ps1 $recources_main_dir\pobierak_primary.ps1
                    }
				
				$path_2_pob_pri = "$recources_main_dir\pobierak_primary.ps1"
				If (Test-Path $path_2_pob_pri)
					{	#IF NO ERROR WITH THE SCRIPT THEN REMOVE OLD pobierak_primary.ps1
						if (( $process_bak_id -eq $null -and $process_bak_primary_id -eq $null ))
							{
								Remove-Item $recources_main_dir\pobierak_primary.ps1 -Force 
							}
					}         
                Copy-Item  -Path $recources_main_dir\pobierak.ps1 $recources_main_dir\pobierak_bak.ps1	#FOR BACKUP PURPOSES pobierak.ps1 IS COPIED AND RENAMED TO pobierak_bak.ps1 
                Copy-Item  -Path $path_to_temp\pobierak\pobierak4windows-main\resources\pobierak.ps1 $recources_main_dir\pobierak.ps1	#COPY NEW VERSION OF POBIERAK TO MAIN DIR
                Copy-Item  -Path $path_to_temp\pobierak\pobierak4windows-main\pobierak.bat $pobierakbat_main_dir\pobierak.bat			#COPY NEW pobierak.bat	TO MAIN DIR
				Copy-Item  -Path $path_to_temp\pobierak\pobierak4windows-main\resources\whats_new_pl.txt $pobierakbat_main_dir\whats_new_pl.txt #COPY NEWS ABOUT POBIERAK TO TO MAIN DIR
				Copy-Item  -Path $path_to_temp\pobierak\pobierak4windows-main\resources\whats_new_en.txt $pobierakbat_main_dir\whats_new_en.txt #COPY NEWS ABOUT POBIERAK TO TO MAIN DIR
				
				if ( $sys_lang -eq "PL" )
					{
						Write-Host ""
						SLEEP 1
						Write-Host "POBIERAK ZOSTAL UAKTUALNIONY!!"
						Remove-Item $path_to_temp -Force -Recurse #REMOVE TEMP WITH DOWNLOADED POBIERAK AFTER COPY TO MAIN DIR
				
						if (($selection_update -eq 1) -and ($instal_or_not -eq 1))
					
							{
								Write-Host ""
								SLEEP 1
								Write-Host "ZA MOMENT ZOSTANIE OTWARTA NOWA WERSJA A STARA WERSJE BEDZIE MOZNA ZAMKNAC"
								Write-Host ""
								SLEEP 5
                                Start-Process $pobierakbat_main_dir\pobierak.bat #START NEW POBIERAK VERSION
								EXIT
							}
					}
				else
					{
						Write-Host ""
						SLEEP 1
						Write-Host "POBIERAK IS UP TO DATE"
                        SLEEP 2
						Remove-Item $path_to_temp -Force -Recurse
				
						if (($selection_update -eq 1) -and ($instal_or_not -eq 1))
							{
								Write-Host ""
								SLEEP 1
								Write-Host "IN THE MOMENT A NEW VERSION WILL BE OPENED AND THE OLD VERSION CAN BE CLOSED"
								Write-Host ""
                                Start-Process $pobierakbat_main_dir\pobierak.bat #START NEW POBIERAK VERSION
								SLEEP 5
								EXIT
							}
					}
			}
        else
            {
                if (( $sys_lang -eq "PL" ) -and ( $instal_or_not -eq 2))
                    {
                       Write-Host ""
                       SLEEP 1
                       Write-Host "OBECNA WERSJA TO: $version_present "
                       SLEEP 2
                    }
                elseif (( $sys_lang -ne "PL" ) -and ( $instal_or_not -eq 2))
                    {
                        Write-Host ""
                        SLEEP 1
                        Write-Host "PRESENT VERSION IS: $version_present "
                        SLEEP 2
                    }
                if ( $selection_update -eq 1 )
                    {
                        main_menu
                    }
            }
		return $instal_or_not

    }
	###############################
	#2 DOWNLOAD FFMPEG LIBRARY# 2 #
	###############################
    Function download_ffmpeg(){
        #https://github.com/GyanD/codexffmpeg/releases

        $test_ffmpef_if_exist = "$recources_main_dir\ffmpeg"
            if (Test-Path $test_ffmpef_if_exist) 
                {
                    Remove-Item $test_ffmpef_if_exist -Force -Recurse #REMOVE OLD FFMPEG DIR RECURS
                }
		if ( $sys_lang -eq "PL" )
			{
				Write-Host ""
				SLEEP 1
				Write-Host "SCIAGANIE KONWERTERA Z REPOZYTORIUM GITHUB.. TO MOZE TROCHE POTRWAC OK KILKU MINUT. OTWORZ BROWAR I CIERPLIWOSCI ;)"
			}
		else
			{
				Write-Host ""
				SLEEP 1
				Write-Host "DOWNLOADING THE CONVERTER FROM THE GITHUB REPOSITORY .. IT MAY TAKE A WHILE . YOU CAN OPEN A BEER AND PATIENCE ;)"
			}
		#DONWLOAD NEW FFMPEG REPO FROM GITHUB GyanD TO ffmpeg.zip
		
        Start-BitsTransfer -Source "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" -Destination "$recources_main_dir\ffmpeg.zip"
		
		if ( $sys_lang -eq "PL" )
			{
				SLEEP 1
				Write-Host ""
				Write-Host "SCIAGANIE KONWERTERA ZAKONCZONE!!!" -ForegroundColor green
				Write-Host ""
				SLEEP 1
				Write-Host "WYPAKOWYWANIE KONWERTERA W TOKU" -ForegroundColor green
			}
		else
			{
				SLEEP 1
				Write-Host ""
				Write-Host "CONVERTER DOWNLOAD COMPLETED !!!" -ForegroundColor green
				Write-Host ""
				SLEEP 1
				Write-Host "UNZIPPING THE CONVERTER IN PROGRESS" -ForegroundColor green
			}
		
		#FIND ZIP WITH FFMPEG IN MAIN DIR AND EXPAND ARCHIVE TO MAIN DIR\ffmpeg
        Get-ChildItem $recources_main_dir -Filter *.zip | Expand-Archive -DestinationPath $recources_main_dir\ffmpeg -Force
		#DELETE DOWNLOADED ZIP WITH FFMPEG AFTER EXTRACTION
        Get-ChildItem $recources_main_dir -Filter *.zip | Remove-Item
		#SET EXTRACTED DIR
        $recources_main_dir_unzipped = "$recources_main_dir\ffmpeg"	
		#FIND EXTRACTED FOLDER NAME AND COPY IT TO MAIN DIR"
        $unzipped_dir = get-ChildItem -Path $recources_main_dir_unzipped -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 1 | Move-Item -Destination $recources_main_dir
        #DELETE UNZIPPED DIR WITH DOWNLOADED NAME IN MAINDIR\FFMPEG
        Remove-Item $recources_main_dir_unzipped -Force -Recurse
		if ( $sys_lang -eq "PL" )
			{
				Write-Host ""
				Write-Host "ROZPAKOWANIE ZAKONCZONE!" -ForegroundColor green	
			}
		else
			{
				Write-Host ""
				Write-Host "UNPACKING COMPLETE!" -ForegroundColor green	
			}
		#RENAME COPIED DIR WITH DOWNLOADED AND COPIED FFMPEG TO ffmpeg
        $unzipped_dir = get-ChildItem -Path $recources_main_dir -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 1 | Rename-Item -newname ffmpeg
        
		if ( $sys_lang -eq "PL" )
			{
				Write-Host ""
				SLEEP 1
				Write-Host "KONWERTER JEST SCIAGNIETY, WYPAKOWANY I GOTOWY DO UZYTKU" -ForegroundColor green
			}
		else
			{
				Write-Host ""
				SLEEP 1
				Write-Host "THE CONVERTER IS DOWNLOADED, UNPACKED AND READY FOR USE." -ForegroundColor green
			}

    }
	#######################
	#3 DOWNLOAD YT-DLP# 3 #
	#######################
    Function download_yt_dlp(){
		if ( $sys_lang -eq "PL" )
			{
				#https://github.com/yt-dlp/yt-dlp
				Write-Host ""
				SLEEP 1
				Write-Host "SCIAGANIE YT-DLP.exe" -ForegroundColor green
				Start-BitsTransfer -Source "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -Destination "$recources_main_dir\yt-dlp.exe" #DOWNLOAD YT-DPL
				Write-Host "SCIAGANIE YT-DLP ZAKONCZONE!!!" -ForegroundColor green
			}
		else
			{
				#https://github.com/yt-dlp/yt-dlp
				Write-Host ""
				SLEEP 1
				Write-Host "DOWNLOADING YT-DLP.exe IN PROGRESS" -ForegroundColor green
				Start-BitsTransfer -Source "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -Destination "$recources_main_dir\yt-dlp.exe" #DOWNLOAD YT-DPL
				Write-Host "DOWNLOAD YT-DLP SUCCESSFUL!!!" -ForegroundColor green
			}
    }
	########################
	#4 ALL IN ONE OPTION#4 #
	########################
    Function download_all_at_once(){
        $instal_or_not = check_pobierak_version
        download_ffmpeg
        download_yt_dlp		
		if ( $instal_or_not -eq 1 )
			{	
				if ( $sys_lang -eq "PL" )
					{
						Write-Host ""
						Write-Host "!!!WSZYSTKIE OPERACJE ZAKONCZONE SUKCESEM!!!"
						SLEEP 1
						Write-Host "ZA MOMENT ZOSTANIE OTWARTA NOWA WERSJA A STARA WERSJE BEDZIE MOZNA ZAMKNAC"
						Write-Host ""
						SLEEP 5
                        Start-Process $pobierakbat_main_dir\pobierak.bat 
						EXIT
					}
				else
					{
						Write-Host ""
						SLEEP 1
						Write-Host "IN THE MOMENT A NEW VERSION WILL BE OPENED AND THE OLD VERSION CAN BE CLOSED"
						Write-Host ""
						SLEEP 5
                        Start-Process $pobierakbat_main_dir\pobierak.bat
						EXIT
					}
			}
		else
			{
                if ( $sys_lang -eq "PL" )
                    {
                        Write-host "!!!WSZYSTKIE OPERACJE ZAKONCZONE SUKCESEM!!!"
                        SLEEP 3
                        main_menu
                    }
                else
                    {
                        Write-host "!!!ALL OPERATIONS SUCCESSFUL!!!"
                        SLEEP 3
                        main_menu
                    }
						
			}
    }
	##############################
	#5 RESTOR PREVIUSE VERSION#5 #
	##############################
	Function previous_version(){
		if ( $sys_lang -eq "PL" )
			{
				do
					{
						Write-Host ""
						SLEEP 1
						Write-Host "CZY CHCESZ PRZYWROCIC POPRZEDNIA WERSJE ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
						[int]$previous_version = Read-Host "PODAJ NUMER: 1-2"
					}while(($previous_version -ne 1  ) -and ($previous_version -ne 2))
				if ( $previous_version -eq 1 )
					{
						sleep 1
						write-host ""
						write-host "PRZYWRACANIE POPRZEDNIEJ WERSJI." -ForegroundColor green
						sleep 1
						write-host ""
						Copy-Item  -Path $recources_main_dir\pobierak_bak.ps1 $recources_main_dir\pobierak.ps1
						sleep 1
						write-host ""
						write-host "POPRZEDNIA WERSJA ZOSTALA PRZYWROCONA" -ForegroundColor green
						sleep 1
						write-host ""
						Start-Process $pobierakbat_main_dir\pobierak.bat
						sleep 1
                        EXIT
					}
				if ( $previous_version -eq 2 )
					{
						write-host "WERSJA NIE ZOSTANIE PRZYWROCONA" -ForegroundColor red
                        SLEEP 3
                        main_menu
					}
			}
		else
			{
				do
					{
						Write-Host ""
						SLEEP 1
						Write-Host "DO YOU WANT TO RESTORE PREVIOUS VERSIONS OF POBIERAK ?: PRESS 1 = YES .. 2 = NO " -ForegroundColor Yellow
						[int]$previous_version = Read-Host "ENTER NUMBER: 1 - (YES) ; 2 - (NO)"
					}while(($previous_version -ne 1  ) -and ($previous_version -ne 2))
				if ( $previous_version -eq 1 )
					{
						sleep 1
						write-host ""
						write-host "RESTORING THE PREVIOUS VERSION." -ForegroundColor green
						sleep 1
						write-host ""
						Copy-Item  -Path $recources_main_dir\pobierak_bak.ps1 $recources_main_dir\pobierak.ps1
						sleep 1
						write-host ""
						write-host "THE PREVIOUS VERSION HAS BEEN RESTORED." -ForegroundColor green
						sleep 1
						write-host ""
						Start-Process $pobierakbat_main_dir\pobierak.bat
						sleep 1
                        EXIT
					}
				if ( $previous_version -eq 2 )
					{
						write-host "THE PREVIOUS VERSION WILL NOT BE RESTORED." -ForegroundColor red
                        SLEEP 3
                        main_menu                                                                                                
					}
			}
	
	}
#############################
######## UPDATE MENU ########
#############################
    function Show_updates_Menu(){
		if ( $sys_lang -eq "PL" )
			{
				Clear-Host
				Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "AKTUALNA WERSJA Pobieraka: " ) -ForegroundColor Green -NoNewline; Write-Host "$pobierak_v" -ForegroundColor yellow
				Write-Host ""
				Write-Host "1: SPRAWDZ CZY JEST DOSTEPNA NOWSZA WERSJA SKRYPTU POBIERAKA." -ForegroundColor Magenta
				Write-Host ""
				Write-Host "2: POBIERZ BIBLIOTEKE FFMPEG DO KONWERTOWANIA SCIAGNIETYCH MULTIMEDIOW" -ForegroundColor Magenta
				Write-Host ""
				Write-Host "3: SCIAGNIJ YT-DLP." -ForegroundColor Magenta
				Write-Host ""
				Write-Host "4: PRZEPROWADZ WSZYSTKIE OPERACJE NA RAZ." -ForegroundColor Yellow
				Write-Host ""
				Write-Host "5: PRZYWROC POPRZEDNIA WESJE POBIERAKA." -ForegroundColor Magenta
				Write-Host ""
				Write-Host "EXIT: ABY WYJSC - 6" -ForegroundColor White
			}
		else
			{
				Clear-Host
				Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "AKTUALNA WERSJA Pobieraka: " ) -ForegroundColor Green -NoNewline; Write-Host "$pobierak_v" -ForegroundColor yellow
				Write-Host ""
				Write-Host "1: CHECK IF A NEWER VERSION OF THE POBIERAK IS AVAILABLE." -ForegroundColor Magenta
				Write-Host ""
				Write-Host "2: DOWNLOAD THE FFMPEG LIBRARY TO CONVERT DOWNLOADED MULTIMEDIA." -ForegroundColor Magenta
				Write-Host ""
				Write-Host "3: GET YT-DLP." -ForegroundColor Magenta
				Write-Host ""
				Write-Host "4: PERFORM ALL OPERATIONS AT ONCE." -ForegroundColor Yellow
				Write-Host ""
				Write-Host "5: RESTORE PREVIOUS POBIERAK VERSION." -ForegroundColor Magenta
				Write-Host ""
				Write-Host "EXIT: TO EXIT THIS MENU ENTER - 6" -ForegroundColor White
			}
	}
			
	if ( $sys_lang -eq "PL" )
		{	
			do
				{
					Show_updates_Menu
					SLEEP 1
					write-host ""
					Do
						{
							[int]$selection_update = $(Write-Host "DOKONAJ WYBORU WYBIERAJAC ODPOWIEDNI NUMER OPCJI. " -ForegroundColor green -NoNewLine) + $(Write-Host "ZATWIERDZ POPRZEZ ENTER: " -ForegroundColor Yellow -NoNewLine; Read-Host )
						}until (( [int]$selection_update -lt 7 ) -and ( [int]$selection_update -gt 0 ))

					switch ($selection_update)
						{
							'1' {	check_pobierak_version	} 
							'2' {	download_ffmpeg	} 
							'3' {	download_yt_dlp	}
							'4' {	download_all_at_once	}
							'5' {	previous_version	}
							'6' {	main_menu	}
						}
					pause
				}until (( [int]$selection_update -ne 6 ) -and ( [int]$selection_update -gt 0 ))
		}
	else
		{
			do
				{
					Show_updates_Menu
					SLEEP 1
					write-host ""
					Do
						{
							[int]$selection_update = $(Write-Host "MAKE YOUR CHOICE BY ENTERING THE RIGHT OPTION NUMBER." -ForegroundColor green -NoNewLine) + $(Write-Host "CONFIRM WITH ENTER: " -ForegroundColor Yellow -NoNewLine; Read-Host )
						}until (( [int]$selection_update -lt 7 ) -and ( [int]$selection_update -gt 0 ))

					switch ($selection_update)
						{
							'1' {	check_pobierak_version	} 
							'2' {	download_ffmpeg	} 
							'3' {	download_yt_dlp	}
							'4' {	download_all_at_once	}
							'5' {	previous_version	}
							'6' {	main_menu	}
						}
					pause
				}until (( [int]$selection_update -ne 6 ) -and ( [int]$selection_update -gt 0 ))
		}
}
###########################
######## YT-DL DEV ########
###########################
function youtube_dlp_dev(){
cls
	if ( $sys_lang -eq "PL" )
		{
			Write-Host "WITAJ W POBIERAKU DLA AMBITNYCH ;)" -ForegroundColor green
			Write-Host "TUTAJ MOZESZ WPROWADZAC KOMENDY BEZPOSREDNIO DLA PROGRAMU YOUTUBE-DLP." -ForegroundColor green
			Write-Host "KOMPLETNA LISTA KOMEND ZNAJDUJE SIE NA STRONIE PROJEKTU: https://github.com/yt-dlp/yt-dlp LUB PO WPISANIU ARGUMENTU --help " -ForegroundColor green
			
			do
				{
					write-host ""
					SLEEP 1
					$arguments = $(Write-Host "PODAJ ZESTAW ARGUMENTOW I ZATWIERDZ POPRZEZ ENTER." -ForegroundColor green -NoNewLine) + $(Write-Host "ABY WYJSC Z TEJ SEKCJI WPISZ: quit" -ForegroundColor RED ; Read-Host)
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList """$arguments"""
				}until($arguments -eq "quit")
			Write-Host "POBIERAK DLA AMBITNYCH ZAKONCZONY." -ForegroundColor green
		}	
	else
		{
			Write-Host "WELCOME IN THE POBIERAK FOR AMBITIOUS  ;)" -ForegroundColor green
			Write-Host "HERE YOU CAN ENTER THE COMMANDS DIRECTLY FOR THE YOUTUBE-DLP PROGRAM." -ForegroundColor green
			Write-Host "A COMPLETE LIST OF COMMANDS YOU CAN FIND ON THE YT-DLP PROJECTS PAGE: https://github.com/yt-dlp/yt-dlp | OR AFTER ENTERING AN ARGUMENT: --help " -ForegroundColor green
			
			do
				{
					write-host ""
					SLEEP 1
					$arguments = $(Write-Host "PROVIDE A SET OF ARGUMENTS AND CONFIRM WITH ENTER." -ForegroundColor green -NoNewLine) + $(Write-Host "TO EXIT WRITE: quit" -ForegroundColor RED ; Read-Host)
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList """$arguments"""
				}until($arguments -eq "quit")
			Write-Host "PBOERAK FOR AMBITIOUS CLOSED" -ForegroundColor green
		}
}
###########################
######## MAIN MENU ########
###########################
function main_menu(){

if ( $sys_lang -eq "PL" )
	{
		function Show-Menu(){
			Clear-Host
			Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "Pobierak wersja: " ) -ForegroundColor Green -NoNewline; Write-Host "$pobierak_v" -ForegroundColor yellow
			write-host ""
			internal_info
			play_sound
			Write-Host ""
			Write-Host "	1: SCIAGNIJ ILE CHCESZ POJEDYNCZYCH LINKOW." -ForegroundColor Magenta
			Write-Host ""
			Write-Host "	2: SCIAGNIJ PIOSENKI Z LINKOW ZNAJDUJACYCH SIE W PLIKU." -ForegroundColor Yellow
			Write-Host ""
			Write-Host "	3: SCIAGNIJ AUDIO ZE WSKAZANEJ PLAYLISTY." -ForegroundColor Magenta
			Write-Host ""
			Write-Host "	4: SCIAGNIJ AUDIO ZE WSKAZANEGO YT CHANNEL." -ForegroundColor Yellow
			Write-Host ""
			Write-Host "	5: SCIAGNIJ VIDEO I/LUB AUDIO (POJEDYNCZE KAWALKI)" -ForegroundColor Magenta
			Write-Host ""
			Write-Host "	6: SCIAGNIJ VIDEO I/LUB AUDIO Z PLAYLISTY LUB CHANNEL " -ForegroundColor Yellow
			Write-Host ""
			Write-Host "	7: SCIAGNIJ Z PRYWATNEJ LISTY VIDEO I/LUB AUDIO" -ForegroundColor Magenta
			Write-Host ""
			Write-Host "	8: MENU AKTUALIZACJI" -ForegroundColor Red
			Write-Host ""
			Write-Host "	EXIT: ABY WYJSC - 10" -ForegroundColor White
		}

		do
			{
				Show-Menu
				SLEEP 1
				write-host ""
				Do
					{
						[int]$selection = $null
						[int]$selection = $(Write-Host "	DOKONAJ WYBORU WYBIERAJAC ODPOWIEDNI NUMER OPCJI. " -ForegroundColor green -NoNewLine) + $(Write-Host "ZATWIERDZ POPRZEZ ENTER: " -ForegroundColor Yellow -NoNewLine; Read-Host)
					}until (( [int]$selection -lt 11 ) -and ( [int]$selection -gt 0 ))

				switch ($selection)
					{
						'1' {	download_song	} 
						'2' {	download_from_list	} 
						'3' {	download_playlist	}
						'4' {	download_channel	}
						'5' {	download_movie_and_or_music_from_list	}
						'6' {	download_movie_and_or_music_from_list_PLAYLIST_AND_CHANNEL	}
						'7' {	download_from_cookie	}
						'8' {	updates_menu	}
						'9' {	youtube_dlp_dev	}
						'10'{	[Environment]::Exit(0)	}
						
					}
		pause
		}until (( [int]$selection -ne 10 ) -and ( [int]$selection -gt 0 ))
	}
else
	{
		function Show-Menu(){
			Clear-Host
			Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "Pobierak version: " ) -ForegroundColor Green -NoNewline; Write-Host "$pobierak_v" -ForegroundColor yellow
			write-host ""
			internal_info
			play_sound
			Write-Host ""
			Write-Host "	1: DOWNLOAD FROM YT LINKS PASTED ONE AFTER ANOTHER." -ForegroundColor Magenta
			Write-Host ""
			Write-Host "	2: DOWNLOAD SONGS FROM YT LINKS IN THE FILE." -ForegroundColor Yellow
			Write-Host ""
			Write-Host "	3: DOWNLOAD AUDIO FROM THE PLAYLIST." -ForegroundColor Magenta
			Write-Host ""
			Write-Host "	4: DOWNLOAD AUDIO FROM THE INDICATED YT CHANNEL." -ForegroundColor Yellow
			Write-Host ""
			Write-Host "	5: DOWNLOAD VIDEO AND / OR AUDIO (SINGLE SONGS)." -ForegroundColor Magenta
			Write-Host ""
			Write-Host "	6: DOWNLOAD VIDEO AND / OR AUDIO FROM PLAYLIST OR CHANNEL." -ForegroundColor Yellow
			Write-Host ""
			Write-Host "	7: DOWNLOAD FROM PRIVATE PLAYLIST IN YT PROFILE VIDEO AND / OR AUDIO." -ForegroundColor Magenta
			Write-Host ""
			Write-Host "	8: UPDATES MENU" -ForegroundColor Red
			Write-Host ""
			Write-Host "	EXIT: TO EXIT ENTER - 10" -ForegroundColor White
		}
		do
			{
				Show-Menu
				SLEEP 1
				write-host ""
				Do
					{
						 [int]$selection = $null
						[int]$selection = $(Write-Host "	MAKE YOUR CHOICE BY ENTERING THE RIGHT OPTION NUMBER." -ForegroundColor green -NoNewLine) + $(Write-Host "CONFIRM WITH ENTER: " -ForegroundColor Yellow -NoNewLine; Read-Host)
					}until (( [int]$selection -lt 11 ) -and ( [int]$selection -gt 0 ))

				switch ($selection)
					{
						'1' {	download_song	} 
						'2' {	download_from_list	} 
						'3' {	download_playlist	}
						'4' {	download_channel	}
						'5' {	download_movie_and_or_music_from_list	}
						'6' {	download_movie_and_or_music_from_list_PLAYLIST_AND_CHANNEL	}
						'7' {	download_from_cookie	}
						'8' {	updates_menu	}
						'9' {	youtube_dlp_dev	}
						'10'{	[Environment]::Exit(0)	}
						
					}
		pause
		}until (( [int]$selection -ne 10 ) -and ( [int]$selection -gt 0 ))
	}
}
#ENTER TO THE MAIN MENU
do
    {
    main_menu
    }while([int]$selection -ne 10 )
