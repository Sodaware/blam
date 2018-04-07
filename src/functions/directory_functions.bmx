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

Import "function_set.bmx"

Type DirectoryFunctions Extends FunctionSet

	''' <summary>Check if a directory exists.</summary>
	''' <param name="path">The directory path to search for.</param>
	''' <returns>True if the path exists, false if not.</returns>
	Method exists:Byte(path:String)             { name = "directory::exists" }

		' Strip trailing slashes.
		If path.EndsWith("/") Or path.EndsWith("\") Then
			path = Left(path, path.Length - 1)
		EndIf

		' Check it exists
		Return (FileType(path) = FILETYPE_DIR)

	End Method

	''' <deprecated>Use directory::exists instead.</deprecated>
	Method _dirExists:Int(path:String)          { name = "path::exists" }
		Return Self.exists(path)
	End Method

End Type
