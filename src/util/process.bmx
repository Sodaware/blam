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
	Method close:Int()
		super.close()
		terminate()
	End Method

	Method avail:Int()
		Return err.bufferpos Or err.readavail() Or pipe.bufferpos Or pipe.readavail()
	End Method
	
	Method read:String()
		If err.bufferpos > 0 Or err.readavail() > 0 Return err.ReadLine().Replace("~r","").Replace("~n","")
		If pipe.bufferpos > 0 Or pipe.readavail() > 0 Return pipe.ReadLine().Replace("~r","").Replace("~n","")
	End Method

	Method readpipe:String()
		If pipe.bufferpos > 0 Or pipe.readavail() > 0 Return pipe.ReadLine().Replace("~r","").Replace("~n","")
	End Method
	
	Method readerr:String()
		If err.bufferpos > 0 Or err.readavail() > 0 Return err.ReadLine().Replace("~r","").Replace("~n","")
	End Method
	
	Method pipeavail:Int()
		Return pipe.bufferpos Or pipe.readavail()
	End Method
	
	Method erravail:Int()
		Return err.bufferpos Or err.readavail()
	End Method
	
	Method Eof:Int()
		If status() = 1 Return False
		If pipe.readavail() > 0 Return False
		If err.readavail() > 0 Return False
		If pipe.bufferpos > 0 Return False
		If err.bufferpos > 0 Return False
		Return True
	End Method

	Function Create:TProc(ncmd:String,nflags:Int)
		Local temp_proc:TProc
		Local infd,outfd,errfd	
		
		'do mac speciffic stuff
		?MacOS
		If FileType(ncmd)=2
			ncmd :+ "/Contents/MacOS/" + StripExt(StripDir(ncmd))
		EndIf
		?
		
		'create the proc object
		temp_proc = New TProc
		
		'setup the proc
		temp_proc.name = ncmd
		
		'attempt to start the process
		temp_proc.handle = fdProcess(ncmd,Varptr(infd),Varptr(outfd),Varptr(errfd),nflags)
		If Not temp_proc.handle Return Null
		
		'creat teh process pipes
		temp_proc.pipe = TPipeStream.Create(infd,outfd)
		temp_proc.err = TPipeStream.Create(errfd,0)
		
		'add process to process list
		If Not ProcessList ProcessList = New TList
		ProcessList.AddLast temp_proc
		
		'return the proc object
		Return temp_proc
	End Function
End Type

Function CreateProc:tproc(ncmd:String,nhidden:Int = True)
	Return tproc.create(ncmd,nhidden)
End Function
