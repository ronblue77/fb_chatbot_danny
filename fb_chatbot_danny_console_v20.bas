#include "fb_chatbot_danny_v10.bas"

LoadArrays("database/database-encrypted.txt") ' eliza_script.txt
'loadarrays("database/eliza-encrypted.txt")

'Dim shared as double start
'start = timer


'Sub speak(text as string )
'	#Ifdef __FB_LINUX__
'		Shell( "espeak-ng -v us-mbrola-2 -s 120 " & chr(34) & text & chr(34))
'	#Else
'		'    shell( "voice -r -1 -n " & Chr(34) & TTSvoice & Chr(34) & " " & Chr(34) & *text & Chr(34))
'		'TTS.Voice("Microsoft Sam")
'		TTS.VoiceByID(1)
'		TTS.Speak( text, True )
'	#endif
'End Sub

'Dim As String respond(5) = {"why don't you talk to me?", "am i boring you?", "a penny for your thoughts", "what's on your mind?", "how are you my friend?"}

dim text as string, answer as STRING

'state_read(state, g_Key_Reply() )

'PRINT "-START OF CONVERSATION WITH DANNY-"

'do
    input "", text
    answer = commands(text)
    print answer
    'speak(answer)
'loop 

'state_write(state, g_Key_Reply() )

'print "-END OF CONVERSATION WITH DANNY-"

'sleep

