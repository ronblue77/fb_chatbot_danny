CONST answersFile = "answers.txt"
CONST questionsFile = "questions.txt"
const logfile = "log.txt"
dim shared as string answers, questions
dim shared as string file

answers = curdir()+"/"+answersFile
questions = curdir()+"/"+questionsFile
'log file goes on current folder
file = curdir()+"/"+logfile

chdir exepath()

redim shared as string data1(any)


sub sAppend(arr() as string , temp as string)
	redim preserve arr((lbound(arr)) to (ubound(arr) + 1))
	arr(ubound(arr)) = temp
End Sub

sub ParseSentence( arr() as string , sSentence as string )	
	dim currentCaracter as ubyte
	dim WordSize as long
	if len(sSentence) <= 0 then exit sub
	for i as long = 0 to len(sSentence) 'reaches the \0 at the end
		'less slower with ascii :)
    currentCaracter = sSentence[i] 'mid(arr(iCount), i, 1)
		select case as const currentCaracter			
    case asc("A") to asc("Z"),asc("a") to asc("z")       'characteres anywhere on the word
      WordSize += 1
    case asc("0") to asc("9"),asc("-"),asc("_"),asc("'") 'cant start with those
      if WordSize then WordSize += 1       
    case else 'case asc(" "),0
      if WordSize > 1 then
        var sWord = mid(sSentence, (i-WordSize)+1, WordSize)       
        sAppend( arr() , sWord )
      endif
      wordSize=0     
		end select		
	next i
end sub

function is75accurate(arr1() as string, sen as string) as STRING
	
	'arr1 = array with sentences
	'arr2 = question parsed
	'arr3 = 
	'dim result as string
	dim ques as STRING	
	dim index as long 
	
	redim result(any) as STRING
	redim arr2() as string		
	ParseSentence(arr2(), sen)
	
    
	
	for index = lbound(arr1) to ubound(arr1)
		
		ques = arr1(index)
		
		redim arr3() as string
		ParseSentence(arr3(), ques)
		dim fitCount as long
		
		for i as long = 0 to ubound(arr2)
			for k as long = 0 to ubound(arr3)		
				if arr2(i) = arr3(k) then fitCount +=1 
			next k
		next i
			
		dim as long scop = ((ubound(arr3)+1) * 0.75)				
		'print scop, fitCount, index				
		if scop>0 andalso fitCount >= scop then sAppend(result(), arr1(index+1))  'return arr1(index +1) 'ques		
		
		
		
	next
	if result(0) ="" then 
		return "no reply found! please try again!"
	else
		return result(int(rnd*(ubound(result)+1)))
	end if
End Function

dim fline as string
dim ff as long = freefile()

chdir exepath()

open "database/dataset_clean.txt" for input as #ff
	while not eof(ff)
		line input #ff, fline
		sAppend(data1(), fline)
	Wend
close #ff

'print ubound(data1)


'dim ans as STRING
'
'do
	'input "you: ", ans
	'print "bot: " & is75accurate(data1(), ans)
	'
'Loop until ans = "quit"