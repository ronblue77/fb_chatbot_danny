'#define fbc -s console -gen gcc -Wc -Ofast -Wc -Wno-maybe-uninitialized -exx -w all
#include "bass.bi"
#ifdef __FB_LINUX__
#undef MAKELONG
#endif
#INCLUDE "window9.bi"

#include "fb_chatbot_danny_v10.bas"

'''#include "windows.bi"

'ShowWindow(GetConsoleWindow(), SW_HIDE)

LoadArrays("database/database-encrypted.txt") ' eliza_script.txt
'loadarrays("database/eliza-encrypted.txt")

const ABOUT = "database/about.txt"

dim shared as long BaseWidth 
BaseWidth = 800
dim shared as long BaseHeight 
BaseHeight = 600

#define ScaleX(_V) ((((_V)*WinWid)\BaseWidth))
#define ScaleY(_V) ((((_V)*WinHei)\BaseHeight))

Dim shared as double start
start = timer

'linux compat
#ifndef BS_DEFPUSHBUTTON
	#define BS_DEFPUSHBUTTON 0
#endif

enum GadgetID
	giFirst = 100
	giOutputEdit
	giInputEdit
	giTalkButton
	giReplayButton
	giDeleteButton
	giLearnButton
	giAnnButton
	giRandomButton
	giElizaButton
	giRcountButton
	giBitImageButton
	giAboutEditText
end enum
enum ShortCutID
	siFirst = 1000
	siDefKey
end enum

Dim As HWND hMainForm
Dim As HWND hSecondForm
Dim As Integer event

dim as string msg 
msg = txtfile(ABOUT)

dim shared as HBITMAP HIMAGE
HIMAGE=Load_image("logo1.png")

hSecondForm = Openwindow( "ABOUT", 900, 10, 400, 340 )
Editorgadget(giAboutEditText, 10, 10, 360, 280, msg , 0)
SetGadgetColor(giAboutEditText,50000,0,1)

hMainForm = OpenWindow( "Chatbot Danny v1.1.6.3", 100, 10, BaseWidth, BaseHeight)

ButtonImageGadget(giBitImageButton,10,10,450,80,HIMAGE, FB_BS_PUSHLIKE or BS_BITMAP)

'AddSysTrayIcon(giBitImageButton,hMainForm,load_Icon("chatbot.ico"),"Icon")

EditorGadget(giOutputEdit, 10, 100, 700,340, "Danny: Hello my friend!", 0) '"hello dear one i'm here to talk with you on what ever you want", 0 )
writefile2("Danny: Hello my friend!")
SetGadgetFont(giOutputEdit, CINT(LoadFont( "MS Dialog", 11)))
Readonlyeditor(giOutputEdit, 1)
SetTransferTextLineEditorGadget(giOutputEdit, 1)

#ifdef __FB_LINUX__
	EditorGadget(giInputEdit, 10, 440, 700, 100, "", 0 )
#else
	StringGadget(giInputEdit, 10, 440, 700, 100, "", ES_MULTILINE or WS_VSCROLL)  '"hellooo??????", 0)
#endif
SetGadgetFont(giInputEdit, CINT(LoadFont( "MS Dialog", 11)))
SetTransferTextLineEditorGadget(giInputEdit, 1)

ButtonGadget(giTalkButton, 720, 520, 60, 30, "Talk", BS_DEFPUSHBUTTON)
ButtonGadget(giReplayButton, 720, 490, 60, 30, "LOG", BS_DEFPUSHBUTTON)
ButtonGadget(giDeleteButton, 720, 460, 60, 30, "Delete", BS_DEFPUSHBUTTON)
ButtonGadget(giLearnButton, 720, 430, 60, 30, "Learn", BS_DEFPUSHBUTTON)
ButtonGadget(giAnnButton, 720, 400, 60, 30, "ML Algo", BS_DEFPUSHBUTTON)
ButtonGadget(giRandomButton, 720, 370, 60, 30, "Crazy", BS_DEFPUSHBUTTON)
ButtonGadget(giElizaButton, 720, 340, 60, 30, "ELIZA", BS_DEFPUSHBUTTON)
ButtonGadget(gIRcountButton, 720, 310, 60, 30, "Random", BS_DEFPUSHBUTTON)
SetFocus(Gadgetid(giInputEdit))                  ' focus on the editor 2
UpdateInfoXserver()                              ' for linux , so that xserver has time to update the information

AddKeyboardShortcut(hMainForm, FVIRTKEY, VK_RETURN, siDefKey)

dim shared isEliza as boolean = false

Sub speak(text as string ptr)
	#Ifdef __FB_LINUX__
		Shell( "espeak-ng -v us-mbrola-2 -s 120 " & chr(34) & *text & chr(34))
	#Else
		'    shell( "voice -r -1 -n " & Chr(34) & TTSvoice & Chr(34) & " " & Chr(34) & *text & Chr(34))
		'TTS.Voice("Microsoft Sam")
		TTS.VoiceByID(7)
		TTS.Speak( *text, True )
	#endif
End Sub

sub DefaultButtonPressed()
	Dim As String respond(5) = {"why don't you talk to me?", "am i boring you?", "a penny for your thoughts", "what's on your mind?", "how are you my friend?"}
	Var text = GetGadgetText(giInputEdit)
	writefile2 ("You: " + text)
	dim ans as string
	if isEliza = false then
		ans = commands(text)
	else
		ans = GetReply(text)
	endif
	if (timer - start) > 600 then
		ans = respond(int(rnd*(ubound(respond)+1)))
	EndIf
	writefile2 ("Danny: " + ans)
	SetGadgetText(giInputEdit, "")
	Var reply1 = GetGadgetText(giOutputEdit)
	SetGadgetText(giOutputEdit, reply1 + !"\n" + "You: " + text + !"\n" + "Danny: " + ans)
	'threadcreate for TTS speak function (sub) shell command
	static as any ptr a :if a then ThreadWait(a)
	Static as string sTemp :sTemp = ans
	a = ThreadCreate(cast(any ptr, @Speak), @sTemp)
	LineScrollEditor(giInputEdit, 5)
	LineScrollEditor(giOutputEdit, 15)
	start = timer
end sub

sub ReplayButtonClick()
	if (fileexists(file) = true) then
		
		#ifdef __fb_linux__
			shell("xdg-open "+ file ) 'https://youtu.be/MUTz3LQEq1Q")
		#else
			shell("start " + file ) 'https://youtu.be/MUTz3LQEq1Q")
			'				shell("start /unix /usr/bin/firefox https://youtu.be/MUTz3LQEq1Q")
		#endif
	else
		var replay3 = getgadgettext(giOutputEdit)
		setgadgettext(giOutputEdit, replay3 + chr(10) + "NO LOG FILE EXISTS!" + chr(10))
		linescrolleditor(giOutputEdit, 5)
	END IF
	SetFocus(Gadgetid(giInputEdit))
End Sub

sub deleteButtonClick()
	Dim result As Integer = Kill( file )
	kill(questions)
	kill(answers)
	if result = 0 then var replay5 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, replay5+ chr(10) + "CONVERSATION LOG FILE BEEN DELETED!" + chr(10))
	linescrolleditor(giOutputEdit, 5)
	SetFocus(Gadgetid(giInputEdit))
End Sub

dim shared as long switch

sub buttonLeranClick()
	if switch = 0 then
		islearnMode = true
		var past1 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past1+chr(10)+ "LEARN MODE NOW ENABLED!" +chr(10))
		linescrolleditor(giOutputEdit, 5)
		switch = 1
	elseif switch = 1 then
		isLearnMode = false
		var past2 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past2+chr(10)+ "LEARN MODE NOW DISABLED!" +chr(10))
		linescrolleditor(giOutputEdit, 5)
		switch = 0
	end if
	SetFocus(Gadgetid(giInputEdit))
End Sub

sub AnnButtonClick()
	if isnna = false then
		isnna = true
		var past3 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past3+chr(10)+"WEAK ANN MODE NOW ENABLED!"+chr(10))
		linescrolleditor(giOutputEdit, 5)
	else
		isnna = false
		var past4 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past4+chr(10)+"WEAK ANN MODE NOW DISABLED!"+chr(10))
		linescrolleditor(giOutputEdit, 5)
	EndIf
	SetFocus(Gadgetid(giInputEdit))
End Sub

sub randomButtonClick()
	if israndom = false then
		israndom = true
		var past5 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past5+chr(10)+"CRAZY MODE NOW ENABLED!"+chr(10))
		linescrolleditor(giOutputEdit, 5)
	else
		israndom = false
		var past6 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past6+chr(10)+"CRAZY MODE NOW DISABLED!"+chr(10))
		linescrolleditor(giOutputEdit, 5)
	EndIf
	SetFocus(Gadgetid(giInputEdit))
End Sub

sub elizaButtonClick()
	if isEliza = false then
		isEliza = true
		var past7 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past7+chr(10)+"NOW TALING TO ELIZA AS DANNY!"+chr(10))
		linescrolleditor(giOutputEdit, 5)
	else
		isEliza = false
		var past8 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past8+chr(10)+"NOW TALKING TO DANNY NOT AS ELIZA!"+chr(10))
		linescrolleditor(giOutputEdit, 5)
	EndIf
	SetFocus(Gadgetid(giInputEdit))
End Sub

sub RcountButtonClick()
	if isCounterReplies = true then
		isCounterReplies = false
		var past9 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past9+chr(10)+"REPLIES NOW ARE MORE RANDOMIZED"+chr(10))
		linescrolleditor(giOutputEdit, 5)
	else
		isCounterReplies = TRUE
		var past10 = getgadgettext(giOutputEdit) : setgadgettext(giOutputEdit, past10+chr(10)+"REPLIES NOW ARE LESS RANDOMIZED"+chr(10))
		linescrolleditor(giOutputEdit, 5)
	endif
	SetFocus(Gadgetid(giInputEdit))
end sub

sub size_change( WinWid as long , WinHei as long )
	
	HIMAGE= Resize_image(HIMAGE,ScaleX(450),ScaleY(80))
	ButtonImageGadget(giBitImageButton,ScaleX(10),ScaleY(10),ScaleX(450),ScaleY(80),HIMAGE, FB_BS_PUSHLIKE or BS_BITMAP)

	Resizegadget(giOutputEdit,ScaleX(10),ScaleY(100), ScaleX(700), ScaleY(340))
    Readonlyeditor(giOutputEdit, 1)
	SetTransferTextLineEditorGadget(giOutputEdit, 1)
	
	Resizegadget(giInputEdit,ScaleX(10), ScaleY(440), ScaleX(700), ScaleY(100))
	SetTransferTextLineEditorGadget(giInputEdit, 1)
	
	SetGadgetFont(giOutputEdit, CINT(LoadFont( "MS Dialog", ScaleY(11))))
	SetGadgetFont(giInputEdit, CINT(LoadFont( "MS Dialog", ScaleY(11))))
	
    Resizegadget(giTalkButton,ScaleX(720), ScaleY(520), ScaleX(60), ScaleY(30))
    Resizegadget(giReplayButton,ScaleX(720),ScaleY(490),ScaleX(60),ScaleY(30))
    Resizegadget(giDeleteButton,ScaleX(720),ScaleY(460),ScaleX(60),ScaleY(30))
    Resizegadget(giLearnButton,ScaleX(720),ScaleY(430),ScaleX(60),ScaleY(30))
    Resizegadget(giAnnButton,ScaleX(720),ScaleY(400),ScaleX(60),ScaleY(30))
    Resizegadget(giRandomButton,ScaleX(720),ScaleY(370),ScaleX(60),ScaleY(30))
    Resizegadget(giElizaButton,ScaleX(720),ScaleY(340),ScaleX(60),ScaleY(30))
    Resizegadget(giRcountButton,ScaleX(720),ScaleY(310),ScaleX(60),ScaleY(30))
	SetFocus(Gadgetid(giInputEdit))                  ' focus on the editor 2
	UpdateInfoXserver()                              ' for linux , so that xserver has time to update the information
end sub


Do

	select case WaitEvent()
		case Eventsize
			if EventHwnd=hMainForm then
			size_change( WindowWidth(hMainForm) , WindowHeight(hMainForm) )
			endif
'			continue do
			
		case EventMenu
			if EventNumber = siDefKey then DefaultButtonPressed()
		case EventClose
			if EventHwnd() = hSecondForm then
			close_window(hSecondForm)
			else
'			Deletesystrayicon(giBitImageButton)
			'freeMusic()                                     'if eventclose = hMainForm then
			End
			end if
		case EventGadget
			select case EventNumber
				case giTalkButton
					DefaultButtonPressed()
				case giReplayButton
					ReplayButtonClick()
				case giDeleteButton
					deleteButtonClick()
				case giLearnButton
					buttonLeranClick()
				case giAnnButton
					AnnButtonClick()
				case giRandomButton
					randomButtonClick()
				CASE giElizaButton
					elizaButtonClick()
				case giRcountButton
					RcountButtonClick()
			end select
	end select
Loop
