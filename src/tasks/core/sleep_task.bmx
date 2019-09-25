' ------------------------------------------------------------------------------
' -- src/tasks/core/char_helper.bmx
' --
' -- Delays script execution for a user-defined period of time.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../build_task.bmx"

Type SleepTask Extends BuildTask

	Field hours:Int							'''< Number of hours to pause for.
	Field minutes:Int						'''< Number of minutes to pause for.
	Field seconds:Int						'''< Number of seconds to pause for.
	Field milliseconds:Int  = 0             '''< Number of milliseconds to pause for.
	Field verbose:Byte      = False         '''< [optional] Show verbose output.


	' ------------------------------------------------------------
	' -- Task Execution
	' ------------------------------------------------------------

	Method execute()

		' Check ranges
		If hours < 0 Then hours = 0
		If minutes < 0 Then minutes = 0
		If seconds < 0 Then seconds = 0
		If milliseconds < 0 Then milliseconds = 0

		' Calculate delay time
		Local delayTime% = milliseconds

		'; Add hours, minutes & seconds
		delayTime = delayTime + (hours * 60 * 60 * 1000)
		delayTime = delayTime + (minutes * 60 * 1000)
		delayTime = delayTime + (seconds * 1000)

		' Output
		If verbose Then
			Self.Log(..
				"Sleeping for " + hours + " hours, " + minutes + " minutes, " + seconds + " seconds " + ..
				" and " + milliseconds + " milliseconds. " + ..
				"Total time : " + delayTime ..
			)
		Else
			Self.Log("Sleeping for " + delayTime + " milliseconds")
		EndIf

		' -- sleep
		Delay(delayTime)

	End Method

End Type
