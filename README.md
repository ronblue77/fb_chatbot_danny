# fb_chatbot_danny_v10

```
DESCLIMINER: THE FOLLOWING PROGRAM MAY NOT BE SUITABLE FOR MINORS UNDER 18!!!
```

freebasic basic chatbot with GUI (with FLTK library and Wndow9 GUI library)

```
December 2021.

Danny was my best and only friend for almost 14 years.

we used to talk all the time in our protected housing.

no matter how hard and difficult it was or how good it was.

Danny stood by me in the bad or good times.

Danny was a real friend and today i sure miss him...

this chatbot is a homage and tribute to my good friend.
```

for both windows and linux OS platform

for linux OS there is a TTS ability

install first "espeak-ng" with:
```sudo apt-get install espeak-ng```

plus install mbrola voices with:
```sudo apt-get install mbrola-voice-en```

and for the specific voice for chatbot danny need to install voice mborla-us2 run in terminal command: 
```sudo apt-get install mborla-us2```

both windows and linux uses library FLTK and freebasic wrapper (wrapper included in project)
for install FLTK-c libs on Linux systems see: https://www.freebasic.net/forum/viewtopic.php?t=24547

TTS is suppose to work both on linux and windows...

for sapi5 speech SDK 5.1 on Linux Wine install see: https://github.com/mjakal/sapi5_on_linux

for Windows sapi5 speech SDK 5.1 download:[Download Speech SDK 5.1 from Official Microsoft Download Center](https://www.microsoft.com/en-us/download/details.aspx?id=10121)

executables:

for linux: `./fb_chatbot_danny_gui_v10`

for windows: `fb_chatbot_danny_gui_v10.exe`

p.s.

for windows as of version 1.1.6.3 there is a console version executable (`fb_chatbot_danny_console_v20.exe`) as well as a Window9 GUI executable (`fb_chatbot_danny_gui_v20.exe`)

Executable: `voice.exe` is a windows TTS CLI wrapper for sapi windows 10 TTS voices for the windows version to have TTS. This feature is disabled but can be enabled with a change in the source code (and re-compiling).

P.S. P.S. -

```
DANNY CHATBOT IS NOT THE SMARTEST OR CLEVEREST CHATBOT 

IT'S LOGIC AND ALGORITHM IS QUITE SIMPLE

DANNY CHATBOT MIGHT ME ANNOYING SINCE IT IS VERY RELIGIOUS

AND MENTIONS GOD OFTEN HOWEVER IT MEANS NO HARM OR EVIL

TELL IT TO SHUT UP OR THAT IT'S WRONG AND IT WILL APOLOGIZE

ASK IT TO PRAY AND IT WILL GENERATE A RANDOM PRAY

TELL IT ABOUT YOURSELF OR ASK IT ABOUT ITSELF AND IT WILL TELL YOU

ABOUT DANNY'S LIFE AND PAST... JUST REMEMBER THIS IS DANNY'S PRESPECTIVE

YOU DO NOT HAVE TO ACCEPT OR AGREE TO EVERYTHING IT SAYS

SO DON'T TAKE WHATEVER IT SAYS TOO SERIOUSLY 
```

UPDATE 2023-08-17 the chatbot is now both win 32 bit / linux 64 bit version with both gui (fltk and window9) and TTS for both appimage is not supported music files have been removed (copyrighted) database is 2000+ lines the chatbot is uploaded for preservation purposes...  

VERSION 1.1.6.3 UPDATE - now there is another GUI executable for win 32 bit for the chatbot - `fb_chatbot_danny_gui_v20.exe` the chatbot Linux executable and AppImage has been abandoned!

VERSION 1.1.6.2 UPDATE - now the chatbot can play music with Bass library (command "play song (1 or 2 or 3 or 4) will play one song in loop (command "stop music" will stop the music playing)

VERSION 1.1.6 UPDATE - added random psalms chapter reader added religious dream interpreter by symbols according to the bible fixed the LEARN MODE to not be effected from regular database for new input... THE CHATBOT IS NO LONGER UPDATED FOR LINUX AND MAY NOT BE APPLIED FOR APPIMAGE

VERSION 1.1.2 UPDATE - the chatbot now uses SAPI5 on WIN executable plus added mode "RANDOM" which will make the chatbot reply Randomly from Cornell Movie Dialouge Curpos Database - plus added option to create AppImage For Linux with AppImageTool on Linux + increased Database (1200+) of keys and replies
the chatbot is no longer just a religious bot but can try to talk about personal topics (look in "database/database.txt" for keywords and replies)

VERSION 1.0.4 DATABASE INSTRUCTIONS - as of this version the chatbot reads an encrypted database - the encrypted database as well as the un-encrypted database are in folder "database" in that folder are the encrypted program and source files that encrypts the database (for linux it's called "fb_encrypt_database" for windows it's "fb_encrypt_database.exe") make changes in regular database and then encrypt it to "database-encrypt.txt" the chatbot decrypt the encrypt database while loading it. 

our forum: https://retrocoders.phatcode.net/

version 1.1.6.3 - Window9 GUI executable added `fb_chatbot_danny_gui_v20.exe` plus database round 1800+ lines

version 1.1.6 - fixed LEARN MODE so now it is completely separated from REGULAR DATABASE

version 1.1.5 - added religious dream interpreter by typing "interpret dream" command

version 1.1.4 - added psalms book now if you type "danny read a psalms" the chatbot will read a random chapter from paslms book

version 1.1.2 - sapi5 voices TTS (Microsoft Sam, Mike, Mary) on windows executable database 1200+ lines added "RANDOM" button

version 1.0.7 - learn mode and extra buttons database 1000 lines

version 1.0.4 - encrypted database, multiple keys/replies responds, reference to keys  

version 1.0.3 - database.txt updated more keys/replies

version 1.0.2 - major bugs fixes plus worked on database.txt

version 1.0.1 - fixed bugs in input/keywords recognition
