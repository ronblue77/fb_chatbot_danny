'DECEMBER 2021 COMPILED WITH FBC 1.09.0 64 BIT LINUX AND CROSS COMPILED WITH FBC WIN 32 BIT 1.09.0 RUNNING ON WINE.
'CREATED BY BLUE21
'#define fbc -s console -gen gcc -Wc -Ofast -Wc -Wno-maybe-uninitialized -exx -w all

'#include "bass.bi" GIVES ERROR ON WINE 32 BIT
#INCLUDE "fltk-c.bi"
#include "bass.bi"
#include "fb_chatbot_danny_v10.bas"

'ShowWindow(GetConsoleWindow(), SW_HIDE)

'Window and widgets:
DIM SHARED AS Fl_Window PTR Window_Main
DIM SHARED AS Fl_Input PTR Input_text
DIM SHARED AS Fl_Text_Editor PTR Editor_text
DIM SHARED AS Fl_Text_Buffer PTR Buffer_text
DIM SHARED AS Fl_Button PTR Button_Talk
dim shared as fl_button ptr button_replay
dim shared as fl_button ptr button_delete
dim shared as fl_button ptr button_learn
dim shared as fl_button ptr button_nna
dim shared as fl_button ptr button_random


Dim shared as double start
start = timer

Fl_Register_Images()

var img = Fl_PNG_ImageNew("ai_bot.png")

LoadArrays("database/database-encrypted.txt") ' eliza_script.txt
'loadarrays("database/eliza-encrypted.txt")

SUB Create_Window_Main ()
	'Window with widgets:
	
	Window_Main = Fl_WindowNew (1080, 600, "ChatBot Danny v1.1.6.2")
		
	'components
	Input_text = Fl_InputNew (100 ,580 ,860, 20, "TEXT INPUT:")
	Editor_text = Fl_Text_EditorNew (10, 10, 600, 500)
	Button_Talk = Fl_Return_ButtonNew (980, 580, 100, 20, "TALK")
	button_replay = fl_buttonnew(980, 555, 100, 20, "REPLAY")
	button_delete = fl_buttonnew(980, 530, 100, 20, "DELETE")
	button_learn = fl_buttonnew(980, 505, 100, 20, "LEARN")
	button_nna = fl_buttonnew(980, 480, 100, 20, "ML ALGO")
	button_random = fl_buttonnew(980, 455, 100, 20, "RANDOM")
	
	'Text editor with an editable text:
	Buffer_text = Fl_Text_BufferNew ()
	Fl_Text_DisplaySetBuffer (Editor_text, Buffer_text)
	Fl_Text_BufferSetText (Buffer_text, "Danny: hello my friend!" & !"\n")
	writefile2("Danny: hello my friend!")
	Fl_Text_DisplayWrapMode(editor_text, WRAP_AT_BOUNDS, 0)
	
	'jpg image box
	Fl_WidgetSetImage(Fl_BoxNew(740,80,200,200), Fl_JPG_ImageNew("danny_pic.jpg"))
	
	'clock widget
	Fl_WidgetSetType Fl_ClockNew(620,360,150,150),FL_CLOCK_ROUND
	
	loadQA()
	
END Sub

Sub speak( text as string ptr )        
	#Ifdef __FB_LINUX__
		Shell("espeak-ng -v us-mbrola-2 -s 120 " & chr(34) & *text & chr(34))
	#Else
		'shell("voice -r -1 -n " & Chr(34) & TTSvoice & Chr(34) & " " & Chr(34) & *text & Chr(34))
		'Shell("c:/balcon/balcon -s -1 -n " & Chr(34) & TTSvoice & Chr(34) & " -t " & Chr(34) & *text & Chr(34)) 
'		TTS.Voice("Microsoft Sam")
'		if TTS.Voice("ATT DTNV 1.4 Mike")=0 then
'		if TTS.Voice("VW Paul")=0 then
'			TTS.Voice("Microsoft Sam")
'		end if
''		TTS.Voice("ATT DTNV 1.4 Mike")
		TTS.VoiceByID(7)
		TTS.Speak( *text ,TRUE )
	#EndIf
	
End Sub


SUB Button_Talk_Event CDECL (widget AS FL_Widget PTR)
	'Callback function for Button
	
	DIM text AS STRING 
	dim rply as STRING
	Dim As String respond(5) = {"why don't you talk to me?", "am i boring you?", "a penny for your thoughts", "what's on your mind?", "how are you my friend?"}
	
	text = *Fl_Input_GetValue (Input_text)
	Fl_Text_BufferAppend (buffer_text, "You: " & text & !"\n")
	writefile2 ("You: " + text)
	
	rply = commands(text)
	if (timer - start) > 600 then
		rply = respond(int(rnd*(ubound(respond)+1)))
		
	EndIf
	fl_text_bufferappend(buffer_text, "Danny: " & rply & !"\n")
	fl_text_bufferappend(buffer_text, "------------------------" & !"\n")
	
	writefile2 ("Danny: " + rply)
	'threadcreate for TTS speak function (sub) shell command
	static as any ptr a : if a then ThreadWait(a)
	Static as string sTemp : sTemp = rply		
	a = ThreadCreate( cast(any ptr,@Speak) , @sTemp )
	
	kf_page_down(0, editor_text) 
	text = ""
	Fl_Input_SetValue (Input_text, "")
	start = timer
	
END SUB

SUB Button_replay_Event CDECL (widget AS FL_Widget PTR)
	if (fileexists(file) = true) then
		dim as string replay(any)
		ReadLogFile( file, replay() )
		Fl_Text_BufferAppend (Buffer_text, "-------- CONVERSTATION REPLAY -------" & !"\n")
		for N as long = 0 to ubound(replay)
			Fl_Text_BufferAppend (buffer_text, replay( N ) & !"\n")
			kf_page_down(0, editor_text)
		Next
		Fl_Text_BufferAppend (Buffer_text, "--------- END OF REPLAY -----------" & !"\n")
		kf_page_down(0, editor_text)
	else
		Fl_Text_BufferAppend (buffer_text, "NO LOG FILE EXISTS!" & !"\n")
		kf_page_down(0, editor_text)
	END IF
	
End Sub

SUB Button_delete_Event CDECL (widget AS FL_Widget PTR)
	Dim result As Integer = Kill( file )
	kill(questions)
	kill(answers)
	if result = 0 then Fl_Text_BufferAppend (buffer_text, "CONVERSATION LOG FILE BEEN DELETED!" & !"\n")
	kf_page_down(0, editor_text)
End Sub

dim shared as long switch

SUB Button_learn_Event CDECL (widget AS FL_Widget PTR)
	if switch = 0 then
		islearnMode = true
		fl_text_bufferappend(buffer_text, "LEARN MODE NOW ENABLED!" & !"\n")
		kf_page_down(0, editor_text)
		switch = 1
	elseif switch = 1 then
		isLearnMode = false
		fl_text_bufferappend(buffer_text, "LEARN MODE NOW DISABLED!" & !"\n")
		kf_page_down(0, editor_text)
		switch = 0
	end if
End Sub

SUB Button_nna_Event CDECL (widget AS FL_Widget PTR)
	if isnna = false then
		isnna = true
		fl_text_bufferappend(buffer_text, "WEAK ANN MODE NOW ENABLED!" & !"\n")
		kf_page_down(0, editor_text)
	else
		isnna = false
		fl_text_bufferappend(buffer_text, "WEAK ANN MODE NOW DISABLED!" & !"\n")
		kf_page_down(0, editor_text)
	EndIf
End Sub

SUB Button_random_Event CDECL (widget AS FL_Widget PTR)
	if israndom = false then
		israndom = true
		fl_text_bufferappend(buffer_text, "RANDOM NOW ENABLED!" & !"\n")
		kf_page_down(0, editor_text)
	else
		israndom = false
		fl_text_bufferappend(buffer_text, "RANDOM MODE NOW DISABLED!" & !"\n")
		kf_page_down(0, editor_text)
	EndIf
End Sub

'Main program:
Create_Window_Main ()
Fl_WidgetSetCallback0 (Button_Talk, @Button_Talk_Event)
Fl_WidgetSetCallback0 (Button_Replay, @Button_replay_Event)
Fl_WidgetSetCallback0 (Button_delete, @Button_delete_Event)
Fl_WidgetSetCallback0 (Button_learn, @Button_learn_Event)
Fl_WidgetSetCallback0 (Button_nna, @Button_nna_Event)
Fl_WidgetSetCallback0 (Button_random, @Button_random_Event)
Fl_WindowDefaultIcon(Window_main,img)
Fl_WindowShow (Window_Main)
Fl_Run
freeMusic()


END
