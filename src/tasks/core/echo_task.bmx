' ------------------------------------------------------------------------------
' -- src/tasks/core/echo_task.bmx
' --
' -- Write text to the console or a file.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../../util/console_util.bmx"
Import "../../core/exceptions.bmx"

Import "../build_task.bmx"

''' <summary>Writes something to the console.</summary>
Type EchoTask Extends BuildTask

	Field message:String                    '''< The message to output.
	Field file:String                       '''< [optional] A filename to write this message to.
	Field append:Byte                       '''< [optional] If true, will append to file.

	Method execute()
		' Check if writing to a file or console
		If Self.file = "" Then
			Self._echoToConsole()
		Else
			Self._echoToFile()
		EndIf
	End Method


	' ------------------------------------------------------------
	' -- Console output
	' ------------------------------------------------------------

	''' <summary>Output to the console.</summary>
	Method _echoToConsole()
		ConsoleUtil.PrintC(message)
	End Method


	' ------------------------------------------------------------
	' -- File output
	' ------------------------------------------------------------

	Method _echoToFile()

		Local fileOut:TStream

		' -- Open the file to write
		If Self.append = True Then
			If FileType(Self.file) <> FILETYPE_FILE Then
				Throw FileLoadException.Create("Could not open file '" + Self.file + "'")
			EndIf
			fileOut = OpenFile(Self.file)
		Else
			fileOut = WriteFile(Self.file)
		EndIf

		' Check
		If fileOut = Null Then
			Throw FileLoadException.Create("Error in opening log file '" + Self.file + "'")
		EndIf

		' Write
		fileOut.WriteLine(Self.message)

		' Cleanup
		fileOut.Close()

	End Method

End Type
