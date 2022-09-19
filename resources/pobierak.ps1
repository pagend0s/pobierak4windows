$pobierak_v = "2.901"

#VAR OF CURRENTLY LOGGED USER
$logged_usr = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).Split('\')[1]

#CLEAR MAIN VAR
$recources_main_dir = $null
$pobierakbat_main_dir = $null
$yt_dlp = $null
$ffmpeg = $null
$process_bak_primary_id = $null
$process_bak_id = $null

#GET POBIERAK PROCESS PID IF ACTIV
$process_bak_primary_id = Get-CimInstance Win32_Process | where commandline -match 'pobierak_primary.ps1'  | Select ProcessId | ForEach-Object {$_ -replace '\D',''}
$process_bak_id = Get-CimInstance Win32_Process | where commandline -match 'pobierak_bak.ps1'  | Select ProcessId | ForEach-Object {$_ -replace '\D',''}

#SET MAIN DIR 
$recources_main_dir =  Split-Path $PSCommandPath -Parent
#SET RECOURCES DIR
$pobierakbat_main_dir =  $recources_main_dir -replace 'Resources',''
#SET YT-DLP PALCE
$yt_dlp = "$recources_main_dir\yt-dlp.exe"
#SET ffmpeg PALCE
$ffmpeg = "$recources_main_dir\ffmpeg\bin\ffmpeg.exe"

#FUNCTION TO DISPLAY MAIN INFORMATION IN FIRST MENU
Function internal_info(){

if (Test-Path $yt_dlp) 
	{
		$yt_dlp_ver_1 = $(write-host "AKTUALNA WERSJA YOUTUBE-DLP: " -NoNewLine -ForegroundColor yellow ) + $( Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--version" )
	}

$recources_test= @()
$recources_test[0]

$test_resource_ffmpeg_if_exist = "$recources_main_dir\ffmpeg"
$test_resource_yt_dlp_if_exist = "$recources_main_dir\yt-dlp.exe"

if (( $process_bak_id -eq $null -and $process_bak_primary_id -eq $null ))
	{
		$critical_update_error = " "		
	}
else
	{
		$critical_update_error = ( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "NASTAPIL KRYTYCZNY PROBLEM Z AKTUALIZACJA. SKONTAKTUJ SIE Z PAGEND0SEM " ) -ForegroundColor RED )
		$recources_test += ," $critical_update_error"
	}

if (Test-Path $test_resource_ffmpeg_if_exist) 
                {
                    $resource_ffmpeg = " "
                    $recources_test += ," $resource_ffmpeg"
                    
                }
            else
                {
                    $warning_missing_resource = ( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "UWAGA UWAGA UWAGA " ) -ForegroundColor RED )
                    $resource_ffmpeg = ( $(write-host "! BIBLIOTEKA FFMPEG NIE JEST SCIAGNIETA !." -ForegroundColor Red ) + $( write-host "W CELU POPRAWNEGO DZIALANIA POBIERAKA UZYJ OPCJI NR 8 I Z MENU AKTUALIZACJI OPCJE NR 2 LUB 4" -ForegroundColor Red ) + $( write-host ""; ))
                    $recources_test += ," $warning_missing_resource"
                    $recources_test += ," $resource_ffmpeg"
                }

if (Test-Path $test_resource_yt_dlp_if_exist) 
                {
                    $resource_yt_dlp = " "
                    $recources_test += ," $resource_yt_dlp"
                    
                }
            else
                {
                    $warning_missing_resource = ( Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "UWAGA UWAGA UWAGA " ) -ForegroundColor RED )
                    $resource_yt_dlp = ( $(write-host "! YOUTUBE-DLP NIE JEST SCIAGNIETY !." -ForegroundColor Red ) + $( write-host "W CELU POPRAWNEGO DZIALANIA POBIERAKA UZYJ OPCJI NR 8 I Z MENU AKTUALIZACJI OPCJE NR 3 LUB 4" -ForegroundColor Red ) + $( write-host ""; ) )
                    $recources_test += ," $warning_missing_resource"
                    $recources_test += ," $resource_yt_dlp"
                }



Return ,$recources_test

}

Function warning_select_file(){
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null;
    [System.Windows.Forms.MessageBox]::Show('WYBIERZ DOCELOWY PLIK Z WKLEJONYMI LINKAMI Z YOUTUBE','WARNING')
}

function Get-FreeSpace {
    Param(
        $path = $output_directory
    );

    [double]$free = Get-WmiObject Win32_Volume -Filter "DriveType=3" |
            Where-Object { $path -like "$($_.Name)*" } |
            Sort-Object Name -Desc |
            Select-Object -First 1 FreeSpace |
            ForEach-Object { $_.FreeSpace / (1024*1024*1024) }
            
    return ([math]::round($free,2))
}

Function Select-Folder
{
    param([string]$Description="Select Folder",[string]$RootFolder="Desktop")

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null     

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
#1
function download_song(){
cls
	$path2song_list_single = "$recources_main_dir\songs.txt"
	If (Test-Path $path2song_list_single)
		{
			Remove-Item -Path $path2song_list_single
		}
	else
		{
			write-host " "
		}
		
    do
        {
            SLEEP 1
            Write-Host ""
            [string]$s = $(Write-Host "PODAJ KOMPLETNY LINK Z YOUTUBE NP (https://www.youtube.com/watch?v=XmaaSK19jGQ)" -ForegroundColor green) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor green) + $(Write-Host "W CELU PRZEZWANIA WPISZ q i WSCISNIJ enter: " -ForegroundColor red; Read-Host)
            if ( $s -eq "q" )
                {
                }
			else
			{
				$testlink = "$s"

				$yt_link_filter_plli = $testlink | Select-String -pattern "&list"

					if ($yt_link_filter_plli -eq $null )
						{
							$yt_link_filter_channel = $testlink | Select-String -pattern "channel"
								if ( $yt_link_filter_channel -ne $null )
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
									}
								else
									{
										$s >> "$recources_main_dir\songs.txt"
									}

						}
					else
						{
							$pattern = '(?<=\=).+?(?=\&)'
							$singel_link_after_filter = [regex]::Matches($yt_link_filter_plli, $pattern).Value | Select-Object -First 1
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
							$correct_single_link >> "$recources_main_dir\songs.txt"

						}						
			}         

        }until($s -eq "q"  )

    do
        {	
			Write-Host ""
			SLEEP 1
            [string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
        }while(($quality -ne "128K"  ) -and ($quality -ne "360K"))

    $c = Get-Content -Path "$recources_main_dir\songs.txt"
	
	$lines_var = Get-Content "$recources_main_dir\songs.txt" 
	$lines_var = $lines_var.trim() -ne ""
	[int]$lines_var = $lines_var.Count

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder
	$free_space = Get-FreeSpace
	sleep 1
	write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
	sleep 2

    Start explorer.exe $output_directory
	[int]$lines_var+=1
    [int]$xyz=0
    ForEach ($a in $c) 
        {
			[int]$xyz++
			[int]$lines_var-= 1
			write-host "ZACIAGANIE AUDIO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
            Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $a"
        }

    Remove-Item -Path "$recources_main_dir\songs.txt"

    write-host ""
    Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline

}
#2
Function download_from_list(){
    cls
    $quality = $null
    warning_select_file
    $selected_file_var = Select-File

    $d = Get-Content -Path $selected_file_var
	$d = $d.trim() -ne ""

    do
        {
			Write-Host ""
			SLEEP 1
            [string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
        }while(($quality -ne "128K"  ) -and ($quality -ne "360K"))

foreach ( $line in $d )
{
    $testlink = "$line"

				$yt_link_filter_plli = $testlink | Select-String -pattern "&list"

					if ($yt_link_filter_plli -eq $null )
						{
							$yt_link_filter_channel = $testlink | Select-String -pattern "channel"
								if ( $yt_link_filter_channel -ne $null )
									{
										write-host "-----------------------------------------------------------------------------------------------"
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
                                        write-host "-----------------------------------------------------------------------------------------------"
                                        $list_after_filtration = 1
									}
								else
									{
										$line >> "$recources_main_dir\songs_out.txt"
									}

						}
					else
						{
							$pattern = '(?<=\=).+?(?=\&)'
							$singel_link_after_filter = [regex]::Matches($yt_link_filter_plli, $pattern).Value | Select-Object -First 1
							$correct_single_link = "https://www.youtube.com/watch?v=$singel_link_after_filter"
							write-host "------------------------------------------------------------------------------"
							Start-Sleep -Milliseconds 500
							write-host "W LINKU WYKRYLEM ODNOSNIK DO CALEJ PLAYLISTY !" -ForegroundColor Red
							write-host ""
							Start-Sleep -Milliseconds 500
							$(write-host "ZOSTANIE ON SKORYGOWANY DO: " -ForegroundColor Green -nonewline ) + $( write-host "$correct_single_link" -ForegroundColor YELLOW ; )
							write-host ""
							Start-Sleep -Milliseconds 500
							write-host "JESLI CHODZI CI O SCIAGNIECIE CALEJ PLAYLISTY TO UZYJ OPCJI Z MENU NR: 3 LUB 6" -ForegroundColor Magenta
							write-host "------------------------------------------------------------------------------"
							$correct_single_link >> "$recources_main_dir\songs_out.txt"
                            $list_after_filtration = 1
						}						
			}         

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder	
	$free_space = Get-FreeSpace
	sleep 1
	write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
	sleep 2

    Start explorer.exe $output_directory
	
	$lines_var = Get-Content "$selected_file_var" 
	$lines_var = $lines_var.trim() -ne ""
	[int]$lines_var = $lines_var.Count
	
    #[int]$lines_var+=1
    $xyz=0
	
	if ( $list_after_filtration -eq 1 )
	{
		$selected_file_var = "$recources_main_dir\songs_out.txt"
		$d = Get-Content -Path $selected_file_var
		$d = $d.trim() -ne ""
		ForEach ($h in $d) 
			{
				[int]$lines_var-= 1
				$xyz++
				write-host " "
				write-host "ZACIAGANIE AUDIO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
				Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $h"
			}
		Remove-Item -Path "$recources_main_dir\songs_out.txt"
        write-host ""
        Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
		
	}
	else
		{
			ForEach ($h in $d) 
				{
					[int]$lines_var-= 1
					$xyz++
					write-host " "
					write-host "ZACIAGANIE AUDIO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $h"
				}

		write-host ""
        Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
		Remove-Item -Path "$recources_main_dir\songs.txt"
		}
		
}
#3
Function download_playlist(){
    cls
	Write-Host ""
	SLEEP 1
    [string]$playlist_ID_yt = $(Write-Host "W CELU SCIAGNIECIA CALEY PLYLISTY NIEZBEDNY JEST JEJ IDENTYFIKATOR" -ForegroundColor yellow) + $(Write-Host "IDENTYFIKATOR PLAYLISTY ZOSTAL ZAZNACZONY NA ZIELONO W PRZYKLADOWYM LINKU PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)  + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CZESC ID Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; Read-Host)
    $quality = $null

    do
        {	
			Write-Host ""
			SLEEP 1
            [string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
        }while(($quality -ne "128K"  ) -and ($quality -ne "360K"))

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder
	$free_space = Get-FreeSpace
	sleep 1
	write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
	sleep 2

    Start explorer.exe $output_directory

    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --yes-playlist --output ""$output_directory""\%(title)s.%(ext)s $playlist_ID_yt "

    write-host ""
    Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
}
#4
Function download_channel(){

    cls
	Write-Host ""
	SLEEP 1
    [string]$channel_ID_yt = $(Write-Host "W CELU SCIAGNIECIA CALEGO KANALU  NIEZBEDNY JEST LINK ZAWIERAJACY PODFOLDER --- channel --- W LINKU" -ForegroundColor yellow) + $(Write-Host "PRZYKLADOWY LINK ZNAJDUJE SIE PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "channel" -NoNewline -ForegroundColor green) + $(Write-Host "/UC0C1W6nV0Rv6QkvAAE_AgXg" -ForegroundColor Magenta ) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CALY LINK Z PODFOLDEREM --- channel --- Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; Read-Host)
    $quality = $null

     do
        {
			Write-Host ""
			SLEEP 1
            [string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
        }while(($quality -ne "128K"  ) -and ($quality -ne "360K"))

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder	
    Start explorer.exe $output_directory
	$free_space = Get-FreeSpace
	sleep 1
	write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
	sleep 2

    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "-ciw --extract-audio --audio-format mp3 --ffmpeg-location ""$ffmpeg"" --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $channel_ID_yt "

}

#5
Function download_movie_and_or_music_from_list(){
cls

	$path2song_list_single = "$recources_main_dir\songs.txt"
	If (Test-Path $path2song_list_single)
		{
			Remove-Item -Path $path2song_list_single
		}
	$path2song_list_select_file = "$recources_main_dir\songs_out.txt"
	If (Test-Path $path2song_list_select_file)
		{
			Remove-Item -Path $path2song_list_select_file
		}
		
	do
        {
			SLEEP 1
			write-host ""
            Write-Host "CHCESZ SCIAGNAC VIDEO/AUDO Z JUZ PRZYGOTWANEJ LISTY CZY WPISAC KILKA LINKOW W CONSOLE ? " -ForegroundColor Yellow
            [int]$list_console = Read-Host "PODAJ CYFRE: 1 = LISTA ; 2 = CONSOLA:"
        }while(($list_console -ne 1  ) -and ($list_console -ne 2))

	if ( $list_console -eq 1)
		{
			warning_select_file
			$selected_file_var = Select-File

			$d = Get-Content -Path $selected_file_var
			$d = $d.trim() -ne ""
			foreach ( $line in $d )
				{
					$testlink = "$line"

						$yt_link_filter_plli = $testlink | Select-String -pattern "&list"

							if ($yt_link_filter_plli -eq $null )
								{
									$yt_link_filter_channel = $testlink | Select-String -pattern "channel"
										if ( $yt_link_filter_channel -ne $null )
											{
												write-host "-----------------------------------------------------------------------------------------------"
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
												write-host "-----------------------------------------------------------------------------------------------"
												$list_after_filtration = 1
											}
										else
											{
												$line >> "$recources_main_dir\songs_out.txt"
											}

								}
							else
								{
									$pattern = '(?<=\=).+?(?=\&)'
									$singel_link_after_filter = [regex]::Matches($yt_link_filter_plli, $pattern).Value | Select-Object -First 1
									$correct_single_link = "https://www.youtube.com/watch?v=$singel_link_after_filter"
									write-host "------------------------------------------------------------------------------"
									Start-Sleep -Milliseconds 500
									write-host "W LINKU WYKRYLEM ODNOSNIK DO CALEJ PLAYLISTY !" -ForegroundColor Red
									write-host ""
									Start-Sleep -Milliseconds 500
									$(write-host "ZOSTANIE ON SKORYGOWANY DO: " -ForegroundColor Green -nonewline ) + $( write-host "$correct_single_link" -ForegroundColor YELLOW ; )
									write-host ""
									Start-Sleep -Milliseconds 500
									write-host "JESLI CHODZI CI O SCIAGNIECIE CALEJ PLAYLISTY TO UZYJ OPCJI Z MENU NR: 3 LUB 6" -ForegroundColor Magenta
									write-host "------------------------------------------------------------------------------"
									$correct_single_link >> "$recources_main_dir\songs_out.txt"
									$list_after_filtration = 1
								}						
				}		
		}
	else
		{
			do
				{
					SLEEP 1
					Write-Host ""
					[string]$s = $(Write-Host "PODAJ KOMPLETNY LINK Z YOUTUBE NP (https://www.youtube.com/watch?v=XmaaSK19jGQ)" -ForegroundColor green) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor green) + $(Write-Host "W CELU PRZEZWANIA WPISZ q i WSCISNIJ enter: " -ForegroundColor red; Read-Host)
					if ( $s -eq "q" )
						{
						}
					else
						{
							$testlink = "$s"

							$yt_link_filter_plli = $testlink | Select-String -pattern "&list"

							if ($yt_link_filter_plli -eq $null )
								{
									$yt_link_filter_channel = $testlink | Select-String -pattern "channel"
										if ( $yt_link_filter_channel -ne $null )
											{
												write-host "----------------------------------------------------------------------------------------------"
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
												write-host "----------------------------------------------------------------------------------------------"
											}
										else
											{
												$s >> "$recources_main_dir\songs.txt"
											}

								}
							else
								{
									$pattern = '(?<=\=).+?(?=\&)'
									$singel_link_after_filter = [regex]::Matches($yt_link_filter_plli, $pattern).Value | Select-Object -First 1
									$correct_single_link = "https://www.youtube.com/watch?v=$singel_link_after_filter"
									write-host "--------------------------------------------------------------------------------"
									Start-Sleep -Milliseconds 500
									write-host "W LINKU WYKRYLEM ODNOSNIK DO CALEJ PLAYLISTY !" -ForegroundColor Red
									write-host ""
									Start-Sleep -Milliseconds 500
									$(write-host "ZOSTANIE ON SKORYGOWANY DO: " -ForegroundColor Green -nonewline ) + $( write-host "$correct_single_link" -ForegroundColor YELLOW ; )
									write-host ""
									Start-Sleep -Milliseconds 500
									write-host "JESLI CHODZI CI O SCIAGNIECIE CALEJ PLAYLISTY TO UZYJ OPCJI Z MENU NR: 3 LUB 6" -ForegroundColor Magenta
									write-host "--------------------------------------------------------------------------------"
									$correct_single_link >> "$recources_main_dir\songs.txt"

								}						
						}         

				}until($s -eq "q"  )
		}
	$path2song_list_single = "$recources_main_dir\songs.txt"
	If (Test-Path $path2song_list_single)
		{
			if ( $list_after_filtration -eq 1 )
				{
					$c = Get-Content -Path "$recources_main_dir\songs_out.txt"
				}
			else
				{
					$c = Get-Content -Path "$recources_main_dir\songs.txt"
				}
		}
	else
		{
			write-host " "
		}
	
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
            Write-Host "CZY CHCESZ RAZEM Z VIDEO SCIAGNAC ROWNIEZ SCIEZKE AUDIO ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
            [int]$audio_yes_no = Read-Host "Enter number from 1-2"
        }while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))
    
    if ( $audio_yes_no -eq 1 )
        {
            do
                {
					write-host ""
                    SLEEP 1
					[string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE FORMATY TO: 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
				}while(($quality -ne "128K"  ) -and ($quality -ne "360K"))
		}
	else
		{
			write-host ""
		}
	

	#PATH TO OUTPUT DIR
	$output_directory = Select-Folder
	Start explorer.exe $output_directory
	$free_space = Get-FreeSpace
	sleep 1
	write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
	sleep 2
					
	
	if ( $list_console -eq 1)
	{
		$xyz=0
		if ( $list_after_filtration -eq 1 )
				{
					$d = Get-Content -Path "$recources_main_dir\songs_out.txt"
					$d = $d.trim() -ne ""
					$lines_var = Get-Content -Path "$recources_main_dir\songs_out.txt"
				}
			else
				{
					$lines_var = Get-Content "$selected_file_var"
				}
				
		$lines_var = $lines_var.trim() -ne ""
		[int]$lines_var = $lines_var.Count	
		[int]$lines_var+=1
		
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
					write-host "ZACIAGANIE VIDEO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
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
	if ( $list_console -eq 2)
	{
		if ( $list_after_filtration -eq 1 )
				{
					$lines_var = Get-Content "$recources_main_dir\songs_out.txt"
				}
			else
				{
					$lines_var = Get-Content "$path2song_list_single"
				}
	 
		$lines_var = $lines_var.trim() -ne ""
		[int]$lines_var = $lines_var.Count	
		[int]$lines_var+=1
		$xyz=0
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
					write-host "ZACIAGANIE VIDEO LINK NR: $xyz . POZOSTALO: $lines_var ." -ForegroundColor yellow
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
    
	
	If (Test-Path $path2song_list_single)
		{
			Remove-Item -Path $path2song_list_single
		}
	
	If (Test-Path $path2song_list_select_file)
		{
			Remove-Item -Path $path2song_list_select_file
		}
    write-host ""
    Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline

}

#6
Function download_movie_and_or_music_from_list_PLAYLIST_AND_CHANNEL(){
cls

	$path2song_list_single = "$recources_main_dir\songs.txt"
	If (Test-Path $path2song_list_single)
		{
			Remove-Item -Path $path2song_list_single
		}

	do
		{
			SLEEP 1
			Write-Host ""
			$(Write-Host "W CELU SCIAGNIECIA CALEY PLYLISTY NIEZBEDNY JEST JEJ IDENTYFIKATOR" -ForegroundColor yellow) + $(Write-Host "IDENTYFIKATOR PLAYLISTY ZOSTAL ZAZNACZONY NA ZIELONO W PRZYKLADOWYM LINKU PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)  + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CZESC ID Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; )
			write-host ""
			$(Write-Host "W CELU SCIAGNIECIA CALEGO KANALU  NIEZBEDNY JEST LINK ZAWIERAJACY PODFOLDER --- channel --- W LINKU" -ForegroundColor yellow) + $(Write-Host "PRZYKLADOWY LINK ZNAJDUJE SIE PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "channel" -NoNewline -ForegroundColor green) + $(Write-Host "/UC0C1W6nV0Rv6QkvAAE_AgXg" -ForegroundColor Magenta ) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CALY LINK Z PODFOLDEREM --- channel --- Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; )
			[string]$s = $(write-host "PODAJ LINK: " -nonewline ) + $(Read-Host ; )
			if ( $s -eq "q" )
				{
				}else{$s >> "$recources_main_dir\songs.txt"}          

			}until($s -eq "q"  )

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
            Write-Host "CZY CHCESZ RAZEM Z VIDEO SCIAGNAC ROWNIEZ SCIEZKE AUDIO ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
            [int]$audio_yes_no = Read-Host "Enter number from 1-2"
        }while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))
    
    if ( $audio_yes_no -eq 1 )
        {
            do
                {
					write-host ""
                    SLEEP 1
					[string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE FORMATY TO: 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
				}while(($quality -ne "128K"  ) -and ($quality -ne "360K"))
		}
	else
		{
			write-host ""
		}
		

	#PATH TO OUTPUT DIR
	$c = Get-Content -Path "$recources_main_dir\songs.txt"
	
	$output_directory = Select-Folder
	Start explorer.exe $output_directory
	$free_space = Get-FreeSpace
	sleep 1
	write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
	sleep 2
					
		if ( $audio_yes_no -eq 1 )
			{
				ForEach ($a in $c) 
                {
					write-host " "
					write-host "ZACIAGANIE AUDIO." -ForegroundColor yellow
                    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --format bestaudio --audio-format mp3 --extract-audio --audio-quality ""$quality"" --output ""$output_directory""\%(title)s.%(ext)s $a"
					write-host " "
					write-host "ZACIAGANIE VIDEO." -ForegroundColor yellow
					write-host " "
					Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --output ""$output_directory""\%(title)s.%(ext)s $a"
                }
			}
		if ( $audio_yes_no -eq 2 )
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
        
	Remove-Item -Path "$recources_main_dir\songs.txt"
	
    write-host ""
    Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
}

#7
function download_from_cookie(){
cls
	$path2song_list_single = "$recources_main_dir\songs.txt"
	If (Test-Path $path2song_list_single)
		{
			Remove-Item -Path $path2song_list_single
		}
	else
		{
			write-host " "
		}

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
	
	do
        {
			SLEEP 1
			write-host ""
            Write-Host "CHCESZ SCIAGNAC VIDEO/AUDO Z JUZ PRZYGOTWANEJ PLAYLISTY ZNAJDUJACEJ SIE W PLIKU CZY WPISAC KILKA PLAYLIST W CONSOLE ? " -ForegroundColor Yellow
			SLEEP 1
			Write-Host ""
            [int]$list_console = Read-Host "PODAJ CYFRE: 1 = GOTOWA LISTA (PLIK) ; 2 = CONSOLA: "
        }while(($list_console -ne 1  ) -and ($list_console -ne 2))
		
	if ( $list_console -eq 1)
		{
			warning_select_file
			$selected_file_var = Select-File

			$selected_file_var_list = Get-Content -Path $selected_file_var
		}
	else
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

	If (Test-Path $path2song_list_single)
		{
			$entered_playlist_console = Get-Content -Path "$recources_main_dir\songs.txt" 
		}
	else
		{
			write-host ""
		}
	
	do
		{
			SLEEP 1
			write-host ""
			[string]$viedo_format = $(Write-Host "W JAKIM FORMACIE MA BYC SCIAGNIETY VIDEO." -ForegroundColor green ) + $(Write-Host " PRAWIDLOWE TO: avi ; mp4 " -ForegroundColor yellow ; Read-Host)
		}while(($viedo_format -ne "avi") -and ($viedo_format -ne "mp4"))
		
	do
        {
			SLEEP 1
			write-host ""
            Write-Host "CZY CHCESZ RAZEM Z VIDEO SCIAGNAC ROWNIEZ SCIEZKE AUDIO ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
            [int]$audio_yes_no = Read-Host "Enter number from 1-2"
        }while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))
    
    if ( $audio_yes_no -eq 1 )
        {
            do
                {
                    SLEEP 1
					write-host ""
					$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE FORMATY TO: 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
				}while(($quality -ne "128K"  ) -and ($quality -ne "360K"))
		}
	else
		{
			write-host ""
		}

	#PATH TO OUTPUT DIR
	$output_directory = Select-Folder
	Start explorer.exe $output_directory
	
	$free_space = Get-FreeSpace
	sleep 1
	write-host = "WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO: $free_space GB." -ForegroundColor Yellow
	sleep 2
					
	if ( $list_console -eq 1)
	{
		if ( $audio_yes_no -eq 1 )
			{
				ForEach ($x in $selected_file_var_list) 
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
				ForEach ($x in $selected_file_var_list)
                {
					write-host " "
					write-host "SCIAGANIE VIDEO W TOKU.." -ForegroundColor yellow
					write-host " "
                    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format""  --output ""$output_directory""\%(title)s.%(ext)s $a --cookies-from-browser ""$web_browser"":""$latest_profile"" $x"
					write-host " "
					write-host "SCIAGANIE VIDEO ZAKONCZONE! " -ForegroundColor yellow
                }
			}
	}
	
	if ( $list_console -eq 2)
	{
		if ( $audio_yes_no -eq 1 )
			{
				ForEach ($y in $entered_playlist_console) 
                {
					write-host " "
					write-host "NAJPIERW ZOSTANIE SCIAGNIETE AUDIO " -ForegroundColor yellow
					write-host "SCIAGANIE AUDIO W TOKU.." -ForegroundColor yellow
					write-host " "
                    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" --extract-audio --audio-format mp3 --output ""$output_directory""\%(title)s.%(ext)s --audio-quality ""$qualit"" --cookies-from-browser ""$web_browser"":""$latest_profile"" $y"
					write-host " "
					write-host "SCIAGANIE AUDIO ZAKONCZONE! " -ForegroundColor yellow
					write-host "SCIAGANIE VIDEO W TOKU.." -ForegroundColor yellow
					write-host " "
                    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg""  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format""  --output ""$output_directory""\%(title)s.%(ext)s --cookies-from-browser ""$web_browser"":""$latest_profile"" $y"
					write-host " "
					write-host "SCIAGANIE VIDEO ZAKONCZONE! " -ForegroundColor yellow
				}
			}
		if ( $audio_yes_no -eq 2 )
			{
				ForEach ($y in $entered_playlist_console) 
                {
					write-host "SCIAGANIE VIDEO W TOKU.." -ForegroundColor yellow
					write-host " "
                    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location ""$ffmpeg"" -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format ""$viedo_format"" --output ""$output_directory""\%(title)s.%(ext)s --cookies-from-browser ""$web_browser"":""$latest_profile"" $y"
					write-host " "
					write-host "SCIAGANIE VIDEO ZAKONCZONE! " -ForegroundColor yellow
					sleep 1
                }
			}
	Remove-Item -Path "$recources_main_dir\songs.txt"
	}
    

    write-host ""
    Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline

}
#7
Function updates_menu(){

    Function check_pobierak_version(){

        cls
        $path_to_temp = "$recources_main_dir\temp"

        If(!(test-path -PathType container $path_to_temp))
            {
                New-Item -ItemType Directory -Path $path_to_temp
            }
        else
            {
                Remove-Item $path_to_temp -Force -Recurse
                New-Item -ItemType Directory -Path $path_to_temp
            }

        curl -o $path_to_temp\pobierak.zip https://github.com/pagend0s/pobierak4windows/archive/refs/heads/main.zip
        Get-ChildItem $path_to_temp\pobierak.zip -Filter *.zip | Expand-Archive -DestinationPath $path_to_temp\pobierak\ -Force

        $pobierak_v_present = Get-ChildItem $recources_main_dir\pobierak.ps1 | Select-String "pobierak_v" | Select-Object -First 1 

        $version_v_downloaded = Get-ChildItem $path_to_temp\pobierak\pobierak4windows-main\resources\pobierak.ps1 | Select-String "pobierak_v" | Select-Object -First 1 

        $version_present = $pobierak_v_present.Line.Split('=')[1] -replace '"','' -replace ' ',''
        [double]$version_present_double = [string]$version_present


        $pobierak_downloaded = $version_v_downloaded.Line.Split('=')[1] -replace '"','' -replace ' ',''
        [double]$pobierak_downloaded_double = [string]$pobierak_downloaded

        if ( $pobierak_downloaded_double -gt $version_present_double  )
            {
                Write-Host ""
                SLEEP 1
                write-host "JEST DOSTEPNA NOWA WERSJA pobieraka: $pobierak_downloaded_double "  -ForegroundColor green
                Write-Host ""
                SLEEP 1
                $whats_new = (( Get-Content $path_to_temp\pobierak\pobierak4windows-main\resources\whats_new.txt  | Out-String) -replace "`n", "`r`n" )
                $whats_new = $(Write-Host "NOWSZA WERSJA OBEJMUJE NASTEPUJACE ZMIANY: " -ForegroundColor green) + $( Write-Host "$whats_new" -ForegroundColor magenta )
       		$whats_new
                do
                    {
                        Write-Host ""
                        SLEEP 1
                        Write-Host "CZY CHCESZ JA ZAINSTALOWAC ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
                        [int]$instal_or_not = Read-Host "WPROWADZ NUMER: 1-2"
                    }while(($instal_or_not -ne 1  ) -and ($instal_or_not -ne 2))

            }
        else
            {
                Write-Host ""
                SLEEP 1
                write-host "BRAK NOWEJ WERSJI POBIERAKA" -ForegroundColor red
                Remove-Item $path_to_temp -Force -Recurse
            }

        if ( $instal_or_not -eq 1 )
            {
                Write-Host ""
                SLEEP 1
                Write-Host "NO TO INSTALJUEMY"

                if ( $process_bak_id -eq $null )
                    {
                        echo ""
                    }
                else
                    {
                        Copy-Item  -Path $recources_main_dir\pobierak_bak.ps1 $recources_main_dir\pobierak_primary.ps1
                    }
					
				$path_2_pob_pri = "$recources_main_dir\pobierak_primary.ps1"
				If (Test-Path $path_2_pob_pri)
					{
						if (( $process_bak_id -eq $null -and $process_bak_primary_id -eq $null ))
							{
								Remove-Item $recources_main_dir\pobierak_primary.ps1 -Force 
							}
					}
				else
					{
						write-host " "
					}
                
                Copy-Item  -Path $recources_main_dir\pobierak.ps1 $recources_main_dir\pobierak_bak.ps1
                Copy-Item  -Path $path_to_temp\pobierak\pobierak4windows-main\resources\pobierak.ps1 $recources_main_dir\pobierak.ps1
                Copy-Item  -Path $path_to_temp\pobierak\pobierak4windows-main\pobierak.bat $pobierakbat_main_dir\pobierak.bat
				Copy-Item  -Path $path_to_temp\pobierak\pobierak4windows-main\resources\whats_new.txt $pobierakbat_main_dir\whats_new.txt 
                Write-Host ""
                SLEEP 1
                Write-Host "POBIERAK ZOSTAL UAKTUALNIONY!!"
                Remove-Item $path_to_temp -Force -Recurse
				
				if ( $selection -eq 4 )
					{
						write-host " "
					}
				else
					{
						Write-Host ""
						SLEEP 1
						Write-Host "ZA MOMENT ZOSTANIE OTWARTA NOWA WERSJA A STARA WERSJE BEDZIE MOZNA ZAMKNAC"
						Write-Host ""
						SLEEP 5
						Start-Process $pobierakbat_main_dir\pobierak.bat
					}
                
            }
        else
            {
                Write-Host ""
                SLEEP 1
                Write-Host "OBECNA WERSJA TO: $version_present "
            }

    }

    Function download_ffmpeg(){
        #https://github.com/GyanD/codexffmpeg/releases

        $test_ffmpef_if_exist = "$recources_main_dir\ffmpeg"
            if (Test-Path $test_ffmpef_if_exist) 
                {
                    Remove-Item $test_ffmpef_if_exist -Force -Recurse
                }
            else
                {
                    Write-Host " "
                }
        Write-Host ""
        SLEEP 1
        Write-Host "SCIAGANIE KONWERTERA Z REPOZYTORIUM GITHUB.. TO MOZE TROCHE POTRWAC OK KILKU MINUT. OTWORZ BROWAR I CIERPLIWOSCI ;)"

        curl -o $recources_main_dir\ffmpeg.zip https://github.com/GyanD/codexffmpeg/releases/download/2022-09-07-git-e4c1272711/ffmpeg-2022-09-07-git-e4c1272711-essentials_build.zip

		SLEEP 1
        Write-Host ""
        Write-Host "SCIAGANIE KONWERTERA ZAKONCZONE!!!" -ForegroundColor green
		Write-Host ""
        SLEEP 1
		Write-Host "WYPAKOWYWANIE KONWERTERA W TOKU" -ForegroundColor green
	
        Get-ChildItem $recources_main_dir -Filter *.zip | Expand-Archive -DestinationPath $recources_main_dir\ffmpeg -Force

        Get-ChildItem $recources_main_dir -Filter *.zip | Remove-Item

        $recources_main_dir_unzipped = "$recources_main_dir\ffmpeg"
	

        $unzipped_dir = get-ChildItem -Path $recources_main_dir_unzipped -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 1 | Move-Item -Destination $recources_main_dir
        
        Remove-Item $recources_main_dir_unzipped -Force -Recurse
        Write-Host ""
        Write-Host "WYPAKOWYWANIE ZAKONCZONE !" -ForegroundColor green
		
        $unzipped_dir = get-ChildItem -Path $recources_main_dir -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 1 | Rename-Item -newname ffmpeg
        Write-Host ""
        SLEEP 1

        Write-Host "KONWERTER JEST SCIAGNIETY, WYPAKOWANY I GOTOWY DO UZYTKU" -ForegroundColor green

    }

    Function download_yt_dlp(){

        #https://github.com/yt-dlp/yt-dlp
        Write-Host ""
        SLEEP 1
        Write-Host "SCIAGANIE YT-DLP.exe" -ForegroundColor green
        curl -o $recources_main_dir\yt-dlp.exe https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
        Write-Host "SCIAGANIE YT-DLP ZAKONCZONE!!!" -ForegroundColor green
    }

    Function download_all_at_once(){

        check_pobierak_version

        download_ffmpeg

        download_yt_dlp
		
		if ( $selection -eq 4 )
			{
				
				Write-Host ""
				SLEEP 1
				Write-Host "ZA MOMENT ZOSTANIE OTWARTA NOWA WERSJA A STARA WERSJE BEDZIE MOZNA ZAMKNAC"
				Write-Host ""
				SLEEP 5
				Start-Process $pobierakbat_main_dir\pobierak.bat				
			}
		else
			{
				write-host " "		
			}

    }
Function previous_version(){
	
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
		}
	if ( $previous_version -eq 2 )
		{
			write-host "WERSJA NIE ZOSTANIE PRZYWROCONA" -ForegroundColor red
		}
}

    function Show_updates_Menu(){
        param (
                [string]$Title = 'Pobierak'
        )

    Clear-Host
    Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "Aktualizacja Pobieraka: " ) -ForegroundColor Green -NoNewline; Write-Host "$pobierak_v" -ForegroundColor yellow
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
    Write-Host "EXIT: ABY WYJSC - 0" -ForegroundColor White
    }

    do
        {
            Show_updates_Menu
            SLEEP 1
            write-host ""
            Do
                {
                    [int]$selection = $(Write-Host "DOKONAJ WYBORU WYBIERAJAC ODPOWIEDNI NUMER OPCJI. " -ForegroundColor green -NoNewLine) + $(Write-Host "ZATWIERDZ POPRZEZ ENTER: " -ForegroundColor Yellow -NoNewLine; Read-Host)
                }until ( $selection -lt 6 )

            switch ($selection)
                {
                    '1' 
                        {
                            check_pobierak_version
                        } 
    
                    '2' 
                        {
                            download_ffmpeg
                        } 

                    '3' 
                        {
                            download_yt_dlp
                        }
                    '4' 
                        {
                            download_all_at_once
                        }
					'5' 
                        {
                            previous_version
                        }

                }
            pause
        }until ( $selection -eq 0 )

}

function youtube_dlp_dev(){
cls
	Write-Host "WITAJ W POBIERAKU DLA AMBITNYCH ;)" -ForegroundColor green
	Write-Host "TUTAJ MOZESZ WPROWADZAC KOMENDY BEZPOSREDNIO DLA PROGRAMU YOUTUBE-DLP." -ForegroundColor green
	Write-Host "KOMPLETNA LISTA KOMEND ZNAJDUJE SIE NA STRONIE PROJEKTU: https://github.com/yt-dlp/yt-dlp LUB PO WPISANIU ARGUMENTU --help " -ForegroundColor green

	do
		{
			write-host ""
			SLEEP 1
			$arguments = $(Write-Host "PODAJ ZESTAW ARGUMENTOW I ZATWIERDZ POPRZEZ ENTER." -ForegroundColor green -NoNewLine) + $(Write-Host "ABY PRZERWAC WPISZ: quit" -ForegroundColor RED ; Read-Host)
			Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList """$arguments"""
				}until($arguments -eq "quit")
	Write-Host "POBIERAK DLA AMBITNYCH ZAKONCZONY." -ForegroundColor green
}

function Show-Menu(){
    param (
            [string]$Title = 'Pobierak'
    )
	
    Clear-Host
    Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Null.Length / 2)))), "Pobierak wersja: " ) -ForegroundColor Green -NoNewline; Write-Host "$pobierak_v" -ForegroundColor yellow
    internal_info
    Write-Host ""
    Write-Host "1: SCIAGNIJ ILE CHCESZ POJEDYNCZYCH LINKOW." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "2: SCIAGNIJ PIOSENKI Z LINKOW ZNAJDUJACYCH SIE W PLIKU." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3: SCIAGNIJ AUDIO ZE WSKAZANEJ PLAYLISTY." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "4: SCIAGNIJ AUDIO ZE WSKAZANEGO YT CHANNEL." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "5: SCIAGNIJ VIDEO I/LUB AUDIO (POJEDYNCZE KAWALKI)" -ForegroundColor Magenta
    Write-Host ""
	Write-Host "6: SCIAGNIJ VIDEO I/LUB AUDIO Z PLAYLISTY LUB CHANNEL " -ForegroundColor Yellow
    Write-Host ""
	Write-Host "7: SCIAGNIJ Z PRYWATNEJ LISTY VIDEO I/LUB AUDIO" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "8: MENU AKTUALIZACJI" -ForegroundColor Red
    Write-Host ""
    Write-Host "EXIT: ABY WYJSC - 0" #-ForegroundColor White
}

do
 {
    Show-Menu
    SLEEP 1
    write-host ""
    Do
        {
            [int]$selection = $(Write-Host "DOKONAJ WYBORU WYBIERAJAC ODPOWIEDNI NUMER OPCJI. " -ForegroundColor green -NoNewLine) + $(Write-Host "ZATWIERDZ POPRZEZ ENTER: " -ForegroundColor Yellow -NoNewLine; Read-Host)
        }until ( $selection -lt 10 )

    switch ($selection)
    {
        '1' 
            {
                download_song
            } 
    
        '2' 
            {
                download_from_list
            } 

        '3' {
                download_playlist
            }
        '4' {
                download_channel
            }
        '5' {
                download_movie_and_or_music_from_list
            }
		'6' {
                download_movie_and_or_music_from_list_PLAYLIST_AND_CHANNEL
            }
        '7' {
                download_from_cookie
            }
		'8' {
                updates_menu
            }
		'9' {
                youtube_dlp_dev
            }
						
    }
    pause
 }
 until ( $selection -eq 0 )
