$pobierak_v = "2.6"

$process_bak_primary_id = Get-CimInstance Win32_Process | where commandline -match 'pobierak_primary.ps1'  | Select ProcessId | ForEach-Object {$_ -replace '\D',''}
$process_bak_id = Get-CimInstance Win32_Process | where commandline -match 'pobierak_bak.ps1'  | Select ProcessId | ForEach-Object {$_ -replace '\D',''}

$recources_main_dir =  Split-Path $PSCommandPath -Parent

$pobierakbat_main_dir =  $recources_main_dir -replace 'Resources',''

$yt_dlp = "$recources_main_dir\yt-dlp.exe"

$ffmpeg = "$recources_main_dir\ffmpeg\bin\ffmpeg.exe"

Function internal_info(){

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
                    $resource_ffmpeg = ( $(write-host "! BIBLIOTEKA FFMPEG NIE JEST SCIAGNIETA !." -ForegroundColor Red ) + $( write-host "W CELU POPRAWNEGO DZIALANIA POBIERAKA UZYJ OPCJI NR 6 I Z MENU AKTUALIZACJI OPCJE NR 2 LUB 4" -ForegroundColor Red ) + $( write-host ""; ))
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
                    $resource_yt_dlp = ( $(write-host "! YOUTUBE-DLP NIE JEST SCIAGNIETY !." -ForegroundColor Red ) + $( write-host "W CELU POPRAWNEGO DZIALANIA POBIERAKA UZYJ OPCJI NR 6 I Z MENU AKTUALIZACJI OPCJE NR 3 LUB 4" -ForegroundColor Red ) + $( write-host ""; ) )
                    $recources_test += ," $warning_missing_resource"
                    $recources_test += ," $resource_yt_dlp"
                }



Return ,$recources_test

}

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Function warning_select_file(){
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');
    [System.Windows.Forms.MessageBox]::Show('WYBIERZ DOCELOWY PLIK Z WKLEJONYMI LINKAMI Z YOUTUBE','WARNING')
}

Function Select-Folder
{
    param([string]$Description="Select Folder",[string]$RootFolder="Desktop")

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null     

        $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
        $Description = "WYBIERZ FOLDER DOCELOWY DLA SCIAGNIETYCH SONGOW"
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
    do
        {
            SLEEP 1
            Write-Host ""
            [string]$s = $(Write-Host "PODAJ KOMPLETNY LINK Z YOUTUBE NP (https://www.youtube.com/watch?v=XmaaSK19jGQ)" -ForegroundColor green) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor green) + $(Write-Host "W CELU PRZEZWANIA WPISZ q i WSCISNIJ enter: " -ForegroundColor red; Read-Host)
            if ( $s -eq "q" )
                {
                }else{$s >> "$recources_main_dir\songs.txt"}          

        }until($s -eq "q"  )
SLEEP 1
    do
        {
            [string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
        }while(($quality -ne "128K"  ) -and ($quality -ne "360K"))

    $c = Get-Content -Path "$recources_main_dir\songs.txt" 

    #PATH TO YT-DLP
    $cmd = "$yt_dlp"

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder

    Start explorer.exe $output_directory
    
    
    ForEach ($a in $c) 
        {
            Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location $ffmpeg --format bestaudio --audio-format mp3 --extract-audio --audio-quality $quality --output ""$output_directory""\%(title)s.%(ext)s $a"
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

    SLEEP 1

    do
        {
            [string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
        }while(($quality -ne "128K"  ) -and ($quality -ne "360K"))

    #PATH TO YT-DLP
    $cmd = "$yt_dlp"

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder

    Start explorer.exe $output_directory
    
    
    ForEach ($h in $d) 
        {
            Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location $ffmpeg --format bestaudio --audio-format mp3 --extract-audio --audio-quality $quality --output ""$output_directory""\%(title)s.%(ext)s $h"
        }

        write-host ""
        Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
}
#3
Function download_playlist(){
    cls
    [string]$playlist_ID_yt = $(Write-Host "W CELU SCIAGNIECIA CALEY PLYLISTY NIEZBEDNY JEST JEJ IDENTYFIKATOR" -ForegroundColor yellow) + $(Write-Host "IDENTYFIKATOR PLAYLISTY ZOSTAL ZAZNACZONY NA ZIELONO W PRZYKLADOWYM LINKU PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/playlist?list=" -NoNewline -ForegroundColor yellow ) + $(Write-Host "PLEsNcyT1Z66QTRRPXdJZJdPoqdud4wNKP" -ForegroundColor green)  + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CZESC ID Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; Read-Host)
    $quality = $null

    SLEEP 1

    do
        {
            [string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
        }while(($quality -ne "128K"  ) -and ($quality -ne "360K"))

     #PATH TO YT-DLP
    $cmd = "$yt_dlp"

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder

    Start explorer.exe $output_directory

    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location $ffmpeg --format bestaudio --audio-format mp3 --extract-audio --audio-quality $quality --yes-playlist --output ""$output_directory""\%(title)s.%(ext)s $playlist_ID_yt "

    write-host ""
    Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline
}
#4
Function download_channel(){

    cls
    [string]$channel_ID_yt = $(Write-Host "W CELU SCIAGNIECIA CALEGO KANALU  NIEZBEDNY JEST LINK ZAWIERAJACY PODFOLDER --- channel --- W LINKU" -ForegroundColor yellow) + $(Write-Host "PRZYKLADOWY LINK ZNAJDUJE SIE PONIZEJ" -ForegroundColor yellow ) + $(Write-Host "https://www.youtube.com/" -NoNewline -ForegroundColor Magenta ) + $(Write-Host "channel" -NoNewline -ForegroundColor green) + $(Write-Host "/UC0C1W6nV0Rv6QkvAAE_AgXg" -ForegroundColor Magenta ) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC CALY LINK Z PODFOLDEREM --- channel --- Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor yellow; Read-Host)
    $quality = $null

    Write-Host ""

    SLEEP 1

     do
        {
            [string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
        }while(($quality -ne "128K"  ) -and ($quality -ne "360K"))

    $cmd = "$yt_dlp"

    #PATH TO OUTPUT DIR
    $output_directory = Select-Folder

    Start explorer.exe $output_directory

    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "-ciw --extract-audio --audio-format mp3 --ffmpeg-location $ffmpeg --audio-quality $quality --output ""$output_directory""\%(title)s.%(ext)s $channel_ID_yt "

}
#5
Function download_movie_and_or_music_from_list(){
cls
    do
        {
            SLEEP 1
            Write-Host ""
            [string]$s = $(Write-Host "PODAJ KOMPLETNY LINK Z YOUTUBE NP (https://www.youtube.com/watch?v=XmaaSK19jGQ)" -ForegroundColor green) + $(Write-Host "NAJPROSCIEJ SKOPIOWAC Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU. " -ForegroundColor green) + $(Write-Host "W CELU PRZEZWANIA WPISZ q i WSCISNIJ enter: " -ForegroundColor red; Read-Host)
            if ( $s -eq "q" )
                {
                }else{$s >> "$recources_main_dir\songs.txt"}          

        }until($s -eq "q"  )

    SLEEP 1
    do
        {
            Write-Host "CZY CHCESZ RAZEM Z VIDEO SCIAGNAC ROWNIEZ SCIEZKE AUDIO ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
            [int]$audio_yes_no = Read-Host "Enter number from 1-2"
        }while(($audio_yes_no -ne 1  ) -and ($audio_yes_no -ne 2))

    $c = Get-Content -Path "$recources_main_dir\songs.txt" 

    #PATH TO YT-DLP
    $cmd = "$yt_dlp"
    
    if ( $audio_yes_no -eq 1 )
        {
            do
                {
                    SLEEP 1
                    [string]$quality = $(Write-Host "PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANA PIOSENKA. " -ForegroundColor green -NoNewLine) + $(Write-Host "PRAWIDLOWE TO 128K LUB 360K: " -ForegroundColor yellow -NoNewLine ; Read-Host)
				}while(($quality -ne "128K"  ) -and ($quality -ne "360K"))

                    #PATH TO OUTPUT DIR
                    $output_directory = Select-Folder
                    Start explorer.exe $output_directory
                     
            ForEach ($a in $c) 
                {
                    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location $ffmpeg --format bestaudio --audio-format mp3 --extract-audio --audio-quality $quality --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
                    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location $ffmpeg  -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format mp4 --no-playlist  --output ""$output_directory""\%(title)s.%(ext)s $a"
                }


        }
    else
        {
        #PATH TO OUTPUT DIR
        $output_directory = Select-Folder
        Start explorer.exe $output_directory
        ForEach ($a in $c) 
                {
                    Start-Process -NoNewWindow -Wait -FilePath $yt_dlp -ArgumentList "--ignore-errors --ffmpeg-location $ffmpeg -f bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best --merge-output-format mp4 --no-playlist --output ""$output_directory""\%(title)s.%(ext)s $a"
                }

        }

    Remove-Item -Path "$recources_main_dir\songs.txt"

    write-host ""
    Write-Host "SCIAGANIE ZAKONCZONE SUKCESEM." -ForegroundColor Green -NoNewline

}
#6
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
                $whats_new = ( Get-Content $path_to_temp\pobierak\pobierak4windows-main\resources\whats_new.txt )
                Write-Host "NOWSZA WERSJA OBEJMUJE NASTEPUJACE ZMIANY: $whats_new " -ForegroundColor green
       
                do
                    {
                        Write-Host ""
                        SLEEP 1
                        Write-Host "CZY CHCESZ JA ZAINSTALOWAC ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
                        [int]$instal_or_not = Read-Host "Enter number from 1-2"
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
				If (!(test-path -PathType container $path_2_pob_pri))
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
                Write-Host ""
                SLEEP 1
                Write-Host "POBIERAK ZOSTAL UAKTUALNIONY!!"
                Remove-Item $path_to_temp -Force -Recurse
                Write-Host ""
                SLEEP 1
                Write-Host "ZA MOMENT ZOSTANIE OTWARTA NOWA WERSJA A STARA WERSJE BEDZIE MOZNA ZAMKNAC"
                Write-Host ""
                SLEEP 6
                Start-Process $pobierakbat_main_dir\pobierak.bat         
                
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
                    Write-Host "ffmpeg Folder Exists"
                    Remove-Item $test_ffmpef_if_exist -Force -Recurse
                }
            else
                {
                    Write-Host "ffmpeg Folder Doesn't Exists"
                }
        Write-Host ""
        SLEEP 1
        Write-Host "SCIAGANIE KONWERTERA Z REPOZYTORIUM GITHUB.. TO MOZE TROCHE POTRWAC OK KILKU MINUT. OTWORZ BROWAR I CIERPLIWOSCI ;)"

        curl -o $recources_main_dir\ffmpeg.zip https://github.com/GyanD/codexffmpeg/releases/download/2022-09-07-git-e4c1272711/ffmpeg-2022-09-07-git-e4c1272711-essentials_build.zip

        Get-ChildItem $recources_main_dir -Filter *.zip | Expand-Archive -DestinationPath $recources_main_dir\ffmpeg -Force

        Get-ChildItem $recources_main_dir -Filter *.zip | Remove-Item

        $recources_main_dir_unzipped = "$recources_main_dir\ffmpeg"
        Write-Host ""
        Write-Host "SCIAGANIE KONWERTERA ZAKONCZONE!!!" -ForegroundColor green

        $unzipped_dir = get-ChildItem -Path $recources_main_dir_unzipped -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 1 | Move-Item -Destination $recources_main_dir
        Write-Host ""
        SLEEP 1
        Write-Host "WYPAKOWYWANIE KONWERTERA" -ForegroundColor green
		
		Remove-Item $recources_main_dir_unzipped -Force -Recurse
        
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
                }until ( $selection -lt 5 )

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

                }
            pause
        }until ( $selection -eq 0 )

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
    Write-Host "3: SCIAGNIJ CALA PLAYLISTE." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "4: SCIAGNIJ CALY KANAL." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "5: SCIAGNIJ VIDEO I/LUB AUDIO" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "6: MENU AKTUALIZACJI" -ForegroundColor Red
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
        }until ( $selection -lt 7 )

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
                updates_menu
            }
    }
    pause
 }
 until ( $selection -eq 0 )
