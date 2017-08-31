' ------------------------------------------------------------------------------
' -- src/functions/environment.bmx
' --
' -- Functions in the "environment" namespace. Used for retrieving system paths
' -- and information about the system the build script is running on.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import sodaware.File_Util

Import "function_set.bmx"

Type EnvironmentFunctions Extends FunctionSet
		
	Method GetSystemPath:String(path:String) 	{ name="environment::get-system-path" }
		
		'SystemDrive
	
		' Standard Blitz paths
		Select Lower(path$)
			
			Case "homedir"		; Return File_Util.GetHomeDir()
			Case "tempdir" 		; Return File_Util.GetTempDir()
			Case "appdir" 		; Return AppDir
			
		End Select
		
	End Method
	
	Method GetOperatingSystem:String() 			{ name="environment::get-operating-system" }
	
		?Win32		Return "win32"
		?Linux		Return "linux"
		?osx		Return "osx"
		?
		
	End Method
	
	Method GetUserName:String()					{ name="environment::get-user-name" }
		Return getenv_("USERNAME")
	End Method
	
End Type
