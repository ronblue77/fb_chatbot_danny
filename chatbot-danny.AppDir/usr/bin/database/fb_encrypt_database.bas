' FB 1.05.0 Win64
Screen 19 
' uses same alphabet and key as Ada language example
Const string1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
Const string2 = "VsciBjedgrzyHalvXZKtUPumGfIwJxqOCFRApnDhQWobLkESYMTN"
 
Sub process(inputFile As String, outputFile As String, encrypt As Boolean)
   Open inputFile For Input As #1
   If err > 0 Then
     Print "Unable to open input file"
     Sleep
     End
   End If
   Dim As String alpha, key 
   If encrypt Then
     alpha = string1 : key = string2
   Else
     alpha = string2 : key = string1
   End If     
   Open outputFile For Output As #2
   Dim s As String
   Dim p As Integer
   While Not Eof(1)
     Line Input #1, s
     For i As Integer = 0 To Len(s) - 1  
       If (s[i] >= 65 AndAlso s[i] <= 90) OrElse (s[i] >= 97 AndAlso s[i] <= 122) Then
         p =  Instr(alpha, Mid(s, i + 1, 1)) - 1
         s[i] = key[p]         
       End If      
     Next 
     Print #2, s
   Wend
   Close #1 : Close #2
End Sub
 
process "database.txt", "database-encrypted.txt", true
'process "encrypted.txt", "decrypted.txt", false
Print
Print "Press any key to quit"
Sleep