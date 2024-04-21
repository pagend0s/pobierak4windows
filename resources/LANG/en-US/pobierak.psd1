#internal_info
ConvertFrom-StringData @'
    internalinfo0 = CURRENT VERSION OF YOUTUBE-DLP:
	warning = !!! WARNING WARNING WARNING !!!
	criticalupdateerror1 = THERE HAS BEEN A CRITICAL ERROR DETECTED AFTER THE UPDATE. TRY TO CONTACT WITH PAGEND0S
	criticalupdateerror2 = Contact e-mail address: pobierak4win@proton.me or leave comment at https://www.youtube.com/watch?v=IuWXUPNXOY0
	ffmpglib = ! THE FFMPEG LIBRARY IS NOT DOWNLOADED !.
	ytdlpexe = ! YOUTUBE-DLP IS NOT DOWNLOADED !.
	updpath = FOR THE CORRECT FUNCTIONING OF POBIERAK, USE OPTION NO.8 AND FROM THE UPDATE MENU OPTIONS NO.2 OR NO.4
'@

#freespace
ConvertFrom-StringData @'
	freespace = FREE SPACE IN TARGET DIRECTORY:
'@

#downloadended
ConvertFrom-StringData @'
	downloadend = THE DOWNLOAD PROCESS IS DONE.
'@

#warning_select_file
ConvertFrom-StringData @'
	selectfile = CHOOSE YOUR TARGET FILE WITH LINKS FROM YOUTUBE
'@

#Select-Folder
ConvertFrom-StringData @'
	selectdir = SET THE DESTINATION FOR DOWNLOADED MULTIMEDIA FILES
'@

#filterlinks
ConvertFrom-StringData @'
	abchanneldiscovered0 = IN THE LINK, POBIERAK DISCOVERED THE REFERENCE TO THE ENTIRE CHANNEL!
	abchanneldiscovered1 = IT WILL BE CORRECTED TO:
	abandchanneldiscovered = IF YOU WANT TO DOWNLOAD THE ENTIRE CHANNEL, USE THE OPTIONS FROM THE MENU NO: 4 OR 6
	channeldiscovered0 = THERE IS A CHANNEL SUBFOLDER IN THE LINK, WHICH WILL DOWNLOAD THE ENTIRE CHANNEL!
	channeldiscovered1 = THIS LINK WILL BE IGNORED BECAUSE IT CANNOT BE CORRECTED
	channeldiscovered2 = IF POBIERAK SHOULD DOWNLOAD A SINGLE AUDIO, PASTE LINK WITHOUT A PART (SUBFOLDER) = channel =.
	plylistdicovered0 = IN THE LINK, POBIERAK DISCOVERED THE REFERENCE TO THE ENTIRE PLAYLIST!
	plylistdicovered1 = IT WILL BE CORRECTED TO:
	plylistdicovered2 = IF YOU WANT TO DOWNLOAD THE ENTIRE PLAYLIST, USE THE OPTIONS FROM THE MENU NO: 3 OR 6
	plylistdicovered01 = UNFORTUNATELY I CANNOT CORRECT THIS LINK IN THIS FORM. IT WILL BE IGNORED
'@

#audioquality
ConvertFrom-StringData @'
	quality0 = ENTER THE VALUE FOR THE QUALITY IN WHICH THE AUDIO WILL BE CONVERTED.
	quality1 = CORRECT VALUES ARE: 128K OR 320K:
'@

#viedoformat
ConvertFrom-StringData @'
	videoformat0 = IN WHAT FORMAT THE VIDEO SHOULD BE DOWNLOADED ?
	videoformat1 = SUPPORTED ARE: avi ; mp4: 
'@

#audio_0_1
ConvertFrom-StringData @'
	audio010 = DO YOU WANT TO DOWNLOAD THE AUDIO TRACK SEPARATED AS MP3 ALSO WITH VIDEO ?: PRESS 1 = YES .. 2 = NO
	audio011 = ENTER THE NUMBER: 1 or 2 :
'@

#video_0_1
ConvertFrom-StringData @'
	video010 = YOU WANT TO DOWNLOAD VIDEO ?
	video011 = ENTER A NUMBER: 1 = YES ; 2 = NO :
'@


#downloaaudio
ConvertFrom-StringData @'
	downloadingaudio0 = PULLING AN AUDIO LINK NR:
	downloadingaudio1 = REMAIN:
'@

#downloadvideo
ConvertFrom-StringData @'
	downloadingvideo0 = PULLING AN VIDEO LINK NR:
	downloadingvideo1 = REMAIN:
'@

#downloadsongonebyone
ConvertFrom-StringData @'
	downloadsongintro = YOU HAVE CHOOSEN OPTION NUMBER 1. DOWNLOADING AUDIO FROM YT USING SINGLE LINKS COPIED INTO THE TERMINAL.
	downloadsonginfo0 = ENTER THE COMPLETE LINK FROM YOUTUBE E.G. (https://www.youtube.com/watch?v=XmaaSK19jGQ)
	downloadsonginfo1 = SIMPLY: COPY FROM THE BROWSER AND PRESS THE RIGHT KEY ON THE TERMINAL.
	downloadsonginfo2 = TO INTERRUPT, TYPE q AND PRESS enter:
'@

#downloadplaylist
ConvertFrom-StringData @'
	downloadplaylistintro = YOU HAVE CHOOSEN OPTIONS NUMBER 3. DOWNLOADING AUDIO FROM YT PLAYLIST.
	downloadplaylistinfo0 = IN ORDER TO DOWNLOAD THE ENTIRE PLAYLIST, ITS IDENTIFIER IS NECESSARY.
	downloadplaylistinfo1 = THE PLAYLIST ID WAS MARKED IN GREEN IN THE EXAMPLE LINK BELOW:
	downloadplaylistinfo2 = SIMPLY: COPY WHOLE URL WITH ID FROM THE BROWSER AND PRESS THE RIGHT KEY IN THE TERMINAL:
'@

#downloadchannel
ConvertFrom-StringData @'
	downloadchannelintro = YOU HAVE CHOOSEN OPTIONS NUMBER 4. DOWNLOADING AUDIO FROM WHOLE YT CHANNEL
	downloadchannelinfo0 = IN ORDER TO DOWNLOAD AN ENTIRE CHANNEL, A CHANNEL ID IS NECESSARY.
	downloadchannelinfo1 = YOU CAN FIND IT IN CHANNEL INFORMATION: "More about this channel" AND FROM THE CONTEXT MENU "Share this channel" AND "Copy Channel ID"
	downloadchannelinfo2 = SIMPLY: COPY CHANNEL ID FROM THE BROWSER AND PRESS THE RIGHT KEY IN THE TERMINAL:
'@

#downloadmovieandormusicfromlistorterminal
ConvertFrom-StringData @'
	fun5intro = YOU HAVE CHOOSED THE OPTION NUMBER 5. DOWNLOADING VIDEO AND/OR AUDIO VIA LINKS SAVED IN A FILE OR ENTERED IN TERMINAL.
	fun5listorterminal0 = YOU WANT TO DOWNLOAD VIDEO / AUDIO FROM AN ALREADY PREPARED LIST OR TO ENTER A FEW LINKS IN THE TERMINAL ?
	fun5listorterminal1 = ENTER NUMBER: 1 = YT LINKS FROM FILE ; 2 = TERMINAL:
'@

#downloadmovieandormusicfromlistPLAYLISTANDCHANNEL
ConvertFrom-StringData @'
	fun6intro = YOU CHOOSE THE OPTIONS NUMBER 6. DOWNLOADING VIDEO AND / OR AUDIO FROM A COMPLETE PLAYLIST OR CHANNEL.
'@

#downloadfromcookie
ConvertFrom-StringData @'
	downloadfromcookieintro = YOU CHOOSE THE OPTIONS NUMBER 7. AVAILABLE CHOICES: VIDEO YES / NO - AND / OR AUDIO FROM PRIVATE LIST
	downloadfromcookiewarn0 = ENTER WHAT BROWSER YOU ARE USING, IT IS WHERE THE PLAYLIST FROM THE LOGGED IN YOUTUBE ACCOUNT IS CURRENTLY.
	downloadfromcookiewarn1 = ! BE CAREFUL WHEN CHOOSING YOUR BROWSER. POBIERAK (YOUTUBE-DLP) WILL HAVE ACCESS TO THE ENTIRE PROFILE !
	downloadfromcookiewarn2 = ! I RECOMMEND LOG IN TO YOUTUBE ON A BROWSER WHICH YOU DO NOT USE ON EVERYDAY !
	downloadfromcookiewarn3 = SUPPORTED BROWSERS: chrome ; edge ; firefox.
	downloadfromcookiewarn4 = !!! IMPORTANT !!! After selecting the browser, in the case of Chrome and Edge, all previously open Chrome or Edge instances will be closed in order to reopen Chrome or Edge in the unlocked cookie mode.
	downloadfromcookieinfo = ENTER THE CORRECT VALUE: chrome OR edge OR firefox :
	downloadfromcookieaudio0 = AUDIO WILL BE DOWNLOADED FIRST.
	downloadfromcookieaudio1 = DOWNLOADING AUDIO IN PROGRESS..
	downloadfromcookieaudio2 = AUDIO DOWNLOAD COMPLETED!
	downloadfromcookievideo0 = VIDEO DOWNLOAD IN PROGRESS..
	downloadfromcookievideo1 = VIDEO DOWNLOAD FINISHED!
	
'@

#UPDATESMENUFUNCTIONS
ConvertFrom-StringData @'
	checkpobierakversion00 = A NEW VERSION OF POBIERAK IS AVAILABLE:
	checkpobierakversion10 = THE NEWER VERSION INCLUDES THE FOLLOWING CHANGES:
	news00 = -3.43 Improved cookie extraction from edge and chrome ; fixed errors in the information area ; -slightly improved filter for detecting playlists in links
	checkpobierakversion01 = DO YOU WANT TO UPDATE ?: PRESS 1 = YES .. 2 = NO
	checkpobierakversion02 = ENTER THE CORRECT VALUE: 1-2:
	checkpobierakversion03 = THERE IS NO NEWER VERSION OF POBIERAK AT THE MOMENT.
	checkpobierakversion04 = PRESENT VERSION IS:
	checkpobierakversionupd01 = UPDATING POBIERAK IN PROGRESS.
	checkpobierakversionupd02 = POBIERAK IS UP TO DATE.
	checkpobierakversionupd03 = IN THE MOMENT A NEW VERSION WILL BE OPENED AND THE OLD VERSION WILL BE CLOSED.
	ffmpgupd00 = DOWNLOADING THE CONVERTER FROM THE GITHUB REPOSITORY .. IT MAY TAKE A WHILE . YOU CAN OPEN A BEER AND PATIENCE ;)
	ffmpgupd01 = CONVERTER DOWNLOAD COMPLETED !!!
	ffmpgupd02 = UNZIPPING THE CONVERTER IN PROGRESS..
	ffmpgupd03 = UNPACKING COMPLETE!
	ffmpgupd04 = THE CONVERTER IS DOWNLOADED, UNPACKED AND READY FOR USE.
	ytdlpupd00 = DOWNLOADING YT-DLP.exe IN PROGRESS
	ytdlpupd01 = DOWNLOAD YT-DLP SUCCESSFUL!!!
	allinone00 = ALL OPERATIONS COMPLETED.
	previousversion00 = DO YOU WANT TO RESTORE PREVIOUS VERSIONS OF POBIERAK ?: PRESS 1 = YES .. 2 = NO .
	previousversion01 = RESTORING THE PREVIOUS VERSION.
	previousversion02 = THE PREVIOUS VERSION HAS BEEN RESTORED.
	previousversion03 = THE PREVIOUS VERSION WILL NOT BE RESTORED.
	updmenu00 = Current version of the program:
	updmenu01 = 1: CHECK IF A NEWER VERSION OF THE POBIERAK IS AVAILABLE.
	updmenu02 = 2: DOWNLOAD THE FFMPEG LIBRARY TO CONVERT DOWNLOADED MULTIMEDIA.
	updmenu03 = 3: GET YT-DLP.
	updmenu04 = 4: PERFORM ALL OPERATIONS AT ONCE.
	updmenu05 = 5: RESTORE PREVIOUS POBIERAK VERSION.
	updmenu06 = 6: TO EXIT THIS MENU
	updmenu07 = MAKE YOUR CHOICE BY ENTERING THE RIGHT OPTION NUMBER.
	updmenu08 = CONFIRM WITH ENTER:
'@

#ytdlpdev
ConvertFrom-StringData @'
	ytdlpdevintro01 = WELCOME IN THE POBIERAK FOR AMBITIOUS  ;)
	ytdlpdevintro02 = HERE YOU CAN ENTER THE COMMANDS DIRECTLY FOR THE YOUTUBE-DLP PROGRAM.
	ytdlpdevintro03 = A COMPLETE LIST OF COMMANDS YOU CAN FIND ON THE YT-DLP PROJECTS PAGE: https://github.com/yt-dlp/yt-dlp | OR AFTER ENTERING AN ARGUMENT: --help
	ytdlpdev00 = PROVIDE A SET OF ARGUMENTS AND CONFIRM WITH ENTER.
	ytdlpdev01 =  TO EXIT WRITE: quit
	ytdlpdev02 = POBIERAK FOR AMBITIOUS CLOSED
'@

#mainmenu
ConvertFrom-StringData @'
	mainmenu00 = Pobierak version:
	mainmenu01 = 1: DOWNLOAD FROM YT LINKS PASTED ONE AFTER ANOTHER.
	mainmenu02 = 2: DOWNLOAD SONGS FROM YT LINKS IN THE FILE.
	mainmenu03 = 3: DOWNLOAD AUDIO FROM THE PLAYLIST.
	mainmenu04 = 4: DOWNLOAD AUDIO FROM THE INDICATED YT CHANNEL.
	mainmenu05 = 5: DOWNLOAD VIDEO AND / OR AUDIO (SINGLE SONGS).
	mainmenu06 = 6: DOWNLOAD VIDEO AND / OR AUDIO FROM PLAYLIST OR CHANNEL.
	mainmenu07 = 7: DOWNLOAD FROM PRIVATE PLAYLIST IN YT PROFILE VIDEO AND / OR AUDIO.
	mainmenu08 = 8: UPDATES MENU
	mainmenu09 = EXIT: TO EXIT ENTER - 10
	mainmenu10 = MAKE YOUR CHOICE BY ENTERING THE RIGHT OPTION NUMBER.
	mainmenu11 = CONFIRM WITH ENTER:
'@
