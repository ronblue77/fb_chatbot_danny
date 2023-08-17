
const database = "database/dream-database.txt"

type dreams
	topicName as STRING
	redim description(any) as STRING
	redim positive(any) as STRING
	redim negavite(any) as STRING
	verse as STRING
End Type	

redim shared dictionary(any) as dreams

function Split(Text As String, Delim As String = " ", Count As Long = (1 shl 31)-1, Ret() As string) as long
	if Count<0 then Count = (1 shl 31)-1 'max possible
	if Count=0 then erase ret: return 0
	
	dim as long iStart = 1
	for N as long = 0 to Count-1
		redim preserve Ret(N) as string
		var iFound = instr( iStart , Text , Delim )
		if iFound=0 then Ret(N) = mid(Text,iStart): return N+1
		Ret(N) = mid(Text,iStart,(iFound-iStart))
		if iFound=iStart then N -= 1
		iStart = iFound+len(Delim)
	next N 
	return Count
End function

sub loadArrays_dreams(filename as string)
	var f = freefile()
	dim as string fline
	dim as string sName
	
	open filename for input as #f
	Dim As Integer IsNewTopic=0,iTopicNum=-1
	while not eof(f)
		line input #f, fline
		Var iPosi = InStr(fline,":")
		Var sText = TRIM(MID(fline, iPosi+1))
		If iPosi = 2 Then 'check for 1 chracter entries
			Select Case fline[0]
				Case asc("t")
					
					if sName <> sText then
						
						iTopicNum +=1
						redim preserve dictionary(iTopicNum)
					end if
					dictionary(iTopicNum).topicName = sText
					sName = dictionary(iTopicNum).topicName
					'if sname <> sText then isNewTopic = 0
				case asc("d")
					Split(sText, , ,dictionary(iTopicNum).description())
				case asc("p")
					split(sText,,,dictionary(iTopicNum).positive())
				case asc("n")
					split(sText,,,dictionary(iTopicNum).negavite())
				case asc("v")
					dictionary(iTopicNum).verse = sText
			End Select
		EndIf
	Wend
End Sub

const MinimumWordSize = 3

'so i was in forest and there was water but i couldnt see the sky i dont know if it was dark or if i was blind but i could hear things and later i only could see a rainbow

function stringComparsion( inptArray() as string, word as string) as long
	var score = 0 , lenword = len((word))
	dim as byte uChar(255)
	for n as integer = 0 to lenword-1 : uChar( word[n] ) = 1 : Next
	
	for i as integer = 0 to ubound(inptArray)
		var inptWord = inptArray(i) , leninptWord = len(inptWord)		
		'1 point for each matchin letter
		for n as integer = 0 to leninptWord-1 
			 if uChar( inptWord[n] ) then score += 1
		Next
		for n as integer = 0 to iif( leninptWord < lenword , leninptWord , lenword )-1
			if inptWord[n] = word[n] then score += 2
		Next
		for n as integer = 2 to len(inptWord)
			for m as integer = 1 to Len(inptWord)-n
				if uChar( inptWord[m-1] ) then
					if instr(" "+word+" ",mid(inptWord,m,n)) then score += (n*n)
				EndIf
			Next
		Next
	Next
	return score
End Function


FUNCTION processInput(Array() AS dreams, inpt AS STRING) AS dreams
	dim as integer index = -1	
	redim wordList(any) as string 	
	var topscore = 0 , result = 0 , inptL = lcase(inpt)	
	split(inptL,,,wordList()) 
	inptL = " "+inptL+" "
	
	print "<"+inptL+">"
	for i as integer =  0 to ubound(Array)
		
		var score = 0
		
		#macro CheckArray( _name )
			for n as integer = 0 to ubound(array(i)._name)			
				if len(Array(i)._name(n)) >= MinimumWordSize then
					score += stringComparsion( wordList() , lcase(Array(i)._name(n)) )
				EndIf
			Next
		#EndMacro
		score += stringComparsion( wordList() , lcase(Array(i).topicName))*2
		'CheckArray( description )
		'CheckArray( negative )
		'CheckArray( positive )
		if instr( inptL , lcase(Array(i).topicName) ) then score *= 2
		
		'if wordcount then print "match words: " & wordcount & "(prev=" & topwords & ")"
		if score > topscore then 
			print "topscore: "+array(i).topicName+" (" & score & ")"
			index = i  : topscore = score		
		EndIf
		
	next i
	if index <> -1 then
		return array(index)
	else 
		dim empty as DREAMS
		return empty
	End If
END Function

loadArrays_dreams(database)

function dream_interpret(txt as string) as string
	'var txt2 = trim(txt, "tell me what this dream means ")
	'print txt2
	dim as integer i
	dim msg as STRING
	var des = "" , positive = "", negative =""
	Var ans = processInput(dictionary(),txt)
	for i = 0 to ubound(ans.description)
	des+= ans.description(i)+" "
	Next
	print
	for i = 0 to ubound(ans.positive)
		positive+= ans.positive(i)+" "
	Next
	print
	for i = 0 to ubound(ans.negavite)
		 negative += ans.negavite(i)+" "
	Next
	msg = "Your Dream Is: " + txt + " Dream Symbol Is: " +ans.topicName +" Symbol Description is: " + des +" Positive interpretation is: " + positive +_
	" Negative interpretation is: " + Negative +" Verses from The Bible: " + ans.verse
	return msg
End Function