' ------------------------------------------------------------------------------
' -- src/core/exceptions.bmx
' --
' -- Exceptions that can be thrown by the application.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type TaskNotImplementedException Extends TBlitzException
	Method toString:String()
		Return "Task not implemented yet"
	End Method
End Type

Type ProcessTimeoutException Extends TBlitzException
	Method toString:String()
		Return "Process timed out"
	End Method
End Type

Type ProcessException Extends TBlitzException
	Field _message:String
	Method toString:String()
		Return Self._message	
	End Method
	
	Function Create:ProcessException(message:String)
		Local exception:ProcessException = New ProcessException
		exception._message = message
		Return exception
	End Function
End Type

Type FileLoadException Extends TBlitzException
	Field _message:String
	Method toString:String()
		Return Self._message	
	End Method
	
	Function Create:FileLoadException(message:String)
		Local exception:FileLoadException = New FileLoadException
		exception._message = message
		Return exception
	End Function
End Type

Type MissingTargetException Extends TBlitzException

	Field _targetName:String

	Method toString:String()
		If Self._targetName Then
			Return "Target ~q" + Self._targetName + "~q not found."
		Else
			Return "Invalid target name specified"
		EndIf
	End Method

	Function Create:MissingTargetException(targetName:String)
		Local exception:MissingTargetException = New MissingTargetException
		exception._targetName = targetName
		Return exception
	End Function

End Type
