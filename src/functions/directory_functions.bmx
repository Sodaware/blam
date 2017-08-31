' ------------------------------------------------------------------------------
' -- src/functions/directory_functions.bmx
' --
' -- Script functions functions for working with files and directories.
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

Type DirectoryFunctions Extends FunctionSet
	
	Method Exists:Int(path:String)				{ name="directory::exists" }
		
		' Strip trailing slashes
		If path.EndsWith("/") Or path.EndsWith("\") Then 
			path = Left(path, path.Length - 1)
		EndIf
		
		' Check it exists
		Return (FileType(path) = FILETYPE_DIR)
	
	End Method
	
	''' <deprecated>Use directory::exists instead.</deprecated>
	Method _dirExists:Int(path:String)			{ name="path::exists" }
		Return Self.Exists(path)
	End Method
	
End Type
