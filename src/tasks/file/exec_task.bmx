' ------------------------------------------------------------------------------
' -- src/tasks/file/exec_task.bmx
' --
' -- Execute an external application.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../build_task.bmx"

Type ExecTask Extends BuildTask
	
	Field command:String						'''< The command to execute
	
	
	' ------------------------------------------------------------
	' -- Task Execution
	' ------------------------------------------------------------
	
	Method execute()
		
	End Method
	
End Type
