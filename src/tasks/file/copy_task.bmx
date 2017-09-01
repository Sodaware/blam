' ------------------------------------------------------------------------------
' -- src/tasks/file/copy_task.bmx
' --
' -- Copies files and directories from one place to another.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.Console_Color
Import "../build_task.bmx"
Import "../../types/fileset.bmx"

Type CopyTask Extends BuildTask

	Field file:String                       '''< The file to copy. Can be replaced with fileset.
	Field tofile:String                     '''< The destination filename to copy to. Ignored with fileset.
	Field todir:String                      '''< The directory to copy the file/files to.
	Field overwrite:Byte    = False         '''< If true will overwrite any files
	Field files:Fileset	                    '''< [optional] List of files to copy.
	Field verbose:Int       = False         '''< [optional] Show verbose output


	' ------------------------------------------------------------
	' -- Task Execution
	' ------------------------------------------------------------

	Method execute()

		' [todo] - Add some error checking here!

		Self.printHeader()

		Local filesToCopy:TList = self.files.getIncludedFiles()
		Local copiedFiles:Int   = 0

		For Local file:String = EachIn filesToCopy

			Local destination:String = (file.Replace(files.dir, Self.todir))

			' Do nothing if the file already exists and overwriting is disabled.
			If Self.overwrite = False And FileType(destination) = FILETYPE_FILE Then Continue

			If Self.verbose Then
				Self.Log(file + " => " + destination)
			EndIf

			CopyFile(file, destination)

			copiedFiles:+ 1

		Next

		Self.Log("Copied " + copiedFiles + " of " + filesToCopy.count() + " files")

	End Method


	' ------------------------------------------------------------
	' -- Configuration Helpers
	' ------------------------------------------------------------

	Method setFileset(files:Fileset)
		Self.files = files
	End Method


	' ------------------------------------------------------------
	' -- Output Helpers
	' ------------------------------------------------------------

	Method printHeader()

		Local fromDirName:String = Self.files.dir
		Local toDirName:String   = Self.todir

		fromDirName = fromDirName.Replace(ExtractDir(Self.getProject().getFilePath()), "")
		toDirName 	= toDirName.Replace(ExtractDir(Self.getProject().getFilePath()), "")

		Self.Log("Copying from '" + fromDirName + "' to '" + toDirName + "'")

	End Method

End Type
