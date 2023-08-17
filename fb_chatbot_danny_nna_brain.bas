Type WordType
	Txt as string
	Link(256) as WordType ptr
	LinkStrength(256) as integer
	Links as integer
	nex as WordType ptr
	prev as WordType ptr
End Type

dim shared WordType_first as WordType ptr=0

sub AddWordType(WordType as string)
	dim t as WordType ptr=WordType_first

	dim ot as WordType ptr


	do until t=0
		ot=t
		If t->Txt = WordType Then Return 'WordType is already in memory
		t=t->nex
	loop

	dim WWordType as WordType ptr= New WordType
	wWordType->Txt = WordType
	wWordType->Links = 0
	if WordType_first=0 then WordType_first=wWordType else ot->nex=wWordType
End sub

Sub AddLink(WordType as string, linkWordType as string)
	'Get the objects for the WordTypes specified
	dim t as WordType ptr=WordType_first


	do until t=0
		If t->Txt = WordType Then exit do
		t=t->nex
	loop
	If t = 0 Then exit sub
	dim WWordType as WordType ptr=t

	t=WordType_first
	do until t=0
		If t->Txt = linkWordType Then exit do
		t=t->nex
	loop
	If t = 0 Then exit sub
	dim link as WordType ptr=t


	'Does the link exist?
	dim as integer i, exists = 0
	For i = 1 To wWordType->Links
		If wWordType->Link(i) = link Then exists = -1: Exit for
	Next
	
	'If link exists, strengthen it
	If exists = -1 Then
		wWordType->LinkStrength(i) = wWordType->LinkStrength(i) + 1
	End If
	
	'If link does not exist, add it
	If exists = 0 Then
		wWordType->Links = wWordType->Links + 1
		wWordType->Link(wWordType->Links) = link
		wWordType->LinkStrength(wWordType->Links) = 1
	End If
	
End sub

'Weaken all WordType links for the specified WordType. Using "decay" for WordType links allows old unused
'WordTypes (such as mis-spelled WordTypes) to be forgotten.
sub Decay(WordType as WordType ptr)
	For i as integer = 1 To WordType->Links
		WordType->LinkStrength(i) = WordType->LinkStrength(i) - 1
		
		If WordType->LinkStrength(i) = 0 Then
			WordType->LinkStrength(i) = WordType->LinkStrength(WordType->Links)
			WordType->Link(i) = WordType->Link(WordType->Links)
			WordType->Link(WordType->Links) = 0
			WordType->LinkStrength(WordType->Links) = 0
			WordType->Links = WordType->Links - 1
			i = i - 1
		End If
	Next
End sub

'Generate a rely for the given sentance
Function Reply(s as string) as string
	dim WordType(256) as string
	dim as integer WordTypes = 1, count
	dim as string m

	'Split to WordTypes
	For i as integer = 1 To Len(s)
		m = Mid(s, i, 1)
		If m = " " Then
			If WordType(WordTypes) <> "" Then WordTypes = WordTypes + 1
		Else
			If m <> "." And m <> "," And m <> "!" And m <> "?" Then WordType(WordTypes) = WordType(WordTypes) + m
		End If
	Next

	If WordTypes = 1 And WordType(1) = "" Then
		WordTypes = 0
	Else
		WordTypes = WordTypes + 1
		WordType(WordTypes) = "."
	End If
	
	'Remember the WordTypes and their relationships
	For i as integer = 1 To WordTypes
		AddWordType(lcase(WordType(i)))
		If i > 1 Then AddLink(lcase(WordType(i-1)), lcase(WordType(i)))
	Next

	'If nothing is in memory, return blank
	dim t as WordType ptr=WordType_first


	If t = 0 Then Return ""
	
	'Pick a keyWordType for the reply 

	If WordTypes = 0 Then
		'Pick a WordType at random
		count = 0
		do until t=0:t=t->nex: count = count + 1: loop
		dim as integer pick = int(Rnd(1)* count) +1
		t= WordType_first
		For i as integer = 2 To pick
			t = t->nex
		Next
	Else
		'Pick a WordType the user used that has the least links
		dim as integer maxlinks = 100000
		dim as WordType ptr maxWordType=0

		For i as integer = 1 To WordTypes
			dim as string lw = Lcase(WordType(i))
			t =WordType_first


			do until t=0
				If t->Txt = lw Then Exit do
				t=t->nex
			loop
			If t->Links > 0 And t->Links < maxlinks Then maxlinks = t->Links: maxWordType = t
		Next
		t = maxWordType
	End If
	
	'Generate a sentance
	dim as string output1 = "": dim as integer done = 0
	While done = 0
		output1 = output1 + t->Txt + " "
		If t->Txt = "." Then
			done = -1
		Else
			dim as integer pick, pick2 
			pick = int(Rnd(1)* t->Links)+1
			pick2 = int(Rnd(1)* t->Links)+1

			If t->LinkStrength(pick) > t->LinkStrength(pick2) Then t = t->Link(pick) Else t = t->Link(pick2)
		End If
	Wend
	
	'Decay
	If s = "" Then
		'For t.WordType = Each WordType
		'	Decay(t)
		'Next
	End If
	
	Return output1
	
End Function



'do
	'dim x as string
	'input x
	'print reply(x)
'loop