' ------------------------------------------------------------------------------
' -- src/errors/compiler_error.bmx
' --
' -- A generic error raised during compilation.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type CompilerError

	Field File:String
	Field Line:Int
	Field Column:Int
	Field Message:String
	
	Method toString:String()
		Return "Error in file ~q" + Self.File + "~q (Line " + Self.Line + ", Column " + Self.Column + ")" ..
			+ "~n" + Self.Message
	End Method
	
End Type
