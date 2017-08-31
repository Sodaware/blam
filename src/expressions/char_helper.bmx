' ------------------------------------------------------------------------------
' -- src/expressions/char_helper.bmx
' --
' -- Helper functions working with characters. Used by the expression parser.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type CharHelper 

	Function IsLetterOrDigit:Int(char$)
		
		Return CharHelper.IsLetter(char) Or CharHelper.isdigit(char)
		
	End Function
	
	Function IsWhitespace%(char$)
		
		If Asc(char) < 33 Or Asc(char) >= 127 Or char="" Then Return True
		
	End Function
	
	Function IsDigit%(char$)
		
		If Asc(char) >= 48 And Asc(char) =< 57 Then Return True
		
	End Function
	
	Function IsLetter:Int(char$)
		
		Local charValue%	= Asc(char)
		
		If (charValue >= 65 And charValue <= 90) Or (charValue >= 97 And charValue =< 122) Then Return True
		
	End Function

End Type
