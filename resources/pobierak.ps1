$pobierak_v = "3.453"

#GET SYS LANG
function get_lang(){
	$regkey = "HKCU:\Control Panel\Desktop" ;
	$name = "PreferredUILanguages" ;
	$get_lang = (Get-ItemProperty $regkey).PSObject.Properties.Name -contains $name ;
	if ( $get_lang -eq $false )
		{
			$lang = (Get-WinUserLanguageList).LocalizedName ;
		}
	else
		{
			$lang = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' PreferredUILanguages).PreferredUILanguages[0] ;
		}
	return $lang ;
}

[string]$language = get_lang ;

#VAR OF CURRENTLY LOGGED USER
$logged_usr = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).Split('\')[1] ;

#CLEAR MAIN VAR
$recources_main_dir = $null ;
$pobierakbat_main_dir = $null ;
$yt_dlp = $null ;
$ffmpeg = $null ;
$process_bak_primary_id = $null ;
$process_bak_id = $null ;

#GET POBIERAK PROCESS PID IF ACTIV FOR EVENTUALLY ERROR DETECTION
$process_bak_primary_id = Get-CimInstance Win32_Process | where commandline -match 'pobierak_primary.ps1'  | Select ProcessId | ForEach-Object {$_ -replace '\D',''} ;
$process_bak_id = Get-CimInstance Win32_Process | where commandline -match 'pobierak_bak.ps1'  | Select ProcessId | ForEach-Object {$_ -replace '\D',''} ;

#SET MAIN DIR 
$recources_main_dir =  Split-Path $PSCommandPath -Parent ;
#SET RECOURCES DIR
$pobierakbat_main_dir =  $recources_main_dir -replace 'Resources','' ;
#SET YT-DLP LOCATION
$yt_dlp = "$recources_main_dir\yt-dlp.exe" ;
#SET ffmpeg LOCATION
$ffmpeg = "$recources_main_dir\ffmpeg\ffmpeg\bin\ffmpeg.exe" ;

#SYS LANG IF PL THEN PL IF OTHER THEN EN

if (( $language -eq "pl-PL" ) -or ( $language -eq "Polski"))
    {
		$text_msg = Import-LocalizedData -BaseDirectory "$recources_main_dir\LANG\" -UICulture "pl-PL" ;
    }
else
    {
		$text_msg  = Import-LocalizedData -BaseDirectory "$recources_main_dir\LANG\" -UICulture "en-US" ;
    }

function play_sound(){
	
	$PlayWav=New-Object System.Media.SoundPlayer ;
	$PlayWav.SoundLocation="$recources_main_dir\Bottle.wav" ;
	$PlayWav.playsync()
	
}

#FUNCTION TO DISPLAY MAIN INFORMATION IN FIRST MENU
Function internal_info(){
	#YTDLP EXE EXIST ?
	if (Test-Path $yt_dlp) 
		{
			$yt_dlp_ver_1 = $(write-host $text_msg.internalinfo0 " " -NoNewLine -ForegroundColor yellow ) + $( Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--version" ) ;

		}
	#RESOURCES TEST ARRAY VAR
	$recources_test= @() ;
	$recources_test[0] ;
	#VARIABLES FOR TEST IF NECESSARY EXE EXISTS
	$test_resource_ffmpeg_if_exist = "$recources_main_dir\ffmpeg\ffmpeg\bin\ffmpeg.exe" ;
	$test_resource_yt_dlp_if_exist = "$recources_main_dir\yt-dlp.exe" ;
	#IF TEST VER ARE EMPTY THEN IS NO ERROR ELSE THERE IS A PROBLEM WITH MAIN SCRIPT
	if (( $process_bak_id -eq $null -and $process_bak_primary_id -eq $null ))
		{
			$critical_update_error = " " ;
		}
	else
		{
			$critical_update_error = ($(write-host $text_msg.criticalupdateerror1`n,$text_msg.criticalupdateerror2  -ForegroundColor Red )) ;		
			$recources_test += ," $critical_update_error" ; #ADD TO ARRAY INFO ABOUT CRITICAL ERROR IF EXIST
		}
	#TEST IF FFMPEG IS ALREADY DOWNLOADED
	if (Test-Path $test_resource_ffmpeg_if_exist) 
		{
			$resource_ffmpeg = " " ;
			$recources_test += ," $resource_ffmpeg" ;                 
		}
	else
		{
			$warning_missing_resource = ($( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), $text_msg.warning ) -ForegroundColor RED )) ;
			$resource_ffmpeg = ($(write-host $text_msg.ffmpglib`n,$text_msg.updpath -ForegroundColor Red )) ;        
				
			$recources_test += ," $warning_missing_resource" ;
			$recources_test += ," $resource_ffmpeg" ;
		}
	#TEST IF YTDLP IS ALREADY DOWNLOADED
	if (Test-Path $test_resource_yt_dlp_if_exist) 
		{
			$resource_yt_dlp = " " ;
			$recources_test += ," $resource_yt_dlp" ;                
		}
	else
		{
			$warning_missing_resource = ($( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), $text_msg.warning ) -ForegroundColor RED )) ;
			$resource_yt_dlp = ($(write-host $text_msg.ytdlpexe`n,$text_msg.updpath -ForegroundColor Red )) ;
			$recources_test += ," $warning_missing_resource" ;
			$recources_test += ," $resource_yt_dlp" ;
		}
	#RETURN INFO ABOUT DETECTED ERRORS OR NOT
	Return ,$recources_test ;

}
#GUI NOTIFICATION ABOUT THE NEED TO SELECT A FILE CONTAINING LINKS TO YT
Function warning_select_file(){
	#LOAD GUI WINDOW IN CONSTRUCT BLOCK
	[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null;
	#PROMT MESSAGE
	[System.Windows.Forms.MessageBox]::Show($text_msg.selectfile,'WARNING')
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
	
	$objForm = New-Object System.Windows.Forms.FolderBrowserDialog
	$Description = $text_msg.selectdir ;
	$objForm.Rootfolder = $RootFolder ;
	$objForm.Description = $Description ;
	$Show = $objForm.ShowDialog() ;
		If ($Show -eq "OK")
			{
				Return $objForm.SelectedPath
			}
		Else
			{
				Write-Error "Operation cancelled by user."
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
	#SEARCH PATTERN FOR PLAYLIST
	$ignore_link = 0
	#FILTER YT LINK TO FIND REFERENCESS PLAYLISTS
	$yt_link_filter_plli = $testlink | Select-String -pattern "&list" ;
	#FILTER YT LINK TO FIND REFERENCESS TO PLAYLISTS 2
	$yt_link_filter_plli_1 = $testlink | Select-String -pattern "list=" ;
	#FILTER YT LINK TO FIND REFERENCESS TO CHANNEL
	$yt_link_filter_channel = $testlink | Select-String -pattern "channel" ;
	#SEARCH PATTERN FOR &ab_channel
	$yt_link_filter_ab_channel = $testlink | Select-String -pattern "&ab_channel" ;
	#IF &ab_channel IS DETECTED AND NO PLAYLIST - CORRECT IT TO DOWNLOAD ONE TRACK LINK
	if (( $yt_link_filter_ab_channel -ne $null ) -and ( $yt_link_filter_plli -eq $null ) )
		{
			$pattern = '(?<=\=).+?(?=\&)'
			$singel_link_after_filter = [regex]::Matches($yt_link_filter_ab_channel, $pattern).Value | Select-Object -First 1
			$correct_single_link = "https://www.youtube.com/watch?v=$singel_link_after_filter"
			write-host "--------------------------------------------------------------------------"
			Start-Sleep -Milliseconds 500
			write-host $text_msg.abchanneldiscovered0 -ForegroundColor Red
			write-host ""
			Start-Sleep -Milliseconds 500
			($(write-host $text_msg.abchanneldiscovered1 -ForegroundColor Green -nonewline ) + $( write-host "$correct_single_link" -ForegroundColor YELLOW ; ))
			write-host ""
			Start-Sleep -Milliseconds 500
			write-host $text_msg.abandchanneldiscovered -ForegroundColor Magenta
			write-host "--------------------------------------------------------------------------"
			$correct_single_link >> "$recources_main_dir\songs_out.txt"
			$ignore_link = 1 ;							
		}
	#IF channel IS DETECTED - IGNORE THE LINK
	if (( $yt_link_filter_channel -ne $null ) -and ($yt_link_filter_ab_channel -eq $null ))
		{
			write-host "--------------------------------------------------------------------------------------------------------"
			Start-Sleep -Milliseconds 500
			write-host $text_msg.channeldiscovered0 -ForegroundColor Red
			write-host ""
			Start-Sleep -Milliseconds 500
			write-host $text_msg.channeldiscovered1 -ForegroundColor Red
			write-host ""
			Start-Sleep -Milliseconds 500
			write-host $text_msg.channeldiscovered2 -ForegroundColor Magenta
			write-host ""
			Start-Sleep -Milliseconds 500
			write-host $text_msg.abandchanneldiscovered -ForegroundColor Magenta
			write-host "--------------------------------------------------------------------------------------------------------"
			$ignore_link = 1 ;
		}
	if ($yt_link_filter_plli -ne $null )
		{
			$pattern = '(?<=\=).+?(?=\&)'
			$singel_link_after_filter = [regex]::Matches($yt_link_filter_plli, $pattern).Value | Select-Object -First 1
			$correct_single_link = "https://www.youtube.com/watch?v=$singel_link_after_filter"
			write-host "--------------------------------------------------------------------------"
			Start-Sleep -Milliseconds 500
			write-host $text_msg.plylistdicovered0 -ForegroundColor Red
			write-host ""
			Start-Sleep -Milliseconds 500
			($(write-host $text_msg.plylistdicovered1 -ForegroundColor Green -nonewline ) + $( write-host "$correct_single_link" -ForegroundColor YELLOW ; ))
			write-host ""
			Start-Sleep -Milliseconds 500
			write-host $text_msg.plylistdicovered2 -ForegroundColor Magenta
			write-host "--------------------------------------------------------------------------"
			$correct_single_link >> "$recources_main_dir\songs_out.txt"
			$ignore_link = 1 ;
		}
	if ($yt_link_filter_plli_1 -ne $null )
		{
			write-host "--------------------------------------------------------------------------"
			Start-Sleep -Milliseconds 500
			write-host $text_msg.plylistdicovered0 -ForegroundColor RED
			write-host ""
			Start-Sleep -Milliseconds 500
			write-host $text_msg.plylistdicovered01 -ForegroundColor RED
			write-host ""
			Start-Sleep -Milliseconds 500
			write-host $text_msg.plylistdicovered2 -ForegroundColor Magenta
			write-host "--------------------------------------------------------------------------"
			$ignore_link = 1
		}
	#IF NONE OF ABOVE ARE DETECTED = LINK IS OK - WRITE LINK TO FILE
	if	(( $ignore_link -ne 1 ))
		{
			$testlink >>	"$recources_main_dir\songs_out.txt"
		}
}
#FUNCTION TO GET AUDIO QUALITY
function audio_quality(){
	do
		{	#GET INPUT WITH AUDIO QUALITY OUT VALUES - 128 kbps or 320 kbps
			Write-Host ""
			SLEEP 1
			[string]$quality = ($(Write-Host $text_msg.quality0 -ForegroundColor green)) + ($(Write-Host $text_msg.quality1 -ForegroundColor yellow -NoNewLine ; Read-Host))
		}while(($quality -ne "128K"  ) -and ($quality -ne "320K"))
		
	return [string]$quality
	
}
function audio_0_1(){
	do
		{
			SLEEP 1
			write-host ""
			[int]$audio_yes_no = ($(Write-Host $text_msg.audio010 -ForegroundColor Yellow)) + ($(Write-Host $text_msg.audio011 -ForegroundColor yellow -NoNewLine ; Read-Host))
		}while(($audio_yes_no -ne 1) -and ($audio_yes_no -ne 2))
	return [int]$audio_yes_no
}

function video_0_1(){
	do
		{
			SLEEP 1
			write-host ""
			[int]$video_yes_no = ($(Write-Host $text_msg.video010 -ForegroundColor Yellow)) + ($(Write-Host $text_msg.video011 -ForegroundColor yellow -NoNewLine ; Read-Host))
		}while(($video_yes_no -ne 1  ) -and ($video_yes_no -ne 2))
	return [int]$video_yes_no
}

function video_format(){
	do
		{
			SLEEP 1
			write-host ""
			[string]$viedo_format = ($(Write-Host $text_msg.videoformat0 -ForegroundColor green)) + ($(Write-Host $text_msg.videoformat1 -ForegroundColor yellow -NoNewLine ; Read-Host))
		}while(($viedo_format -ne "avi") -and ($viedo_format -ne "mp4"))
	return [string]$viedo_format
}

function ytdlp_download_audio(){
	if ( $song_count -eq $null )
		{
			Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s " , "$track"
		}
	else
		{
			write-host	$text_msg.downloadingaudio0 $song_count $text_msg.downloadingaudio1 $lines_var -ForegroundColor yellow
			Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s " , "$track"
		}
}

function ytdlp_download_video(){
	write-host	$text_msg.downloadingvideo0 $song_count $text_msg.downloadingvideo1 $lines_var -ForegroundColor yellow
	Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s " , "$track"
}

##############################################################################
#1 FUNCTION TO DOWNLOAD FROM LINKS BY ENTERING THEM IN CONSOLE ONE BY ONE #1 #
##############################################################################
function download_song(){
cls
	write-host ""
	sleep 1
	Write-Host $text_msg.downloadsongintro -ForegroundColor Yellow
		
	#TEST IF OLD  LIST WITH LINK EXIST - IF SO - THEN REMOVE
	$path2song_list_single = "$recources_main_dir\songs_out.txt"
	If (Test-Path $path2song_list_single)
		{
			Remove-Item -Path $path2song_list_single
		}
	#DO LOOP FOR ENTER LINKS FROM YOUTUBE
	do
		{
			SLEEP 1
			#GET INPUT WITH YT LINK
			Write-Host ""
			[string]$s = ($(write-host $text_msg.downloadsonginfo0`n,$text_msg.downloadsonginfo1`n -ForegroundColor Green )) + ($(Write-Host $text_msg.downloadsonginfo2`n -ForegroundColor yellow -NoNewLine ; Read-Host))
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
		$source = Get-Content -Path "$recources_main_dir\songs_out.txt" | Where { $_ }
		
		#LINES COUNTER
		$lines_var = Get-Content "$recources_main_dir\songs_out.txt" | Where { $_ }
		
    	[int]$lines_var = $lines_var.Count
		#PATH TO OUTPUT DIR
		$output_directory = Select-Folder
		$free_space = Get-FreeSpace
		sleep 1
		write-host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
		sleep 2
		#SHOW OWER EXPLORER THE TARGET DIR
		Start explorer.exe $output_directory
		[int]$lines_var-=1
		[int]$song_count=0
		#MAIN LOOP TO DOWNLOAD ENTERED AND CORRECTED SONGS FROM YT LINKS
		ForEach ($track in $source)
			{
				$song_count+= 1 #COUNTER FOR SONGS TO DOWNLOAD
				ytdlp_download_audio
				$lines_var-= 1 #SUB - HOW MANY LEFT
			}
		#REMOVE PATH WITH SONG LIST CREATED AFTER DOWNLOAD LOOP
		Remove-Item -Path "$recources_main_dir\songs_out.txt" -Force

		write-host ""
		Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewline
}
#######################################################################
#2 FUNCTION TO DOWNLOAD FROM LINKS WHICH ARE ALREADY SAVED IN FILE #2 #
#######################################################################
Function download_from_list(){
    cls
			write-host ""
			sleep 1
			Write-Host $text_msg.downloadfromlistintro -ForegroundColor Yellow
			write-host ""
			sleep 1

	#GET A PATH TO FILE FROM THE EXPLORER GUI THAT CONTAINS PREVIOUS SAVED LINKS TO YT INTO VAR $selected_file_var
    warning_select_file
    $selected_file_var = Select-File
	#REMOVE EMPTY LINES IF EXIST
    $d = Get-Content -Path $selected_file_var | Where { $_ }
	
                           
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

	sleep 1
	write-host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
	sleep 2
	#SHOW OWER WINDWOS EXPLORER THE TARGET DIR
    Start explorer.exe $output_directory
	#LINES COUNTER
	$lines_var = Get-Content "$recources_main_dir\songs_out.txt" | Where { $_ }
	$lines_var = $lines_var.trim() -ne ""
	[int]$lines_var = $lines_var.Count
    [int]$lines_var-=1
	[int]$song_count=0
	
	#$selected_file_var POINTET TO songs_out.txt
	$selected_file_var = "$recources_main_dir\songs_out.txt"
	#PARSE FILE CONTENT
	$source = Get-Content -Path $selected_file_var
	
	#MAIN LOOP FOR DOWNLOAD
	ForEach ($track in $source) 
		{
			$song_count+= 1 #COUNTER FOR SONGS TO DOWNLOAD
			ytdlp_download_audio
			$lines_var-= 1 #SUB - HOW MANY LEFT
		}
		
	Remove-Item -Path "$recources_main_dir\songs_out.txt"
	
	write-host ""
	Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewline			
}
###########################################
#3 FUNCTION TO DOWNLOAD WHOLE PLAYLIST #3 #
###########################################
Function download_playlist(){
    cls
	write-host ""
	sleep 1
	Write-Host $text_msg.downloadplaylistintro -ForegroundColor Yellow
	write-host ""
	SLEEP 1
	[string]$playlist_ID_yt = ($(write-host $text_msg.downloadplaylistinfo0`n,$text_msg.downloadplaylistinfo1 -ForegroundColor yellow )) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green) + ($(Write-Host $text_msg.downloadplaylistinfo2`n -ForegroundColor yellow -NoNewLine ; Read-Host))
	
    #GET AUDIO QUALITY
	[string]$quality = audio_quality

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder
	$free_space = Get-FreeSpace
	sleep 1
	write-host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
	sleep 2
	#SHOW OWER WINDWOS EXPLORER THE TARGET DIR
    Start explorer.exe $output_directory
	#MAIN DOWNLOAD PROCESS
    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --yes-playlist --output ""$output_directory""\%(title)s.%(ext)s " , "$playlist_ID_yt"

	write-host ""
	Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewline
}
##########################################
#4 FUNCTION TO DOWNLOAD WHOLE CHANNEL #4 #
##########################################
Function download_channel(){
	cls
	sleep 1
	Write-Host $text_msg.downloadchannelintro -ForegroundColor Yellow
	write-host ""
	SLEEP 1
	
	[string]$channel_ID_yt = ($(write-host $text_msg.downloadchannelinfo0`n,$text_msg.downloadchannelinfo1 -ForegroundColor yellow )) + ($(Write-Host $text_msg.downloadchannelinfo2`n -ForegroundColor yellow -NoNewLine ; Read-Host))
	[string]$channel_ID_yt = "https://www.youtube.com/channel/$channel_ID_yt"

    #GET AUDIO QUALITY
	[string]$quality = audio_quality
    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder
	#SHOW OWER WINDWOS EXPLORER THE TARGET DIR
    Start explorer.exe $output_directory
	#GET FREE SPACE
	$free_space = Get-FreeSpace
	sleep 1
	write-host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
	sleep 2
	#MAIN DOWNLOAD PROCESS
    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "-ciw --extract-audio --audio-format mp3 --ffmpeg-location ""$ffmpeg"" --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s " , "$channel_ID_yt"
	
	write-host ""
	Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewline

}
##############################################################################################################
#5 FUNCTION TO DOWNLOAD VIDEO OR AUDIO FROM SINGLE LINKS ENTERED IN THE TERMINAL OR ALREADY PREPARED LIST #5 #
##############################################################################################################
Function download_movie_and_or_music_from_list(){
	cls
	sleep 1
	Write-Host $text_msg.fun5intro -ForegroundColor Yellow
	write-host ""
	SLEEP 1
	
	$path2song_list_select_file = "$recources_main_dir\songs_out.txt"
	If (Test-Path $path2song_list_select_file)
		{
			Remove-Item -Path $path2song_list_select_file
		}
	do
		{
			SLEEP 1
			write-host ""
			[int]$list_console = ($(write-host $text_msg.fun5listorterminal0`n -ForegroundColor Yellow )) + ($(Write-Host $text_msg.fun5listorterminal1 -ForegroundColor yellow -NoNewLine ; Read-Host))
		}while(($list_console -ne 1  ) -and ($list_console -ne 2))


	if ( $list_console -eq 1)
		{
			#TXT FILE WITH SAVED YT LINKS
			warning_select_file
			$selected_file_var = Select-File
			#GET LINKS FROM THE TXT FILE

			$source = Get-Content -Path $selected_file_var | Where { $_ }
			
			foreach ( $line in $source )
				{
					$testlink = $line
					filter_links	#FILTER PARSED LINKS FROM FILE					
				}
		}
	elseif ( $list_console -eq 2)
		{
			do
				{
					SLEEP 1
					#GET INPUT WITH YT LINK
					Write-Host ""
					[string]$link = ($(write-host $text_msg.downloadsonginfo0`n,$text_msg.downloadsonginfo1`n -ForegroundColor Green )) + ($(Write-Host $text_msg.downloadsonginfo2`n -ForegroundColor yellow -NoNewLine ; Read-Host))
						if ( $link -eq "q" )
							{
							}
						else
							{
								#VAR WITH YT LINK TO FILTER REFERENCES TO A CHANNEL OR PLAYLIST
								$testlink = "$link"
								filter_links $testlink							
							}
				}until($link -eq "q"  )
		}
	#SET PATH FOR LINK LIST
	$source = Get-Content -Path "$recources_main_dir\songs_out.txt" | Where { $_ }
	
	
	$viedo_format = video_format
	$audio_yes_no = audio_0_1

    if ( $audio_yes_no -eq 1 )
        {
			#GET AUDIO QUALITY
			[string]$quality = audio_quality
		}
	#PATH TO OUTPUT DIR
	$output_directory = Select-Folder
	
	$free_space = Get-FreeSpace
	
	sleep 1
	write-host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
	sleep 2	
	Start explorer.exe $output_directory

	if ( $list_console -eq 1)
	{	
		[int]$lines_var = $source.Count	
		[int]$lines_var-=1
		[int]$song_count=0
	
			
		if ( $audio_yes_no -eq 1 )
			{			
				ForEach ($track in $source ) 
					{
						$song_count+= 1 #COUNTER FOR SONGS TO DOWNLOAD
						ytdlp_download_audio
						ytdlp_download_video
						$lines_var-= 1 #SUB - HOW MANY LEFT
					}
			}
		if ( $audio_yes_no -eq 2 )
			{			
				ForEach ($track in $source) 
					{
						$song_count+= 1 #COUNTER FOR SONGS TO DOWNLOAD
						ytdlp_download_video
						$lines_var-= 1 #SUB - HOW MANY LEFT
					}
			}
			
	}
	if ( $list_console -eq 2)
		{
			[int]$lines_var = $source.Count	
			[int]$lines_var-=1
			[int]$song_count=0
	
			
			if ( $audio_yes_no -eq 1 )
				{			
					ForEach ($track in $source ) 
						{
							$song_count+= 1 #COUNTER FOR SONGS TO DOWNLOAD
							ytdlp_download_audio
							ytdlp_download_video
							$lines_var-= 1 #SUB - HOW MANY LEFT
						}
				}
			if ( $audio_yes_no -eq 2 )
				{			
					ForEach ($track in $source) 
						{
							$song_count+= 1 #COUNTER FOR SONGS TO DOWNLOAD
							ytdlp_download_video
							$lines_var-= 1 #SUB - HOW MANY LEFT
						}
				}
     	
		}
    	
	If (Test-Path "$recources_main_dir\songs_out.txt")
		{
			Remove-Item -Path "$recources_main_dir\songs_out.txt"
		}
	
	write-host ""
	Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewline

}
###########################################################
#6 DOWNLOADING AUDIO OR VIDEO FROM PLAYLIST OR CHANNEL #6 #
###########################################################
Function download_movie_and_or_music_from_list_PLAYLIST_AND_CHANNEL(){
cls
	sleep 1
	Write-Host $text_msg.fun6intro -ForegroundColor Yellow
	write-host ""
	SLEEP 1
	If (Test-Path "$recources_main_dir\songs.txt")
		{
			Remove-Item -Path "$recources_main_dir\songs.txt"
		}
	do
		{
			SLEEP 1
			Write-Host ""
			(write-host $text_msg.downloadplaylistinfo0`n,$text_msg.downloadplaylistinfo1 -ForegroundColor yellow) + (Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta) + (Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)
			write-host ""
			($(write-host $text_msg.downloadchannelinfo0`n,$text_msg.downloadchannelinfo1 -ForegroundColor yellow )) + ($(Write-Host $text_msg.downloadchannelinfo2`n -ForegroundColor yellow -NoNewLine ))
			write-host ""
			[string]$s = ($(Write-Host $text_msg.downloadsonginfo2 -ForegroundColor yellow -NoNewLine ; Read-Host))
			if ( $s -eq "q" )
				{
				}else{$s >> "$recources_main_dir\songs.txt"}          
		}until($s -eq "q"  )
		
	$viedo_format = video_format
	$audio_yes_no = audio_0_1
	
	$source = Get-Content -Path "$recources_main_dir\songs.txt" | Where { $_ }
	#PATH TO OUTPUT DIR
	$output_directory = Select-Folder
	Start explorer.exe $output_directory
	$free_space = Get-FreeSpace
	
	sleep 1
	write-host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
	sleep 2		
	$lines_var-=$null
	$song_count=$null
	if ( $audio_yes_no -eq 1 )
		{			
			ForEach ($track in $source ) 
				{
					ytdlp_download_audio
					ytdlp_download_video
				}
		}
	if ( $audio_yes_no -eq 2 )
		{			
			ForEach ($track in $source) 
				{
					ytdlp_download_video
				}
		}
		Remove-Item -Path "$recources_main_dir\songs.txt"
    write-host ""
	Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewline
}
###############################################
#7 DOWNLOAD FROM PRIVATE PLAYLIST = COOKIES #7#
###############################################
function download_from_cookie(){
cls
	sleep 1
	Write-Host $text_msg.downloadfromcookieintro -ForegroundColor Yellow
	write-host ""
	SLEEP 1
	
	$path2song_list_single = "$recources_main_dir\songs.txt"
	If (Test-Path $path2song_list_single)
		{
			Remove-Item -Path $path2song_list_single
		}
	
	do
		{
			SLEEP 1
			(write-host $text_msg.downloadfromcookiewarn0`n -ForegroundColor yellow) + (write-host $text_msg.downloadfromcookiewarn1`n,$text_msg.downloadfromcookiewarn2`n -ForegroundColor RED) + (write-host $text_msg.downloadfromcookiewarn3`n -ForegroundColor yellow) + (write-host $text_msg.downloadfromcookiewarn4`n -ForegroundColor red) 
			Start-Sleep -Milliseconds 1000
			[string]$web_browser = ($(Write-Host $text_msg.downloadfromcookieinfo -ForegroundColor yellow -NoNewLine ; Read-Host))
			
		}while(($web_browser -ne 'chrome')  -and ($web_browser -ne 'firefox') -and  ($web_browser -ne 'edge'))
		

	SLEEP 1
    Write-Host ""
	if ( $web_browser -eq "firefox" )
		{
			$dir_4_borowser_cookies = "C:\Users\$logged_usr\AppData\Roaming\Mozilla\Firefox\Profiles"
			$latest_profile = Get-ChildItem -Path $dir_4_borowser_cookies | Sort-Object LastAccessTime -Descending | Select-Object -First 1
		}
	elseif ( $web_browser -eq "edge" )
		{
		
			$dir_4_borowser_cookies = "C:\Users\$logged_usr\AppData\Local\Microsoft\Edge\User Data\Default"
			$latest_profile = $dir_4_borowser_cookies
			Stop-Process -Name "msedge" -ErrorAction SilentlyContinue
			Start-Process -FilePath ("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe") -ArgumentList "--disable-features=LockProfileCookieDatabase"
		
		}
	if ( $web_browser -eq "chrome" )
		{
			$dir_4_borowser_cookies = "C:\Users\$logged_usr\AppData\Local\Google\Chrome\User Data\Default"
			$latest_profile = $dir_4_borowser_cookies	
			Stop-Process -Name "chrome" -ErrorAction SilentlyContinue
			Start-Process -FilePath ("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe") -ArgumentList "--disable-features=LockProfileCookieDatabase"
		}
		
	[string]$playlist_ID_yt = ($(write-host $text_msg.downloadplaylistinfo0`n,$text_msg.downloadplaylistinfo1 -ForegroundColor yellow )) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green) + ($(Write-Host $text_msg.downloadplaylistinfo2`n -ForegroundColor yellow -NoNewLine ; Read-Host))

	If (Test-Path $path2song_list_single)
		{
			$entered_playlist_console = Get-Content -Path "$recources_main_dir\songs.txt"	| Where { $_ }
		}	
	
	$video_yes_no = video_0_1
	
	if ( $video_yes_no -eq 1 )
		{	
			sleep 1
			$viedo_format = video_format					
		}
		
	if ( $video_yes_no -eq 1 )
		{
			SLEEP 1
			$audio_yes_no = audio_0_1				
		}
    
	if (( $audio_yes_no -eq 1 ) -or ( $video_yes_no -eq 2 ))
		{
			#GET AUDIO QUALITY
			[string]$quality = audio_quality		
		}
		

	#PATH TO OUTPUT DIR
	$output_directory = Select-Folder
	Start explorer.exe $output_directory
	
	$free_space = Get-FreeSpace
	
	sleep 1
	write-host $text_msg.freespace "$free_space GB." -ForegroundColor Yellow
	sleep 2	
	

	if ( $video_yes_no -eq 1)
		{
			if ( $audio_yes_no -eq 1 )
				{
					write-host " "
					(write-host $text_msg.downloadfromcookieaudio0`n,$text_msg.downloadfromcookieaudio1 -ForegroundColor yellow)
					write-host " "
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --extract-audio --audio-format mp3 --output ""$output_directory""\%(title)s.%(ext)s --audio-quality ""$quality"" --cookies-from-browser ""$web_browser"":""$latest_profile"" " , "$playlist_ID_yt"
					write-host " "
					(write-host $text_msg.downloadfromcookieaudio2 -ForegroundColor yellow)
					(write-host $text_msg.downloadfromcookievideo0`n -ForegroundColor yellow)
					write-host " "
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format""  --output ""$output_directory""\%(title)s.%(ext)s $a --cookies-from-browser ""$web_browser"":""$latest_profile"" " , "$playlist_ID_yt"
					write-host " "
					(write-host $text_msg.downloadfromcookievideo1`n -ForegroundColor yellow)
						
				}
			if ( $audio_yes_no -eq 2 )
				{
					write-host " "
					(write-host $text_msg.downloadfromcookievideo0`n -ForegroundColor yellow)
					write-host " "
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format""  --output ""$output_directory""\%(title)s.%(ext)s $a --cookies-from-browser ""$web_browser"":""$latest_profile"" " , "$playlist_ID_yt"
					write-host " "
					(write-host $text_msg.downloadfromcookievideo1`n -ForegroundColor yellow)
				}
		}	
	
	if ( $video_yes_no -eq 2)
		{		
			write-host " "
			(write-host $text_msg.downloadfromcookieaudio1 -ForegroundColor yellow)
			write-host " "
			Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --extract-audio --audio-format mp3 --output ""$output_directory""\%(title)s.%(ext)s --audio-quality ""$quality"" --cookies-from-browser ""$web_browser"":""$latest_profile"" " , "$playlist_ID_yt"
			write-host " "
			(write-host $text_msg.downloadfromcookieaudio2 -ForegroundColor yellow)
								
		}		
	write-host ""
	Write-Host $text_msg.downloadend -ForegroundColor Green -NoNewline
	Remove-Item -Path "$recources_main_dir\songs.txt"		
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

		if ( $pobierak_downloaded_double -gt $version_present_double  )
			{
				Write-Host ""
				SLEEP 1
				write-host $text_msg.checkpobierakversion00 " $pobierak_downloaded_double"  -ForegroundColor green
				Write-Host ""
				SLEEP 1
				write-host $text_msg.checkpobierakversion10`n -ForegroundColor green
				if (( $language -eq "pl-PL" ) -or ( $language -eq "Polski"))
					{
						$whats_new = (Get-Content "$path_to_temp\pobierak\pobierak4windows-main\resources\LANG\pl-PL\pobierak.psd1"  | Select-String "news00" | Out-String)
					}
				else
					{
						$whats_new = (Get-Content "$path_to_temp\pobierak\pobierak4windows-main\resources\LANG\en-US\pobierak.psd1"  | Select-String "news00" | Out-String)
					}
				$whats_new.split(";").trim() -ne ""			
				do
					{
						Write-Host ""
						SLEEP 1
						[int]$instal_or_not = ($(Write-Host $text_msg.checkpobierakversion01`n,$text_msg.checkpobierakversion02`n -ForegroundColor green ; Read-Host))
					}while(([int]$instal_or_not -ne 1  ) -and ([int]$instal_or_not -ne 2))
			}
		else
			{	#PRESENT VER OF POBIERAK
				Write-Host ""
				SLEEP 1
				write-host $text_msg.checkpobierakversion03`n,$text_msg.checkpobierakversion04 "$version_present" -ForegroundColor red
				Remove-Item $path_to_temp -Force -Recurse
				Write-Host ""                 
				SLEEP 3
				if ( $selection_update -eq 1 )
					{
						main_menu
					}
			}
			
        if ( $instal_or_not -eq 1 )
            {
				
				Write-Host ""
				SLEEP 1
				Write-Host $text_msg.checkpobierakversionupd01
				
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
                Copy-Item  	-Path $recources_main_dir\pobierak.ps1 $recources_main_dir\pobierak_bak.ps1	#FOR BACKUP PURPOSES pobierak.ps1 IS COPIED AND RENAMED TO pobierak_bak.ps1 
                Copy-Item  	-Path $path_to_temp\pobierak\pobierak4windows-main\resources\pobierak.ps1 $recources_main_dir\pobierak.ps1	#COPY NEW VERSION OF POBIERAK TO MAIN DIR
                Copy-Item	-Path $path_to_temp\pobierak\pobierak4windows-main\*	$pobierakbat_main_dir\ -Recurse -ErrorAction SilentlyContinue
				
				
				Write-Host ""
				SLEEP 1
				Write-Host $text_msg.checkpobierakversionupd02
				Remove-Item $path_to_temp -Force -Recurse #REMOVE TEMP WITH DOWNLOADED POBIERAK AFTER COPY TO MAIN DIR
				
				if (($selection_update -eq 1) -and ($instal_or_not -eq 1))
					{
						Write-Host ""
						SLEEP 1
						Write-Host $text_msg.checkpobierakversionupd03
						Write-Host ""
						SLEEP 5
						Start-Process $pobierakbat_main_dir\pobierak.bat  -ArgumentList "-noexit" #START NEW POBIERAK VERSION
      						sleep 1
						[Environment]::Exit(0)
					}			
			}
        else
            {
                #PRESENT VER OF POBIERAK
				Write-Host ""
				SLEEP 1
				write-host $text_msg.checkpobierakversion03`n,$text_msg.checkpobierakversion04 "$version_present" -ForegroundColor red
				Remove-Item $path_to_temp -Force -Recurse
				Write-Host ""                 
				SLEEP 3
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
			Write-Host ""
			SLEEP 1
			Write-Host $text_msg.ffmpgupd00
		
		#DONWLOAD NEW FFMPEG REPO FROM GITHUB GyanD TO ffmpeg.zip
		
        Start-BitsTransfer -Source "https://github.com/GyanD/codexffmpeg/releases/download/7.0/ffmpeg-7.0-essentials_build.zip" -Destination "$recources_main_dir\ffmpeg.zip"
		
		SLEEP 1
		Write-Host ""
		Write-Host $text_msg.ffmpgupd01,$text_msg.ffmpgupd02 -ForegroundColor green
		Write-Host ""
		SLEEP 1
		
		
		#FIND ZIP WITH FFMPEG IN MAIN DIR AND EXPAND ARCHIVE TO MAIN DIR\ffmpeg
        Get-ChildItem $recources_main_dir -Filter *.zip | ForEach { Expand-Archive -Path $_.FullName -DestinationPath $recources_main_dir\ffmpeg -Force}
		
		#DELETE DOWNLOADED ZIP WITH FFMPEG AFTER EXTRACTION
        Get-ChildItem $recources_main_dir -Filter *.zip | Remove-Item
		#SET EXTRACTED DIR
        $recources_main_dir_unzipped = "$recources_main_dir\ffmpeg"	
		#FIND EXTRACTED FOLDER NAME AND COPY IT TO MAIN DIR"
        $unzipped_dir = get-ChildItem -Path $recources_main_dir_unzipped -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 1 | Rename-Item -NewName ffmpeg
		Write-Host $text_msg.ffmpgupd03`n,$text_msg.ffmpgupd04 -ForegroundColor green

    }
	#######################
	#3 DOWNLOAD YT-DLP# 3 #
	#######################
    Function download_yt_dlp(){
		#https://github.com/yt-dlp/yt-dlp
		Write-Host ""
		SLEEP 1
		Write-Host $text_msg.ytdlpupd00 -ForegroundColor green
		Start-BitsTransfer -Source "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -Destination "$recources_main_dir\yt-dlp.exe" #DOWNLOAD YT-DPL
		Write-Host $text_msg.ytdlpupd01 -ForegroundColor green
			
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
				Write-Host ""
				$text_msg.allinone00
				SLEEP 1
				$text_msg.checkpobierakversionupd03
				Write-Host ""
				SLEEP 5
				Start-Process $pobierakbat_main_dir\pobierak.bat -ArgumentList "-noexit" 
    				sleep 1
				[Environment]::Exit(0)			
			}
		else
			{
				$text_msg.allinone00
				SLEEP 3
				main_menu					
			}
    }
	##############################
	#5 RESTOR PREVIUSE VERSION#5 #
	##############################
	Function previous_version(){
		do
			{
				Write-Host ""
				SLEEP 1
				[int]$previous_version = ($(Write-Host $text_msg.previousversion00 -ForegroundColor Yellow)) + ($(Write-Host $text_msg.checkpobierakversion02 -ForegroundColor yellow -NoNewLine ; Read-Host))
					}while(($previous_version -ne 1  ) -and ($previous_version -ne 2))
				if ( $previous_version -eq 1 )
					{
						sleep 1
						write-host ""
						write-host $text_msg.previousversion01 -ForegroundColor green
						sleep 1
						write-host ""
						Copy-Item  -Path $recources_main_dir\pobierak_bak.ps1 $recources_main_dir\pobierak.ps1
						sleep 1
						write-host ""
						write-host $text_msg.previousversion02 -ForegroundColor green
						sleep 1
						write-host ""
						Start-Process $pobierakbat_main_dir\pobierak.bat
						sleep 1
                        			EXIT 0
					}
				if ( $previous_version -eq 2 )
					{
						write-host $text_msg.previousversion03 -ForegroundColor red
                        SLEEP 3
                        main_menu
					}
			
	}

#############################
######## UPDATE MENU ########
#############################
    function Show_updates_Menu(){
		Clear-Host
		Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), $text_msg.updmenu00 ) -ForegroundColor Green -NoNewline; Write-Host "$pobierak_v" -ForegroundColor yellow
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
	do
		{
			Show_updates_Menu
			SLEEP 1
			write-host ""
			Do
				{
					[int]$selection_update = ($(Write-Host $text_msg.updmenu07 -ForegroundColor green)) + ($(Write-Host $text_msg.updmenu08 -ForegroundColor yellow -NoNewLine ; Read-Host))
				}until(($selection_update -lt 7  ) -and ($selection_update -gt 0))

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
###########################
######## YT-DL DEV ########
###########################
function youtube_dlp_dev(){
cls
write-host	$text_msg.ytdlpdevintro01`n,$song_count $text_msg.ytdlpdevintro02`n,$text_msg.ytdlpdevintro03 -ForegroundColor yellow			
	do
		{
			write-host ""
			SLEEP 1
			[string]$arguments = ($(Write-Host $text_msg.ytdlpdev00 -ForegroundColor green -NoNewLine)) + ($(Write-Host $text_msg.ytdlpdev01 -ForegroundColor RED ; Read-Host))
				Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList """$arguments"""
		}until($arguments -eq "quit")
		Write-Host $text_msg.ytdlpdev02 -ForegroundColor green
}
###########################
######## MAIN MENU ########
###########################
function main_menu(){

	function Show-Menu(){
		Clear-Host
		Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), $text_msg.mainmenu00 ) -ForegroundColor Green -NoNewline; Write-Host "$pobierak_v" -ForegroundColor yellow
		write-host ""
		internal_info
		play_sound
		Write-Host ""
		Write-Host "	"$text_msg.mainmenu01 -ForegroundColor Magenta
		Write-Host ""
		Write-Host "	"$text_msg.mainmenu02 -ForegroundColor Yellow
		Write-Host ""
		Write-Host "	"$text_msg.mainmenu03 -ForegroundColor Magenta
		Write-Host ""
		Write-Host "	"$text_msg.mainmenu04 -ForegroundColor Yellow
		Write-Host ""
		Write-Host "	"$text_msg.mainmenu05 -ForegroundColor Magenta
		Write-Host ""
		Write-Host "	"$text_msg.mainmenu06 -ForegroundColor Yellow
		Write-Host ""
		Write-Host "	"$text_msg.mainmenu07 -ForegroundColor Magenta
		Write-Host ""
		Write-Host "	"$text_msg.mainmenu08 -ForegroundColor Red
		Write-Host ""
		Write-Host "	"$text_msg.mainmenu09 -ForegroundColor White
	}

	do
		{
			Show-Menu
			SLEEP 1
			write-host ""
			Do
				{
					[int]$selection = $null
					[int]$selection = ($(Write-Host $text_msg.mainmenu10 -ForegroundColor green)) + ($(Write-Host $text_msg.mainmenu11 -ForegroundColor yellow -NoNewLine ; Read-Host))
				}until(($selection -lt 11  ) -and ($selection -gt 0))

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
#ENTER TO THE MAIN MENU
do
    {
    main_menu
    }while([int]$selection -ne 10 )
