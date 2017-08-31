' ------------------------------------------------------------------------------
' -- src/tasks/file/mkdir_task.bmx
' --
' -- Create a directory or directory tree.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../build_task.bmx"

Type MkdirTask Extends BuildTask
	
	Field dir:String						'''< The directory to create
	
	
	' ------------------------------------------------------------
	' -- Task Execution
	' ------------------------------------------------------------
	
	Method execute()
		CreateDir(dir, True)
	End Method
	
End Type
