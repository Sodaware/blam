' ------------------------------------------------------------------------------
' -- src/tasks/build_task.bmx
' --
' -- Base type all build tasks must extend. All build tasks have access to the
' -- build script they were defined in, as well as all application services.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

' TODO: Remove this eventually (why?)
Import "../util/console_util.bmx"
Import "../service_manager.bmx"
Import "../file/build_script.bmx"

Type BuildTask

	Const LEVEL_INFO:Byte   = 1
	Const LEVEL_WARN:Byte   = 2
	Const LEVEL_ERROR:Byte  = 3

	Field _services:ServiceManager
	Field _project:BuildScript

	Method getProject:BuildScript()
		Return Self._project
	End Method

	Method _getService:Service(serviceName:String)
		Return Service(Self._services.GetService(TTypeId.ForName(serviceName)))
	End Method

	Method execute() Abstract

	Method _setProperty(propName:String, propValue:String)

		If Self._project.getCurrentTarget() = Null Then
			' -- Global property
			Self._project.setProperty(propName, propValue)
		Else
			' -- Local property
			Self._project.getCurrentTarget().setProperty(propName, propValue)
		End If

	End Method

	Method _setChild(childType:String, childValue:Object)

	End Method

	Method log(message:String, logLevel:Int = LEVEL_INFO)

		' Add colour codes
		If logLevel = LEVEL_WARN Then
			message = "%Y" + message + "%n"
		ElseIf logLevel = LEVEL_ERROR Then
			message = "%R" + message + "%n"
		End If

		' TODO: Add it to the build log

		ConsoleUtil.PrintC(message)

	End Method

End Type
