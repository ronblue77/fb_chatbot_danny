'ORIGINAL CODE BY BPLUS FROM QB64 FORUM!

'_TITLE "RACHEL CHATBOT V1.2R" ' B+ started 2019-05-26  post loadArrays test on Script Eliza.txt file
'2019-05-29 post basic getReply$ function of Eliza / Script Player
'2019-05-30 LINE INPUT to allow commas, try isolatePunctuation$ and joinPunction, look like it's working.
'2019-05-31 OK it all seems to be working without all caps and with punctuation.
'2019-06-21 mod by ron77 for Rachel chatbot prototype added TTS with voice.exe TTS command line
'2020-04-01 mod and converted by ron77 to FB #lang"qb"
'2020-04-03 converted to standard FB DIalect - Imortis
'2020-04-09 converted to use disphelper

'#INCLUDE ONCE "SAPI.bi"

CONST punctuation = "?!,.:;<>(){}[]"
DIM SHARED as String Greeting, You, Script
DIM SHARED as long kCnt, rCnt, wCnt2, NoKeyFoundIndex
REDIM SHARED as String keywords(0), replies(0), wordIn(0), wordOut(0)
REDIM SHARED as Long rStarts(0), rEnds(0), rIndex(0)
'const file = "log.txt"

'open file for append as #1
'close #1

'sub writefile2(text as string)
	'dim f as long = freefile()
	'open file for append as #f
	'print #f , text
	'close #f
'End Sub

'append to the string array the string item
SUB sAppend3 (arr() AS STRING, item AS STRING)
	REDIM Preserve arr(LBOUND(arr) TO UBOUND(arr) + 1) AS STRING
	arr(UBOUND(arr)) = item
END SUB

'append to the integer array the integer item
SUB nAppend (arr() AS long, item AS long)
	REDIM Preserve arr(LBOUND(arr) TO UBOUND(arr) + 1) AS long
	arr(UBOUND(arr)) = item
END SUB

' pull data out of some script file
SUB LoadArrays_eliza(scriptFile AS STRING)
	DIM as long startR, endR, ReadingR, temp
	DIM as string fline, kWord
	dim f as long = freefile
	OPEN scriptFile FOR INPUT AS #f
	WHILE Not EOF(f)
		LINE INPUT #1, fline
		SELECT CASE LEFT(fline, 2)
			CASE "g:": Greeting = Trim(MID(fline, 3))
			CASE "y:": You = Trim(MID(fline, 3))
			CASE "c:": Script = Trim(MID(fline, 3))
			CASE "s:"
				wCnt2 = wCnt2 + 1: temp = INSTR(fline, ">")
				IF temp THEN
					sAppend3 wordIn(), " " + Trim(MID(fline, 3, temp - 3)) + " "
					sAppend3 wordOut(), " " + Trim(MID(fline, temp + 1)) + " "
				END IF
			CASE "r:"
				rCnt = rCnt + 1
				sAppend3 replies(), Trim(MID(fline, 3))
				IF NOT ReadingR THEN
					ReadingR = -1
					startR = rCnt
				END IF
			CASE "k:"
				IF ReadingR THEN
					endR = rCnt
					ReadingR = 0
				END IF
				IF rCnt THEN
					kCnt = kCnt + 1
					kWord = Trim(MID(fline, 3))
					sAppend3 keywords(), " " + kWord + " "
					nAppend rStarts(), startR
					nAppend rIndex(), startR
					nAppend rEnds(), endR
					IF kWord = "nokeyfound" THEN NoKeyFoundIndex = kCnt
				END IF
			CASE "e:": EXIT WHILE
		END SELECT
	WEND
	CLOSE #f
	IF ReadingR THEN 'handle last bits
		endR = rCnt
		kCnt = kCnt + 1
		sAppend3 keywords(), "nokeyfound"
		nAppend rStarts(), startR
		nAppend rIndex(), startR
		nAppend rEnds(), endR
		NoKeyFoundIndex = kCnt
	END IF
END SUB


FUNCTION isolatePunctuation2 (s AS STRING) as string
	'isolate punctuation so when we look for key words they don't interfere
	DIM as string b
	b = ""
	FOR i as integer = 1 TO LEN(s)
		IF INSTR(punctuation, MID(s, i, 1)) > 0 THEN b = b + " " + MID(s, i, 1) + " " ELSE b = b + MID(s, i, 1)
	NEXT
	isolatePunctuation2 = b
END FUNCTION

FUNCTION joinPunctuation2 (s AS STRING) as String
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
	joinPunctuation2 = b
END Function

' =============================== here is the heart of ELIZA / Player function
FUNCTION GetReply (text As string) as string
	DIM as string inpt, tail, answ
	DIM as long kFlag, k, kFound
	'locate 37
	' USER INPUT SECTION
	inpt = text
	'PRINT You + ": ";: LINE INPUT "", inpt
	'IF LCASE(inpt) = "q" OR LCASE(inpt) = "x" OR LCASE(inpt) = "goodbye" OR LCASE(inpt) = "good night" OR LCASE(inpt) = "bye" THEN
	'	GetReply = "Goodbye!": EXIT FUNCTION
	'END IF
	'writefile2(you + ": "+ inpt)
	inpt = " " + inpt + " " '<< need this because keywords embedded in spaces to ID whole words only
	inpt = isolatePunctuation2(inpt)
	FOR k = 1 TO kCnt 'loop through key words until we find a match
		kFound = INSTR(LCASE(inpt), LCASE(keywords(k)))
		IF kFound > 0 THEN '>>> need the following for * in some replies
			tail = " " + MID(inpt, kFound + LEN(keywords(k)))
			FOR l as Integer = 1 TO LEN(tail) 'DO NOT USE INSTR
				FOR w as integer = 1 TO wCnt2 'swap words in tail if used there
					IF LCASE(MID(tail, l, LEN(wordIn(w)))) = LCASE(wordIn(w)) THEN 'swap words exit for
						tail = MID(tail, 1, l - 1) + wordOut(w) + MID(tail, l + LEN(wordIn(w)))
						EXIT FOR
					END IF
				NEXT w
			NEXT l
			kFlag = -1
			EXIT FOR
		END IF
	NEXT
	IF kFlag = 0 THEN k = NoKeyFoundIndex
	answ = replies(INT((rEnds(k) - rStarts(k) + 1) * RND) + rStarts(k))
	'set pointer to next reply in rIndex array
	IF k = NoKeyFoundIndex THEN 'let's not get too predictable for most used set of replies
		rIndex(k) = INT((rEnds(k) - rStarts(k) + 1) * RND) + rStarts(k)
		'ELSE
		'   rIndex(k) = rIndex(k) + 1 'set next reply index then check it
		'   IF rIndex(k) > rEnds(k) THEN rIndex(k) = rStarts(k)
	END IF
	IF RIGHT(answ, 1) <> "*" THEN GetReply = answ: EXIT FUNCTION 'oh so the * signal an append to reply!
	If Trim(tail) = "" THEN
		GetReply = "Please elaborate on, " + keywords(k)
	ELSE
		tail = joinPunctuation2(tail)
		GetReply = MID(answ, 1, LEN(answ) - 1) + tail
	END IF
END FUNCTION



'function speakTotext (lines as string) As String 'uses voice command line voice.exe
	''locate 37
	''print Script + ": " + lines: PRINT
	''shell("espeak-ng -s 120 " + chr(34) + lines + chr(34))
	''   Speak(lines, SVSFlagsAsync)
	''   SAPI_WaitUntilDone()
	'writefile2(script +": " +lines)
	'Return Script + ": " + lines: Print
'END function

'screen 19, 32
'Color RGB(255, 128, 0), RGB(0, 0, 64): cls
'view print 1 to 37
'DIM rply AS STRING '              for main loop

'If SAPI_Init() = False Then
'   PRINT "Unable to initialize SAPI!"
'   Sleep
'   End
'else
'   SAPI_SetVolume(100)
'   SAPI_SetFemaleVoice()
'end if
'randomize ' DON'T FOR GET TO COMMENT THIS!!!
LoadArrays_eliza("database/eliza_script.txt") '   check file load, OK checks out
'speakTotext(Greeting)
'start testing main Eliza code
'DO
'	
'	rply = GetReply
'	PRINT: speakTotext(rply)
'LOOP UNTIL rply = "Goodbye!"

'========================================================================

'randomize ' DON'T FOR GET TO COMMENT THIS!!!
'LoadArrays_eliza("database/eliza_script.txt")

'dim text as string, answer as STRING

'	input "", text
'    answer = GetReply(text)
'    print answer
	
''sleep