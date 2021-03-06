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

	Function IsLetterOrDigit:Byte(character:String)
		Return CharHelper.IsLetter(character) Or CharHelper.isdigit(character)
	End Function
	
	Function IsWhitespace:Byte(character:String)
		Return ( Asc(character) < 33 Or Asc(character) >= 127 Or character = "" )
	End Function
	
	Function IsDigit:Byte(character:String)
		Return ( Asc(character) >= 48 And Asc(character) =< 57 )
	End Function
	
	Function IsLetter:Int(character:String)
		Local charValue:Byte = Asc(character)
		Return (charValue >= 65 And charValue <= 90) Or (charValue >= 97 And charValue =< 122)
	End Function

End Type
