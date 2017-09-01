' ------------------------------------------------------------------------------
' -- src/util/process_runner.bmx
' --
' -- Wraps execution of an external process. These are used when running a
' -- compiler or external tool.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "process.bmx"

Type ProcessRunner

	Field _process:TProc
	Field _timeoutLimit:Int
	Field _currentTimeout:Int

	Field _delta:Int
	Field _startTime:Int

	Field _lineIn:String
	Field _errorIn:String

	Method isRunning:Byte()
		Return Not(Self._Process.Eof())
	End Method

	Method getNextLine:String()
		Self.update(0)
		Return Self.getLine()
	End Method

	Method getLine:String()
		Return Self._lineIn
	End Method

	Method getError:String()
		Return Self._errorIn
	End Method

	Method update(delayTime:int = 5)

		Self._lineIn = Self._process.Read()
		If Self._lineIn <> "" Then Self._currentTimeout = 0

		Self._errorIn = Self._process.readerr()
		?debug 
		If Self._errorIn <> "" Then Print "ERROR: " + Self._errorIn
		?

		' -- Adding a short delay here stops the app from stalling
		' -- Without this, it takes 5 seconds. With, it takes 0.05
		Delay(delayTime)

		' -- Used to check for timeouts			
		Self._delta 	= MilliSecs() - Self._startTime
		Self._startTime = MilliSecs()

		Self._currentTimeout:+ Self._delta

		If Self._currentTimeout > Self._timeoutLimit Then 
			Throw "Process timed out"
		EndIf
	End Method

	Method stop()
		Self._process.Close()
	End Method

	Function Create:ProcessRunner(command:String, timeout:int = 10000)
		Local this:ProcessRunner = New ProcessRunner
		this._process = CreateProc(command)
		If this._Process = Null Then Return Null

		this._timeoutLimit = timeout
		this._startTime 	= MilliSecs()

		return this
	End Function	

	''' <summary>Adds quotes to a filename if required.</summary>
	Function GetSafeName:String(fileName:String)
		If Not(fileName.StartsWith("~q")) Then fileName = "~q" + fileName
		If Not(fileName.EndsWith("~q")) Then fileName = fileName + "~q"

		Return fileName
	End Function

End Type
