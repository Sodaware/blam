' ------------------------------------------------------------------------------
' -- src/tasks/core/call_task.bmx
' --
' -- Calls another target.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../../core/exceptions.bmx"
Import "../build_task.bmx"

Type CallTask Extends BuildTask
	
	Field target:String
	
	Method execute()
		Throw New TaskNotImplementedException
	End Method
	
End Type
