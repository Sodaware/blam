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

Import sodaware.File_Util

Import "function_set.bmx"

Type EnvironmentFunctions Extends FunctionSet

	''' <summary>Get a system path.</summary>
	''' <param name="path">
	''' The path to fetch. Allowed values are "homedir", "tempdir" and "appdir".
	''' </param>
	''' <return>The requested path, or an empty string if an invalid path name was passed in.</return>
	Method GetSystemPath:String(path:String)	{ name="environment::get-system-path" }
		Select Lower(path$)
			Case "homedir" ; Return File_Util.GetHomeDir()
			Case "tempdir" ; Return File_Util.GetTempDir()
			Case "appdir"  ; Return AppDir
		End Select
	End Method

	''' <summary>Get the name of the current operating system.</summary>
	''' <return>The current operating system. Allowed values are "win32", "linux" or "osx".</return>
	Method GetOperatingSystem:String()			{ name="environment::get-operating-system" }
		?Win32		Return "win32"
		?Linux		Return "linux"
		?osx		Return "osx"
		?
	End Method

	''' <summary>Get the application extension used by the current operating system.</summary>
	''' <return>The extension used by this os. Allowed values are ".exe" for windows and ".app" for MacOS".</return>
	Method getAppExtension:String()				{ name="environment::get-app-extension" }
		?Win32		Return ".exe"
		?Linux		Return ""
		?osx		Return ".app"
		?
	End Method

	''' <summary>Get the username running the build.</summary>
	''' <return>The username running the app.</return>
	Method GetUserName:String()					{ name="environment::get-user-name" }
		Return getenv_("USERNAME")
	End Method

End Type
