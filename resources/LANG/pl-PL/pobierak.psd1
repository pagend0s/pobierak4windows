#internal_info
ConvertFrom-StringData @'
	internalinfo0 = AKTUALNA WERSJA YOUTUBE-DLP:
	warning = !!! UWAGA UWAGA UWAGA !!!
	criticalupdateerror1 = PO AKTUALIZACJI WYKRYTO BLAD KRYTYCZNY. SPROBUJ SKONTAKTOWAC SIE Z PAGEND0SEM
	criticalupdateerror2 = Kontaktowy adres e-mail: pobierak4win@proton.me lub zostaw komentarz na https://www.youtube.com/watch?v=IuWXUPNXOY0
	ffmpglib = ! BIBLIOTEKA FFMPEG NIE JEST SCIAGNIETA !
	ytdlpexe = ! YOUTUBE-DLP NIE JEST POBRANY !.
	updpath = W CELU POPRAWNEGO DZIALANIA POBIERAKA UZYJ OPCJI NR 8 I Z MENU AKTUALIZACJI OPCJE NR 2 I NR 3 LUB 4.
	optionwithoutexe0 = WYGLADA NA TO, ZE Pobierak WCIAZ POTRZEBUJE NIEZBEDNYCH PLIKOW *.exe, BY DZIALAC. 
	optionwithoutexe1 = ZOSTANIESZ PRZENIESIONY DO MENU AKTUALIZACJI, GDZIE NALEZY WYBRAC OPCJE NR 4
	optionwithoutexe2 = ABY POBRAC NIEZBEDNE PLIKI exe, WYBIERZ OPCJE NR 4.
	optionwithoutexe3 = yt-dlp.exe ORAZ ffmpeg.exe SA WYMAGANE DO PRAWIDLOWEGO FUKCJONOWANIA POBIERAKA
	
'@

#freespace
ConvertFrom-StringData @'
	freespace = WOLNE MIEJSCE W FOLDERZE DOCELOWYM TO:
'@

#downloadended
ConvertFrom-StringData @'
	downloadend = SCIAGANIE ZAKONCZONE.
'@

#warning_select_file
ConvertFrom-StringData @'
	selectfile = WYBIERZ DOCELOWY PLIK Z WKLEJONYMI LINKAMI Z YOUTUBE
'@

#Select-Folder
ConvertFrom-StringData @'
	selectdir = WSKAZ MIEJSCE DOCELOWE DLA SCIAGNIETYCH MULTIMEDIOW
'@

#filterlinks
ConvertFrom-StringData @'
	abchanneldiscovered0 = W LINKU POBIERAK ZNALAZL ODNIESIENIE DO CAŁEGO KANALU!
	abchanneldiscovered1 = ZOSTANIE ON SKORYGOWANY DO: 
	abandchanneldiscovered = JESLI CHODZI CI O SCIAGNIECIE CALEGO KANALU TO UZYJ OPCJI Z MENU NR: 4 LUB 6
	channeldiscovered0 = W LINKU ZNAJDUJE SIE PODFOLDER CHANNEL CO BEDZIE SKUTKOWALO SCIAGNIECIEM CALEGO KANALU!
	channeldiscovered1 = ZOSTANIE ON ZIGNOROWANY.
	channeldiscovered2 = JESLI MAM SCIAGNAC POJEDYNCZA SCIEZKE AUDIO TO WSKAZ LINK BEZ CZESCI (PODFOLDERU) = channel = .
	plylistdicovered0 = W LINKU WYKRYLEM ODNOSNIK DO CALEJ PLAYLISTY !
	plylistdicovered1 = ZOSTANIE ON SKORYGOWANY DO:
	plylistdicovered2 = JESLI CHODZI CI O SCIAGNIECIE CALEJ PLAYLISTY TO UZYJ OPCJI Z MENU NR: 3 LUB 6
	plylistdicovered01 = NIESTETY NIE MOGĘ POPRAWIĆ TEGO LINKU W TEJ FORMIE. ZOSTANIE ON ZIGNOROWANY
'@

#audioquality
ConvertFrom-StringData @'
	quality0 = PODAJ WARTOSC OZNACZAJACA JAKOSC W JAKIEJ MA BYC PRZEKONWERTOWANE AUDIO.
	quality1 = PRAWIDLOWE WARTOSCI TO 128K LUB 320K:
'@

#audio_0_1
ConvertFrom-StringData @'
	audio010 = CZY CHCESZ RAZEM Z VIDEO SCIAGNAC ROWNIEZ ODDZIELNIE SCIEZKE AUDIO W FORMACIE MP3 ?: PODAJ LICZBE 1 = TAK .. 2 = NIE
	audio011 = WPISZ LICZBE: 1 = TAK ; 2 = NIE :
'@

#video_0_1
ConvertFrom-StringData @'
	video010 = CHCESZ SCIAGNAC VIDEO ?
	video011 =  WPISZ LICZBE: 1 = TAK ; 2 = NIE :
'@

#downloaaudio
ConvertFrom-StringData @'
	downloadingaudio0 = ZACIAGANIE AUDIO LINK NR:
	downloadingaudio1 = POZOSTALO:
'@

#downloadvideo
ConvertFrom-StringData @'
	downloadingvideo0 = ZACIAGANIE VIDEO LINK NR:
	downloadingvideo1 = POZOSTALO:
'@

#viedoformat
ConvertFrom-StringData @'
	videoformat0 = W JAKIM FORMACIE MA BYC SCIAGNIETY VIDEO ?
	videoformat1 = PRAWIDLOWE TO: avi ; mp4: 
'@

#playlist_range
ConvertFrom-StringData @'
	playlist_range0 = CZY CHCESZ SCIAGNAC Z JAKIEGOS KONKRETNEGO ZAKRESU ?: 1 = TAK .. 2 = NIE
	playlist_range1 = PODAJ WARTOSC LICZBOWA "OD":
	playlist_range2 = PODAJ WARTOSC LICZBOWA DO: 
'@


#downloadsongonebyone
ConvertFrom-StringData @'
	downloadsongintro = WYBRALES OPCJE NUMER 1. POBIERANIE AUDIO Z YT ZA POMOCA POJEDYNCZYCH LINKOW SKOPIOWANYCH DO TERMINALA.
	downloadsonginfo0 = PODAJ KOMPLETNY LINK Z YOUTUBE NP (https://www.youtube.com/watch?v=XmaaSK19jGQ)
	downloadsonginfo1 = NAJPROSCIEJ SKOPIOWAC Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU.
	downloadsonginfo2 = W CELU PRZEZWANIA WPISZ q i WSCISNIJ enter:
'@

#downloadfromlist
ConvertFrom-StringData @'
	downloadfromlistintro = WYBRALES OPCJE NUMER 2. POBIERANIE AUDIO Z YT ZA POMOCA LINKOW ZNAJDUJACYCH SIE W PLIKU.
'@

#downloadplaylist
ConvertFrom-StringData @'
	downloadplaylistintro = WYBRALES OPCJE NUMER 3. POBIERANIE AUDIO Z PLAYLISTY.
	downloadplaylistinfo0 = W CELU SCIAGNIECIA CALEY PLYLISTY NIEZBEDNY JEST JEJ IDENTYFIKATOR.
	downloadplaylistinfo1 = IDENTYFIKATOR PLAYLISTY ZOSTAL ZAZNACZONY NA ZIELONO W PRZYKLADOWYM LINKU PONIZEJ:
	downloadplaylistinfo2 = NAJPROSCIEJ SKOPIOWAC CALY ADRES URL WRAZ Z ID Z PRZEGLADARKI I WCISNAC PRAWY KLAWISZ W TERMINALU:
'@

#downloadchannel
ConvertFrom-StringData @'
	downloadchannelintro = WYBRALES OPCJE NUMER 4. POBIERANIE AUDIO Z CALEGO KANALU YT.
	downloadchannelinfo0 = ABY POBRAC CALY KANAL, NIEZBEDNY JEST IDENTYFIKATOR KANALU..
	downloadchannelinfo1 = ZNAJDZIESZ GO W INFORMACJACH O KANALE: „Wiecej informacji o tym kanale” ORAZ Z MENU KONTEKSTOWEGO „Udostępnij kanal” ORAZ „Kopiuj identyfikator kanalu”
	downloadchannelinfo2 = PO PROSTU: SKOPIUJ ID KANALU Z PRZEGLĄDARKI I NACIŚNIJ PRAWY KLAWISZ W TERMINALU:
'@

#downloadmovieandormusicfromlist
ConvertFrom-StringData @'
	fun5intro = WYBRALES OPCJE NUMER 5. POBIERANIE VIDEO I/LUB AUDIO POPRZEZ LINKI WPISYWANE Z PLIKU LUB WPISYWANE W CONSOLE.
	fun5listorterminal0 = CHCESZ SCIAGNAC VIDEO/AUDO Z JUZ PRZYGOTWANEJ LISTY CZY WPISAC KILKA LINKOW W CONSOLE ?
	fun5listorterminal1 = PODAJ CYFRE: 1 = LISTA ; 2 = CONSOLA:
'@

#downloadmovieandormusicfromlistPLAYLISTANDCHANNEL
ConvertFrom-StringData @'
	fun6intro = WYBRALES OPCJE NUMER 6. POBIERANIE VIDEO I/LUB AUDIO Z KOMPLETNEJ PLAYLISTY LUB KANALU.
'@

#downloadfromcookie
ConvertFrom-StringData @'
	downloadfromcookieintro = WYBRALES OPCJE NUMER 7. MOZLIWOSC WYBORU: VIDEO TAK/NIE - I/LUB AUDIO Z PRYWATNEJ LISTY.
	downloadfromcookiewarn0 = PODAJ JAKA PRZEGLADARKE UZYWASZ, CHODZI O TA GDZIE AKTUALNIE ZNAJDUJE SIE PLAYLISTA Z ZALOGOWANEGO KONTA YOUTUBE.
	downloadfromcookiewarn1 = ! PRZY WYBORZE PRZEGLADARKI ZALECA SIE ROZWAGE. POBIERAK (YOUTUBE-DLP) BEDZIE MIAL DOSTEP DO CALEGO PROFILU !
	downloadfromcookiewarn2 = ! ZALECAM ZALOGOWANIE SIE DO YOUTUBE NA PRZEGLADARCE KTOREJ NIE UZYWA SIE NA CODZIEN I WSKAZANIE WLASNIE JEJ !
	downloadfromcookiewarn3 = OBSLUGIWANA PRZEGLADARKI TO: firefox.
	downloadfromcookiewarn4 = !!! WAZNE !!! Po wybraniu przegladarki, w przypadku Chrome i Edge, wszystkie otwarte wczesniej instancje Chrome lub Edge zostana zamkniete, aby ponownie otworzyć Chrome lub Edge w trybie odblokowanych plikow cookie.!!!
	downloadfromcookieinfo = WPISZ POPRAWNA WARTOSC: firefox LUB brave :
	downloadfromcookieaudio0 = NAJPIERW ZOSTANIE SCIAGNIETE AUDIO.
	downloadfromcookieaudio1 = SCIAGANIE AUDIO W TOKU..
	downloadfromcookieaudio2 = SCIAGANIE AUDIO ZAKONCZONE !
	downloadfromcookievideo0 = SCIAGANIE VIDEO W TOKU..
	downloadfromcookievideo1 = SCIAGANIE VIDEO ZAKONCZONE!
'@

#UPDATESMENUFUNCTIONS
ConvertFrom-StringData @'
	checkpobierakversion00 = JEST DOSTEPNA NOWA WERSJA pobieraka:
	checkpobierakversion10 = NOWSZA WERSJA OBEJMUJE NASTEPUJACE ZMIANY:
	news00 = 3.483  ; Dostosowanie wyboru folderow do win 11 ; Usunięto problem ze sprawdzania wersji ytdlp
	checkpobierakversion01 = CZY CHCESZ JA ZAINSTALOWAC ?: WCISNIJ 1 = TAK .. 2 = NIE
	checkpobierakversion02 = WPROWADZ NUMER: 1-2
	checkpobierakversion03 = BRAK NOWEJ WERSJI POBIERAKA
	checkpobierakversion04 = OBECNA WERSJA TO:
	checkpobierakversionupd01 = AKTUALIZACJA POBIERAKA W TOKU.
	checkpobierakversionupd02 = POBIERAK ZOSTAL UAKTUALNIONY!!
	checkpobierakversionupd03 = ZA MOMENT ZOSTANIE OTWARTA NOWA WERSJA A STARA WERSJA ZOSTANIE ZAMKNIETA.
	ffmpgupd00 = SCIAGANIE KONWERTERA Z REPOZYTORIUM GITHUB.. TO MOZE TROCHE POTRWAC OK KILKU MINUT. OTWORZ BROWAR I CIERPLIWOSCI ;)
	ffmpgupd01 = SCIAGANIE KONWERTERA ZAKONCZONE!!!
	ffmpgupd02 = WYPAKOWYWANIE KONWERTERA W TOKU..
	ffmpgupd03 = ROZPAKOWANIE ZAKONCZONE!
	ffmpgupd04 = KONWERTER JEST SCIAGNIETY, WYPAKOWANY I GOTOWY DO UZYTKU
	ytdlpupd00 = SCIAGANIE YT-DLP.exe
	ytdlpupd01 = SCIAGANIE YT-DLP ZAKONCZONE!!!
	allinone00 = WSZYSTKIE OPERACJE ZAKONCZONE.
	previousversion00 = CZY CHCESZ PRZYWROCIC POPRZEDNIA WERSJE ?: WCISNIJ 1 = TAK .. 2 = NIE .
	previousversion01 = PRZYWRACANIE POPRZEDNIEJ WERSJI.
	previousversion02 = POPRZEDNIA WERSJA ZOSTALA PRZYWROCONA.
	previousversion03 = WERSJA NIE ZOSTANIE PRZYWROCONA
	updmenu00 = AKTUALNA WERSJA Pobieraka:
	updmenu01 = 1: SPRAWDZ CZY JEST DOSTEPNA NOWSZA WERSJA SKRYPTU POBIERAKA.
	updmenu02 = 2: POBIERZ BIBLIOTEKE FFMPEG DO KONWERTOWANIA SCIAGNIETYCH MULTIMEDIOW
	updmenu03 = 3: SCIAGNIJ YT-DLP.
	updmenu04 = 4: PRZEPROWADZ WSZYSTKIE OPERACJE NA RAZ.
	updmenu05 = 5: PRZYWROC POPRZEDNIA WESJE POBIERAKA.
	updmenu06 = EXIT: ABY WYJSC - 6
	updmenu07 = DOKONAJ WYBORU WYBIERAJAC ODPOWIEDNI NUMER OPCJI.
	updmenu08 = ZATWIERDZ POPRZEZ ENTER:
	 
'@

#ytdlpdev
ConvertFrom-StringData @'
	ytdlpdevintro01 = WITAJ W POBIERAKU DLA AMBITNYCH ;)
	ytdlpdevintro02 = TUTAJ MOZESZ WPROWADZAC KOMENDY BEZPOSREDNIO DLA PROGRAMU YOUTUBE-DLP.
	ytdlpdevintro03 = KOMPLETNA LISTA KOMEND ZNAJDUJE SIE NA STRONIE PROJEKTU: https://github.com/yt-dlp/yt-dlp LUB PO WPISANIU ARGUMENTU --help
	ytdlpdev00 = PODAJ ZESTAW ARGUMENTOW I ZATWIERDZ POPRZEZ ENTER.
	ytdlpdev01 = ABY WYJSC Z TEJ SEKCJI WPISZ: quit
	ytdlpdev02 = POBIERAK DLA AMBITNYCH ZAKONCZONY.
'@
#mainmenu
ConvertFrom-StringData @'
	mainmenu00 = Pobierak wersja:
	mainmenu01 = 1: SCIAGNIJ ILE CHCESZ POJEDYNCZYCH LINKOW.
	mainmenu02 = 2: SCIAGNIJ PIOSENKI Z LINKOW ZNAJDUJACYCH SIE W PLIKU.
	mainmenu03 = 3: SCIAGNIJ AUDIO ZE WSKAZANEJ PLAYLISTY.
	mainmenu04 = 4: SCIAGNIJ AUDIO ZE WSKAZANEGO YT CHANNEL.
	mainmenu05 = 5: SCIAGNIJ VIDEO I/LUB AUDIO (POJEDYNCZE KAWALKI)
	mainmenu06 = 6: SCIAGNIJ VIDEO I/LUB AUDIO Z PLAYLISTY LUB CHANNEL
	mainmenu07 = 7: SCIAGNIJ Z PRYWATNEJ LISTY VIDEO I/LUB AUDIO
	mainmenu08 = 8: MENU AKTUALIZACJI
	mainmenu09 = EXIT: ABY WYJSC - 10
	mainmenu10 = DOKONAJ WYBORU WYBIERAJAC ODPOWIEDNI NUMER OPCJI.
	mainmenu11 = ZATWIERDZ POPRZEZ ENTER:

'@
