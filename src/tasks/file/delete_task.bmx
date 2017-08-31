' ------------------------------------------------------------------------------
' -- src/tasks/file/delete_task.bmx
' --
' -- Delete a file, directory or a fileset.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../build_task.bmx"
Import "../../types/fileset.bmx"

Type DeleteTask Extends BuildTask

	Field file:String
	Field dir:String
	Field filesets:TList = New TList
	
	' ------------------------------------------------------------
	' -- Task Execution
	' ------------------------------------------------------------
	
	Method execute()
		
		' Delete file name (if set)
		If Self.file Then
			If FileType(Self.file) = FILETYPE_FILE Then
				DeleteFile(Self.file)
			EndIf
		EndIf
		
		' Delete a directory (if set)
		If Self.dir Then
			If FileType(Self.dir) = FILETYPE_DIR Then
				DeleteDir(Self.dir)
			End If
		EndIf
		
		' Delete a fileset
		If Self.filesets <> Null Then 
			
			Local fileCount:Int = 0
			Local totalSize:Int = 0
		
			For Local fs:Fileset = EachIn Self.filesets
				
				Local list:TList = fs.getIncludedFiles()
				
				For Local fileName:String = EachIn list
					fileCount:+ 1
					totalSize:+ FileSize(fileName)
					DeleteFile(fileName)
				Next
				
			Next
			
			Self.Log("Deleted " + fileCount + " files (" + totalSize + " bytes)")
			
		EndIf
		
	End Method
	
	Method setFileset(fs:Fileset)
		Self.filesets.AddLast(fs)
	End Method
	
End Type
