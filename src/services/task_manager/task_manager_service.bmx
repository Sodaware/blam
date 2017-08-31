' ------------------------------------------------------------------------------
' -- src/services/task_manager/task_manager_service.bmx
' --
' -- Creates `BuildTask` objects from their meta name.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import brl.reflection

Import "../service.bmx"
Import "../../tasks/build_task.bmx"


Type TaskManagerService Extends Service

	''' <summary>Find and create a BuildTask object by name.</summary>
	Method findTask:BuildTask(taskName:String)

		' todo: cache this in initialiseService
		' Check all derived types first
		Local baseTask:TTypeId = TTypeId.ForName("BuildTask")
		For Local task:TTypeId = EachIn baseTask.DerivedTypes()
			' Strip 'Task' from the end of the type name
			If Lower(Left(task.Name(), task.Name().Length - 4)) = Lower(taskName) Then
				Return BuildTask(task.NewObject())
			EndIf
		Next

		Return Null

	End Method


	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method initialiseService()

	End Method

	Method unloadService()

	End Method

End Type
