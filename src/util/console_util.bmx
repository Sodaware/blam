' ------------------------------------------------------------------------------
' -- src/util/console_util.bmx
' --
' -- Helper functions for working with the console, formatting notices and
' -- managing indentation.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

import brl.retro
import sodaware.console_color

Type ConsoleUtil

	Global currentIndent:Int	= 1
	Global TabSize:int			= 4
	Global currentTask:String	= ""
	
	Function PrintC(text:string)
		sodaware.Console_Color.PrintC(ConsoleUtil._makeString(text))
	End Function

	Function WriteC(text:string)
		sodaware.Console_Color.WriteC(ConsoleUtil._makeString(text))
	End Function
	
	Function _makeString:String(text:String)
		Local output:String = RSet(" ", ConsoleUtil.currentIndent * ConsoleUtil.TabSize)
		If ConsoleUtil.currentTask Then output:+ RSet("[" + ConsoleUtil.currentTask + "]", 12) + " "
		Return output + text
	End Function
	
	Function increaseIndent()
		currentIndent:+ 1
	End Function

	Function decreaseIndent()
		currentIndent:- 1
		if currentIndent < 0 then currentIndent = 0
	End Function
	
End Type
