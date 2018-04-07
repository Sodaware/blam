' ------------------------------------------------------------------------------
' -- src/functions/date_functions.bmx
' --
' -- Functions for working with dates and times.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.system

Import "function_set.bmx"

Type DateFunctions Extends FunctionSet

	' ------------------------------------------------------------
	' -- Date Functions
	' ------------------------------------------------------------

	''' <summary>
	''' Get the current date in the form: day month abbreviation and year
	''' </summary>
	Method getCurrentDate:String() { name="date::get-current-date" }
		Return CurrentDate()
	End Method

	Method getCurrentTime:String() { name="date::get-current-time" }
		Return CurrentTime()
	End Method

End Type
