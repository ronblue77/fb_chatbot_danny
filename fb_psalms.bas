type chapter
	redim verse(any) as string
End Type

sub sAppend_psalms(arr() as string , temp as string)
	redim preserve arr((lbound(arr)) to (ubound(arr) + 1))
	arr(ubound(arr)) = temp
End Sub

sub LoadArrays_psalms(filename as string, psalms2() as CHAPTER)
	dim f as long = FREEFILE
	dim fline as STRING
	dim index as long = 1
	dim counter as long = -1
	open filename for input as #f
	while not eof(f)
		line input #f, fline
		var tag = instr(fline, ":")
		var sText = TRIM(MID(fline, tag+1))
		var start = mid(fline, 1, tag)
		if val(start) = index THEN
			counter +=1
			index += 1
			redim preserve psalms2(counter)
		EndIf
		sAppend_psalms(psalms2(counter).verse(), sText)
	Wend
	
End Sub

dim shared psalms() as CHAPTER
randomize
LoadArrays_psalms("database/psalms.txt", psalms())

function read_psalms() as STRING
	dim as long index
	index = int(rnd*(ubound(psalms)+1))
	dim praise as string
	for i as long = 0 to ubound(psalms(index).verse)
		praise += psalms(index).verse(i) + " "
	Next
	return "Chapter " & (index+1) & " From Psalms book: " & praise
End Function

