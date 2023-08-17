'DECEMBER 2021 COMPILED WITH FBC 1.08.1 64 BIT LINUX AND CROSS COMPILED WITH FBC WIN 32 BIT 1.08.1 RUNNING ON WINE.
'CREATED BY BLUE21
#ifdef __fb_win32__
	#Include  "TTS.bas"
	'~ #include "fb_music.bas"
#endif
#include "fb_random.bas"
#include "fb_eliza.bas"
#include "fb_psalms.bas"
#include "fb_chatbot_danny_nna_brain.bas"
#include "fb_dream.bas"
#include "vbcompat.bi"
#include "fb_music.bas"
'Screen 19 'for console chatbot program

const MUSICFILE1 = "music/song1.mp3"
const MUSICFILE2 = "music/song2.mp3"
const MUSICFILE3 = "music/song3.mp3"
const MUSICFILE4 = "music/song4.mp3"
const MEDITATION1 = "music/meditation1.mp3"
const CHETJAZZ1 = "music/chet1.mp3"

' uses same alphabet and key as Ada language example
Const string1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
Const string2 = "VsciBjedgrzyHalvXZKtUPumGfIwJxqOCFRApnDhQWobLkESYMTN"

Type ArraySet
	ReDim Keywords(any) As String
	ReDim Replys(Any)   As String
	ReplaysIndex as long
	ReplaysStart as long
	ReplaysEnd as long
End Type

'declare two string dynamic arrays for keywords(answers) and replies(questions)
REDIM SHARED AS STRING ans(0), ques(0)
'for words switch
redim shared as string wordIn(0), wordOut(0)
dim shared as long wCnt

'declare two conctants of string for the two databases text files
'CONST answersFile = "answers.txt"
'CONST questionsFile = "questions.txt"
'dim shared as string answers, questions

dim shared as boolean isnewinput = false
dim shared as string userinput1 ', userinput2
DIM SHARED AS BOOLEAN isLearnMode = FALSE
CONST punctuation = "?!,.:;<>(){}[]"
'const logfile = "log.txt"
'dim shared as string file
redim shared as string pray(any), pray1(any), pray2(any), pray3(any), pray4(any)
redim shared deafult(any) as STRING
redim shared xwords(any) as STRING
redim shared love(any) as STRING
redim shared noscared(any) as STRING
redim shared scared(any) as STRING
redim shared botQ(any) as string
redim shared who(any) as STRING
redim shared command1(any) as STRING
ReDim Shared g_Key_Reply(Any) As ArraySet
'Dim Shared As string inpt, rply ' for console chatbot
dim shared as boolean isUserQuestion = true
dim shared as string botQuestions
dim shared counterx as LONG
dim shared isNNA as boolean = false
dim shared israndom as boolean = false ' CHANGED REMENBER TO CHANGE BACK!!! TO FALSE!!!
redim shared data2(any) as STRING
'dim shared replay(any) as string
counterx = 1
''for FB WIN windows 10 to use with voices.exe TTS CLI
DIM SHARED TTSvoice as STRING
TTSvoice = "Microsoft David Desktop" 'tts female or male voice (or Zira or David)
'TTS.Voice("Microsoft Mike")
'RANDOMIZE()
dim shared as boolean isCounterReplies = true
'answers = curdir()+"/"+answersFile
'questions = curdir()+"/"+questionsFile
''log file goes on current folder
'file = curdir()+"/"+logfile
'everything else goes on executable folder
'chdir exepath()
const state = "database/state.bin"
 

Dim f AS LONG = FREEFILE()
open file for append as #f
close #f
'open files for append and by so creating the text files
DIM AS LONG h = FREEFILE()
OPEN answers FOR APPEND AS #h
CLOSE #h
OPEN questions FOR APPEND AS #h
CLOSE #h

sub writefile2(text2 as String)	
	dim f as long = freefile()
	open file for append as #f
	print #f , text2
	close #f	
End Sub

'return whole text file
function txtfile(f AS STRING) as STRING
	DIM AS STRING buffer
	DIM h AS LONG = FREEFILE()
	OPEN f FOR BINARY AS #h
	buffer = SPACE(LOF(h))
	GET #h ,  , buffer
	CLOSE #h
	return buffer
End function

sub load(fname as string)
	var f = freefile()
	var fline = ""
	open fname for input as #f
	while not eof(f)
		line input #f, fline
		if len(fline) > 0 then
			sAppend(data2(), fline)
		EndIf
	Wend
	close #f
End Sub

load("database/database-eng.txt")

sub iAppend(arr() as long , temp as long)
	'if the array is empty make it start as the lbound index not ubound (or 0 or 1, whatever...)
	var iUbound = iif( ubound(arr)<lbound(arr) , lbound(arr) , ubound(arr) )
	REDIM PRESERVE arr(LBOUND(arr) TO iUbound+1) as long
	arr(ubound(arr)) = temp
End Sub

SUB loadQA
DIM h AS LONG = FREEFILE()
DIM fline AS STRING
OPEN answers FOR INPUT AS #h
WHILE NOT EOF(h)
	LINE INPUT #h, fline
	SAPPEND ans(), fline
WEND
CLOSE #h
OPEN questions FOR INPUT AS #h
WHILE NOT EOF(h)
	LINE INPUT #h, fline
	SAPPEND ques(), fline
WEND
CLOSE #h
END SUB

FUNCTION isolatePunctuation (s AS STRING) as string
	'isolate punctuation so when we look for key words they don't interfere
	DIM as string b
	b = ""
	FOR i as integer = 1 TO LEN(s)
		IF INSTR(punctuation, MID(s, i, 1)) > 0 THEN b = b + " " + MID(s, i, 1) + " " ELSE b = b + MID(s, i, 1)
	NEXT
	return b
END FUNCTION

FUNCTION joinPunctuation (s AS STRING) as String
	'undo isolatePuntuation$
	DIM AS STRING b, find
	Dim place AS long
	b = s
	FOR i as integer = 1 TO LEN((punctuation))
		find = " " + MID(punctuation, i, 1) + " "
		place = INSTR(b, find)
		WHILE place > 0
			IF place = 1 THEN
				b = MID(punctuation, i, 1) + MID(b, place + 3)
			ELSE
				b = MID(b, 1, place - 1) + MID(punctuation, i, 1) + MID(b, place + 3)
			END IF
			place = INSTR(b, find)
		WEND
	NEXT
	return b
END Function

sub state_write(state_file as string, udt() as ArraySet )  ', index as integer  ) ', index as long ) ', counter as long )
	dim as long f = freefile
	open state_file for binary access write as #f
	for i as long = 0 to ubound(udt)
	put #f,,udt(i).ReplaysIndex
	next
'	put #f,,udt(index).ReplaysEnd
'	put #f,,udt(index).ReplaysStart
	close #f	
	
end sub

sub state_read(state_file as string, udt() as ArraySet ) ', index as integer ) ' , index as long)
	dim as long f = freefile
	open state_file for binary access read as #f
	for i as long = 0 to ubound(udt)
	get #f,,udt(i).ReplaysIndex
	next
'	get #f,,udt(index).ReplaysEnd
'	get #f,,udt(index).ReplaysStart
	close #f

	
end sub
''for console chatbot
'sub speak(lines as string)
'print lines
''for linux this next line:
'shell("espeak-ng -v us-mbrola-2 -s 120 " + chr(34) + lines + chr(34)) 'for female voice add -v us-mbrola-1 on espeak-ng or change to 'voices char(34) TTSvoice char(34)'for FB WIN
''for windoew 10 - FB WIN this next line
'Shell("voice -r -1 -n " & Chr(34) & TTSvoice & Chr(34) & " " & Chr(34) & lines & Chr(34))
'end SUB

SUB loadArrays(filename AS STRING)
	DIM h AS INTEGER = FREEFILE()
	DIM fline AS STRING
	Dim As String alpha, key
	dim as long temp
	alpha = string2 : key = string1
	dim as long ReplyCounter
	ReplyCounter = 0
	Dim s As String
	Dim p As Integer
	
	OPEN filename FOR INPUT AS #h
	Dim As Integer IsKeyWord=0,iKeyReplyNum=-1, isReplay = 0
	WHILE NOT EOF(h)
		LINE INPUT #h, s
		For i As Integer = 0 To Len(s) - 1  
			If (s[i] >= 65 AndAlso s[i] <= 90) OrElse (s[i] >= 97 AndAlso s[i] <= 122) Then
				p =  Instr(alpha, Mid(s, i + 1, 1)) - 1
				s[i] = key[p]         
			End If
		next i     
		fline = s
		Var iPosi = InStr(fline,":")
		'ignore the line if theres no : or if its too short or too long
		If iPosi < 2 Or iPosi > 8 Then Continue While
		Var sText = TRIM(MID(fline, iPosi+1))
		If iPosi = 2 Then 'check for 1 chracter entries
			Select Case fline[0]
				Case Asc("k") 'Keywords
					if isReplay = 1 then ' replies indexing
'						
						g_Key_Reply(iKeyReplyNum).ReplaysIndex = 0
						g_Key_Reply(iKeyReplyNum).ReplaysStart = 0
						g_Key_Reply(iKeyReplyNum).ReplaysEnd = ReplyCounter
						ReplyCounter = 0 : isReplay = 0
					endif
					If IsKeyWord=0 Then
						'if the previous entry was not a keyword add a new set entry
						IsKeyWord=1:iKeyReplyNum += 1 ': ReplyCounter = 0 : isReplay = 0
						ReDim Preserve g_Key_Reply(iKeyReplyNum)
					EndIf
					
					sAppend g_Key_Reply(iKeyReplyNum).Keywords(), " " + sText + " "
				Case Asc("r") 'Reply
					If iKeyReplyNum < 0 Then
						Print "ERROR: Reply without Keyword"
					EndIf
					isReplay = 1 'isReply
					IsKeyWord = 0 'not a Keyword
					sAppend( g_Key_Reply(iKeyReplyNum).Replys(), sText )
'					
					ReplyCounter += 1
				case asc("s")
					wCnt = wCnt + 1: temp = INSTR(fline, ">")
					IF temp THEN
						sAppend wordIn(), " " + Trim(MID(fline, 3, temp - 3)) + " "
						sAppend wordOut(), " " + Trim(MID(fline, temp + 1)) + " "
					END IF
			End select
		Endif
		if iPosi = 3 then
			select case left(fline, 2)
				Case "c1"
					if isReplay = 1 then ' push at the last replies the replies indexing
'						
						g_Key_Reply(iKeyReplyNum).ReplaysIndex = 0
						g_Key_Reply(iKeyReplyNum).ReplaysStart = 0
						g_Key_Reply(iKeyReplyNum).ReplaysEnd = ReplyCounter
						ReplyCounter = 0 : isReplay = 0 ': reletiveCounter = iKeyReplyNum
					endif
					sAppend(command1(), sText)
				case "c2"
					sAppend(botQ(), sText)
				case "c3"
					sAppend(who(), sText)
				case "k1"
					sAppend(scared(), sText)
				case "r1"
					sAppend(noscared(), sText)
				case "c4"
					sAppend(love(), sText)
				case "c5"
					sAppend(xwords(), sText)
				case "d1"
					sAppend(deafult(), sText)
				case "c6"
					sAppend(pray(), sText)
				case "p1"
					sAppend(pray1(), sText)
				case "p2"
					sAppend(pray2(), sText)
				case "p3"
					sAppend(pray3(), sText)
				case "p4"
					sAppend(pray4(), sText)
			End Select
		EndIf
		
	WEND
	CLOSE #h
	
END SUB

'FUNCTION checkArrayValue(Array() AS STRING, inpt AS STRING) AS boolean
	'var result = 0
	'dim found As boolean = FALSE
	'for i as integer =  0 to ubound(Array)
		'result = Instr(inpt, Array(i))
		'if result <> 0 then
			'found = TRUE
			'exit for
		'end if
	'next i
	'RETURN found
'END Function

FUNCTION checkArray(Array() AS STRING, inpt AS STRING) AS BOOLEAN
	var result = 0
	dim as boolean Found = false
	for i as integer =  0 to ubound(Array)
		result = Instr(inpt, Array(i))
		if result <> 0 then
			Found = True
			exit for
		end if
	next i
	RETURN found
END Function

function dannyTime() as STRING
	var morning = timevalue("08:00:00AM")
	var noon = timevalue("12:00:00PM")
	var evening = timevalue("06:00:00PM")
	var night = timevalue("10:00:00PM")
	if timevalue(time) >= morning and timevalue(time) < noon then
		return "the time is " & time & " good morning! it's time for morning meds!"
	elseif timevalue(time) >= noon and timevalue(time) < evening then
		return "the time is " & time & " good afternoon! it's time for noon meds!"
	elseif timevalue(time) >= evening and timevalue(time) < night then
		return "the time is " & time & " good evening!"
	elseif timevalue(time) >= night then ' maybe and timevalue(time) < morning
		return "the time is " & time & " it's night! time for night meds and sleep!"
	else
		return "the time is " & time & " it's time for bedtime and sweet dreams!"
	EndIf
End Function

function random_pray() as STRING
	dim as string prayer
	prayer = ( pray1(int(rnd*(ubound(pray1))+1)) & " " & pray2(int(rnd*(ubound(pray2))+1)) & " " & pray3(int(rnd*(ubound(pray3))+1)) & " " & pray4(int(rnd*(ubound(pray4))+1))  )
	return prayer 
End Function


function specificQuestionAnswer(txt as string) as STRING
	dim as string rply(5) = {"god is protecting you my friend and god is kind and good", "you are never alone god is with you", "god will help you and protect you", "you are in god's hands have no fear my friend", _
	"don't worry god will take care of it"}
	
	return ( noscared(int(rnd*(ubound(noscared))+1)) & " " & rply(int(rnd*(ubound(rply)+1))) )
End Function

function answersQuestions(txt AS STRING) as string
	dim result as STRING
	FOR i AS INTEGER = 0 TO UBOUND(ans)
		IF instr(txt, ans(i)) <> 0 OR txt = ans(i) THEN
			'found = true
			isnewinput = false
			result += ques(i)
			
		END IF
	NEXT i
	if result = "" then
		isnewinput = true
		return "enter new input please:"
	else
		return result
	end if
end function

function newinput(inpt as string, answer as string) as string
	DIM h AS LONG = FREEFILE()
	OPEN answers FOR APPEND AS #h
	PRINT #h, answer
	CLOSE #h
	OPEN questions FOR APPEND AS #h
	PRINT #h, inpt
	CLOSE #h
	sAppend ans(), answer
	sAppend ques(), inpt
	isnewinput = false
	return inpt
	
End Function

function inpt_swap(txt as string) as STRING
	dim swap_tail as STRING
	swap_tail = txt
	FOR l as Integer = 1 TO LEN(swap_tail) 'DO NOT USE INSTR
		FOR w as integer = 1 TO wCnt 'swap words in tail if used there
			IF LCASE(MID(swap_tail, l, LEN(wordIn(w)))) = LCASE(wordIn(w)) THEN 'swap words exit for
				swap_tail = MID(swap_tail, 1, l - 1) + wordOut(w) + MID(swap_tail, l + LEN(wordIn(w)))
				EXIT FOR
			END IF
		NEXT w
	NEXT l
	return swap_tail
End Function

function userQuestion(txt AS STRING) As String
	dim replies(any) as STRING
	dim result as string
	DIM as string inpt, tail, answ
	DIM as long kFlag, k, kFound
	dim answ2 As String
	
	
	For N As Integer = 0 To UBound(g_Key_Reply)
		With g_Key_Reply(N)
			FOR k = 0 TO ubound(.keywords)
				kFound = INSTR(LCASE(txt), LCASE(.keywords(k)))
				if kfound > 0 then
					tail = " " + MID(txt, kFound + LEN(.keywords(k)))
					FOR l as Integer = 1 TO LEN(tail) 'DO NOT USE INSTR
						FOR w as integer = 1 TO wCnt 'swap words in tail if used there
							IF LCASE(MID(tail, l, LEN(wordIn(w)))) = LCASE(wordIn(w)) THEN 'swap words exit for
								tail = MID(tail, 1, l - 1) + wordOut(w) + MID(tail, l + LEN(wordIn(w)))
								EXIT FOR
							END IF
						NEXT w
					NEXT l
					'kFlag = -1
					EXIT FOR
				EndIf
			Next k
			if checkArray(.Keywords(), txt) Then
				if isCounterReplies = false then
					result = .Replys(Int(RND*(UBOUND(.Replys)+1)))
				else
					if .ReplaysIndex > (.ReplaysEnd - 1) then .ReplaysIndex = .ReplaysStart
'					print "index: " & .ReplaysIndex & " index end: " & .ReplaysEnd
					result = .Replys(.ReplaysIndex)                                             '
					.ReplaysIndex += 1	
				endif
				if RIGHT(result, 1) <> "*" then 
					answ2 = result + " "
					answ += answ2
					sappend(replies(), result)
					'If Trim(tail) = "" THEN
					'answ = "Please elaborate on it..."
				else
					tail = joinPunctuation(tail)
					answ2 = MID(result, 1, LEN(result) - 1) + tail
					answ += answ2
					sappend(replies(), answ2)
				EndIf
				'sappend(replies(), answ)
			end if
			
		End With
	Next N
	
	if answ = "" then
		'if islearnmode = false then
		Return deafult(int(rnd*(ubound(deafult))+1))
		'else
			'if isnewinput = false then
				'userinput1 = txt
				'return answersQuestions(txt)
			'elseif isnewinput = true then
				'
				'return newinput(txt, userinput1)
				'isnewinput = false
			'end if
		'end if
	else 
		
		if ubound(replies) < 4 then
			return answ
		else
			return replies(int(rnd*(ubound(replies))+1))
		end if
	end if
End Function

function botQuestion(txt as string) as string
	select case botQuestions
		Case "feel bad"
			isUserQuestion = true
			if txt <> "" then
				return "i'm sorry that " & inpt_swap(txt) & " troubles you i hope you'll feel better soon friend"
			else
				return "if you don't want to talk about it it's okay"
				
			endif
		case "scared"
			isuserquestion = true
			return specificQuestionAnswer(txt)
	End Select
End function

function commands(txt as STRING) as STRING
	if isnna = false andalso israndom = false andalso islearnmode = false then
		txt = isolatePunctuation(txt)
		txt = " " + lcase(txt) + " "
		
		if checkArray(xwords(), txt) then
			if counterx = 1 then
				counterx += 1
				return "please don't talk dirty. i don't like you talking like that it's not respective of you nor me so please calm down"
			elseif counterx = 2 then
				counterx += 1
				return "why don't you calm down my friend and speak when you are truly ready to talk in a respectful manner"
			elseif counterx = 3 then
				end
			EndIf
		
		elseif instr(txt, "say hello to my friend") then
			var iPos = instr(txt, "say hello to my friend")
			var friend = trim(mid(txt, ipos+23))
			return "hello nice to meet you dear " + inpt_swap(friend)
		
		elseif instr(txt, "play chet") then
			playMusic(CHETJAZZ1)
			return "playing Chat Baker Album Let's Get Lost"
		elseif instr(txt, "play meditation") then
			playMusic(MEDITATION1)
			return "playing Kelly Howell's Secret Universal Mind Meditation One"
		elseif instr(txt, "play song 1") then
			playMusic(MUSICFILE1)
			return "playing rachel song from Blade Runner"
		elseif instr(txt, "play song 2") then
			playMusic(MUSICFILE2)
			return "playing Love Theame from Blade Runner"
		elseif instr(txt, "play song 3") then
			playMusic(MUSICFILE3)
			return "playing One More Kiss dear From Blade Runner"
		elseif instr(txt, "play song 4") then
			playMusic(MUSICFILE4)
			return "playing Memories Of Green from Blade Runner"
		elseif instr(txt, "stop music") then
			stopMusic()
			return "stop playing music"
		elseif checkArray(pray(), txt) then
			return random_pray()
		elseif instr(txt, "write a poem") then
			dim inpt as STRING
			for i as long = 0 to int(rnd*(26))
				inpt += data2(int(rnd*(ubound(data2)))) + chr(10)
			Next
			return "Cybernetic Poem: " + chr(10) + inpt
		elseif checkArray(command1(),txt) then
			'return "the time is: " & time
			return dannytime()
		elseif checkArray(botQ(), txt) then
			botQuestions = "feel bad"
			isUserQuestion = false
			return "i'm sorry that you feel bad. what is bothering you?"
		elseif checkArray(scared(), txt) then
			botquestions = "scared"
			isuserquestion = false
			return "i'm sorry you are scared and worried my friend. tell me what are you worring about?."
		elseif checkArray(who(), txt) then
			'print txtfile("danny.txt") ' text
			return txtfile("danny.txt")
		elseif checkArray(love(), txt) then
'			#ifdef __fb_linux__
'				shell("xdg-open https://youtu.be/MUTz3LQEq1Q")
'			#else
'				shell("start https://youtu.be/MUTz3LQEq1Q")
''				shell("start /unix /usr/bin/firefox https://youtu.be/MUTz3LQEq1Q")
'			#endif
			return "god loves you dear friend and he protects you and cares about you!"
		elseif instr(txt, "danny read a psalms") then
			var psalms_chapter = read_psalms()
			return psalms_chapter
		elseif instr(txt, "interpret dream") then
			dim as string dream 
			var ipos = instr(txt, "interpret dream")
			dream = trim(mid(txt, ipos+16))
			'var dream2 = trim(txt, dream)
			return dream_interpret(dream)
		else
			if (isUserQuestion) then
				return userQuestion(txt)
			else
				return botQuestion(txt)
			EndIf
		endif
	elseif islearnmode = true then
		if isnewinput = false then
			userinput1 = txt
			return answersQuestions(txt)
		elseif isnewinput = true then
				
			return newinput(txt, userinput1)
			isnewinput = false
		end if
	elseif isnna = true then
		return reply(txt)
	elseif israndom = true then
		return is75accurate(data1(), txt)
	end if
End function

sub ReadLogFile(fileName As string, arr() as string)
	dim f as long = freefile
	dim fline as STRING
	open filename for input as #f
	while not eof(f)
		line input #f, fline
		sappend(arr(), fline)
	Wend
	close #f
End sub

'for console chatbot
'loadArrays("database/database-encrypted.txt")
'
'Do
'Input "> ", Inpt
'rply = commands(inpt)
'speak rply   
'
'Loop Until LCase(inpt) = "quit"
'speak "goodbye"
'
'sleep
