$pobierak_v = "2.0"

$recources_main_dir =  Split-Path $PSCommandPath -Parent

$pobierakbat_main_dir =  $recources_main_dir -replace 'Resources',''

$yt_dlp = "$recources_main_dir\yt-dlp.exe"

$ffmpeg = "$recources_main_dir\ffmpeg\bin\ffmpeg.exe"

$exit_completly = 0

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

        Write-Host "pobierak present: $version_present_double"

        Write-Host "pobierak downloaded: $pobierak_downloaded_double"

        if ( $pobierak_downloaded_double -gt $version_present_double  )
            {

                write-host "JEST DOSTEPNA NOWA WERSJA pobieraka: $pobierak_downloaded_double "  -ForegroundColor green
                $whats_new = ( Get-Content $path_to_temp\pobierak\pobierak4windows-main\resources\whats_new.txt )
                Write-Host "NOWSZA WERSJA OBEJMUJE NASTEPUJACE ZMIANY: $whats_new " -ForegroundColor green
       
                do
                    {
                        Write-Host "CZY CHCESZ JA ZAINSTALOWAC ?: WCISNIJ 1 = TAK .. 2 = NIE " -ForegroundColor Yellow
                        [int]$instal_or_not = Read-Host "Enter number from 1-2"
                    }while(($instal_or_not -ne 1  ) -and ($instal_or_not -ne 2))

            }
        else
            {
                write-host "BRAK NOWEJ WERSJI POBIERAKA" -ForegroundColor red
                Remove-Item $path_to_temp -Force -Recurse
            }

        if ( $instal_or_not -eq 1 )
            {
                "NO TO INSTALJUEMY"
                Copy-Item  -Path $path_to_temp\pobierak\pobierak4windows-main\resources\pobierak.ps1 $recources_main_dir\pobierak.ps1
                "POBIERAK ZOSTAL UAKTUALNIONY!!"
                Remove-Item $path_to_temp -Force -Recurse
                "ZA MOMENT ZOSTANIE OTWARTA NOWA WERSJA A STARA WERSJE BEDZIE MOZNA ZAMKNAC"
                SLEEP 6
                Start-Process $pobierakbat_main_dir\pobierak.bat         
                
            }
        else
            {
                "OBECNA WERSJA TO: $version_present "
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

        Write-Host "SCIAGANIE KONWERTERA Z REPOZYTORIUM GITHUB.. TO MOZE TROCHE POTRWAC OK KILKU MINUT"

        curl -o $recources_main_dir\ffmpeg.zip https://github.com/GyanD/codexffmpeg/releases/download/2022-09-07-git-e4c1272711/ffmpeg-2022-09-07-git-e4c1272711-essentials_build.zip

        Get-ChildItem $recources_main_dir -Filter *.zip | Expand-Archive -DestinationPath $recources_main_dir\ffmpeg -Force

        Get-ChildItem $recources_main_dir -Filter *.zip | Remove-Item

        $recources_main_dir_unzipped = "$recources_main_dir\ffmpeg"

        $unzipped_dir = get-ChildItem -Path $recources_main_dir_unzipped -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 1 | Move-Item -Destination $recources_main_dir

        Remove-Item –path $recources_main_dir_unzipped

        $unzipped_dir = get-ChildItem -Path $recources_main_dir -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object -First 1 | Rename-Item -newname ffmpeg

    }

    Function download_yt_dlp(){

        #https://github.com/yt-dlp/yt-dlp
        curl -o $recources_main_dir\yt-dlp.exe https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
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
    Write-Host "2: POBIERZ BIBLIOTEKE FFMPEG DO KONWERTOWANIA SCIAGNIETYCH MULTIMEDIOW" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3: SCIAGNIJ YT-DLP." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "4: PRZEPROWADZ WSZYSTKIE OPERACJE NA RAZ." -ForegroundColor Magenta
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
    Write-Host ""
    Write-Host "1: SCIAGNIJ ILE CHCESZ POJEDYNCZYCH LINKOW." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "2: SCIAGNIJ PIOSENKI Z LINKOW ZNAJDUJACYCH SIE W PLIKU." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3: SCIAGNIJ CALA PLAYLISTE." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "4: SCIAGNIJ CALY KANAL." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "5: MENU AKTUALIZACJI" -ForegroundColor Red
    Write-Host ""
    Write-Host "EXIT: ABY WYJSC - 0" -ForegroundColor White
}

do
 {
    Show-Menu
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
                updates_menu
            }
    }
    pause
 }
 until ( $selection -eq 0 )
