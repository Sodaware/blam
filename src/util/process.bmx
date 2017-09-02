' ------------------------------------------------------------------------------
' -- src/util/process.bmx
' --
' -- Extends TProcess with some os-specific changes.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Import pub.freeprocess


Type TProc Extends TProcess

	' ------------------------------------------------------------
	' -- Process Management
	' ------------------------------------------------------------

	Method close:Int()
		Super.close()
		Self.terminate()
	End Method

	Method avail:Int()
		Return err.bufferpos Or err.readavail() Or pipe.bufferpos Or pipe.readavail()
	End Method


	' ------------------------------------------------------------
	' -- Reading Content
	' ------------------------------------------------------------

	Method read:String()
		If err.bufferpos > 0 Or err.readavail() > 0 Then
			Return Self.cleanLine(err.ReadLine())
		EndIf
		If pipe.bufferpos > 0 Or pipe.readavail() > 0 then
			Return Self.cleanLine(pipe.ReadLine())
		EndIf
	End Method

	Method readPipe:String()
		If pipe.bufferpos > 0 Or pipe.readavail() > 0 Then
			Return Self.cleanLine(pipe.ReadLine())
		EndIf
	End Method

	Method readErr:String()
		If err.bufferpos > 0 Or err.readavail() > 0 Then
			Return Self.cleanLine(err.ReadLine())
		EndIf
	End Method

	Method pipeAvail:Int()
		Return pipe.bufferpos Or pipe.readavail()
	End Method

	Method errAvail:Int()
		Return err.bufferpos Or err.readavail()
	End Method

	Method endOfFile:Byte()
		If status() = 1 Then Return False
		If pipe.readavail() > 0 Then Return False
		If err.readavail() > 0 Then Return False
		If pipe.bufferpos > 0 Then Return False
		If err.bufferpos > 0 Then Return False
		Return True
	End Method

	''' <summary>Remove newlines from a string.</summary>
	Method cleanLine:String(line:String)
		Return line.Replace("~r", "").Replace("~n", "")
	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Function Create:TProc(command:String, flags:Int)

		Local infd:Int
		Local outfd:Int
		Local errfd:Int

		' MacOS only path helper
		?MacOs
		If FILETYPE_DIR = FileType(command) Then
			command :+ "/Contents/MacOS/" + StripExt(StripDir(command))
		EndIf
		?

		' Create the new process and setup
		Local temp_proc:TProc = New TProc
		temp_proc.name = command

		' Attempt to start the process
		temp_proc.handle = fdProcess(command, Varptr(infd), Varptr(outfd), Varptr(errfd), flags)
		If Not(temp_proc.handle) Then Return Null

		' Create pipes
		temp_proc.pipe = TPipeStream.Create(infd, outfd)
		temp_proc.err = TPipeStream.Create(errfd, 0)

		' Add this process to the global BlitzMax process list
		If Not(ProcessList) Then
			ProcessList = New TList
		EndIf
		ProcessList.AddLast(temp_proc)

		Return temp_proc
	End Function

End Type

Function CreateProc:tproc(ncmd:String,nhidden:Int = True)
	Return TProc.Create(ncmd, nhidden)
End Function
