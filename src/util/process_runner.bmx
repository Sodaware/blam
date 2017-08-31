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
	
	field m_Process:TProc
	field m_TimeoutLimit:Int
	field m_CurrentTimeout:int
	
	field m_Delta:int
	Field m_StartTime:Int
	
	Field m_LineIn:String
	Field m_ErrorIn:String
	
	method running:int()
		return not(self.m_Process.Eof())
	End Method
	
	Method getNextLine:String()
		self.update(0)
		return self.getLine()
	End Method
	
	Method getLine:String()
		Return Self.m_LineIn
	End Method
	
	Method getError:String()
		Return Self.m_ErrorIn
	End Method
	
	Method update(delayTime:int = 5)
		
		Self.m_LineIn = Self.m_Process.Read()
		If Self.m_LineIn <> "" Then Self.m_CurrentTimeout = 0
			
		Self.m_ErrorIn = Self.m_Process.readerr()
		?debug 
		If Self.m_ErrorIn <> "" Then Print "ERROR: " + Self.m_ErrorIn
		?
		
		
			
		' -- Adding a short delay here stops the app from stalling
		' -- Without this, it takes 5 seconds. With, it takes 0.05
		Delay(delayTime)
			
		' -- Used to check for timeouts			
		self.m_Delta 	= MilliSecs() - self.m_StartTime
		self.m_StartTime = MilliSecs()
			
		self.m_CurrentTimeout:+ self.m_Delta
			
		If self.m_CurrentTimeout > self.m_TimeoutLimit Then 
			Throw "Process timed out"
		EndIf
	End Method
	
	method stop()
		self.m_Process.Close()
	end Method
	
	Function Create:ProcessRunner(command:String, timeout:int = 10000)
		local this:ProcessRunner = new ProcessRunner
		this.m_Process = createproc(command)
		if this.m_Process = null then return null
		
		this.m_TimeoutLimit = timeout
		this.m_StartTime 	= millisecs()
		
		return this
	End Function	
	
	
	''' <summary>Adds quotes to a filename if required.</summary>
	Function GetSafeName:String(fileName:String)
		If Not(fileName.StartsWith("~q")) Then fileName = "~q" + fileName
		If Not(fileName.EndsWith("~q")) Then fileName = fileName + "~q"
		
		Return fileName
	End Function
	
End Type
