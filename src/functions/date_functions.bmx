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

	''' <summary>Get the current date as a string.</summary>
	''' <return>The current date in the form: "day month_abbreviation year".</return>
	Method getCurrentDate:String() { name="date::get-current-date" }
		Return CurrentDate()
	End Method

	''' <summary>Get the current time as a string.</summary>
	''' <return>The current time in the form "hours:minutes:seconds".</return>
	Method getCurrentTime:String() { name="date::get-current-time" }
		Return CurrentTime()
	End Method

End Type
