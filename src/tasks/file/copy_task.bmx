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
	
	Field file:String
	Field tofile:String
	Field todir:String
	Field overwrite:Int	= False
	
	Field files:Fileset
	Field verbose:Int		= False			'''< [optional] Show verbose output

	Method execute()

' [todo] - Add some error checking here!

		self.printHeader()

		Local filesToCopy:TList = self.files.getIncludedFiles()
		local copiedFiles:Int   = 0

		For local file:String = eachin filesToCopy

			Local destination:STring = (file.replace(files.dir, self.todir))

			' Check if it exists
			if filetype(destination) = 1 and self.overwrite = false then continue

			if self.verbose then
				self.log(file + " => " + destination)
			endif

			copyfile(file, destination)

			copiedFiles:+ 1

		next

		self.log("Copied " + copiedFiles + " of " + filesToCopy.count() + " files")

	End Method

	Method setFileset(files:Fileset)
		self.files = files
	end method

	Method printHeader()
		
		Local fromDirName:String 	= self.files.dir
		local toDirName:String 		= self.todir

		fromDirName = fromDirName.replace(ExtractDir(self.getProject().getFilePath()), "")
		toDirName 	= toDirName.replace(ExtractDir(self.getProject().getFilePath()), "")

		self.log("Copying from '" + fromDirName + "' to '" + toDirName + "'")

	End Method

End Type
