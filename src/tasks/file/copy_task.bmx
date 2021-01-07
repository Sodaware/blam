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

Import "../build_task.bmx"
Import "../../types/fileset.bmx"
Import "../../types/filter_chain.bmx"

Type CopyTask Extends BuildTask

	Field file:String                       '''< The file to copy. Can be replaced with fileset.
	Field toFile:String                     '''< The destination filename to copy to. Ignored with fileset.
	Field toDir:String                      '''< The directory to copy the file/files to.
	Field overwrite:Byte                    '''< If true will overwrite any files.
	Field createDirs:Byte                   '''< If true, will create directory structure when copying files.
	Field files:Fileset                     '''< [optional] List of files to copy.
	Field filters:FilterChain               '''< [optional] List of filters to run files through.
	Field verbose:Byte                      '''< [optional] Show verbose output.


	' ------------------------------------------------------------
	' -- Task Execution
	' ------------------------------------------------------------

	Method execute()
		Self.printHeader()

		' Quit out if missing a valid file location.
		If Not Self.validateInputs() Then Return

		Local copiedFiles:Int = 0
		Local totalFiles:Int  = 0

		' Get the files to copy. May be a fileset or a single to/from operation.
		If Self.files Then
			Local filesToCopy:TList = Self.files.getIncludedFiles()
			totalFiles = filesToCopy.count()

			For Local file:String = EachIn filesToCopy
				Local destination:String = file.Replace(files.dir, Self.todir)

				' Do nothing if the file already exists and overwriting is disabled.
				If Self.overwrite = False And FileType(destination) = FILETYPE_FILE Then Continue

				If Self.verbose Then
					Self.Log(file + " => " + destination)
				EndIf

				' Create the directory if not present.
				If FileType(ExtractDir(destination)) <> FILETYPE_DIR And Self.createDirs Then
					CreateDir(ExtractDir(destination), True)
				EndIf

				' Copy file and display an error if it failed.
				If Not CopyFile(file, destination) Then
					Self.Log("Could not copy to " + destination, LEVEL_ERROR)
					Continue
				EndIf

				' Process the file if needed.
				If Self.filters Then
					Self.processFile(destination)
				End If

				copiedFiles = copiedFiles + 1
			Next

		Else
			' Copy a single file.
			totalFiles = 1

			If Self.verbose Then
				Self.Log(Self.file + " => " + Self.tofile)
			EndIf

			' Do nothing if the file already exists and overwriting is disabled.
			If Self.overwrite = False And FileType(Self.tofile) = FILETYPE_FILE Then
				If Self.verbose Then Self.Log("  Skipping (file exists)")

				Return
			EndIf

			' Create the destination directory if not present.
			If FileType(ExtractDir(Self.toFile)) <> FILETYPE_DIR And Self.createDirs Then
				CreateDir(ExtractDir(Self.toFile), True)
			EndIf

			' Copy the file
			If Not CopyFile(Self.file, Self.toFile) Then
				Self.Log("Could not copy to " + Self.toFile, LEVEL_ERROR)

				Return
			EndIf

			' Process the file if needed.
			If Self.filters Then
				Self.processFile(Self.tofile)
			End If

			copiedFiles = 1

		End If

		Self.Log("Copied " + copiedFiles + " of " + totalFiles + " files")

	End Method


	' ------------------------------------------------------------
	' -- Validation Helpers
	' ------------------------------------------------------------

	Method validateInputs:Byte()
		If Self.files = Null Then
			If Self.file = "" Then
				Self.Log("Missing source path in <copy> command", LEVEL_ERROR)
				Return False
			End if

			If Self.tofile = "" Then
				Self.Log("Missing destination path in <copy> command", LEVEL_ERROR)
				Return False
			End if
		End If

		Return True
	End Method


	' ------------------------------------------------------------
	' -- Running Filters
	' ------------------------------------------------------------

	Method processfile(filename:String)

		' Do nothing if no filters exist.
		If Self.filters = Null Then Return

		' Load the file contents and strip the last char.
		Local contents:String = File_Util.GetFileContents(filename)

		' Run the content through each filter in order.
		For Local filter:BaseFilter = EachIn Self.filters.getFilters()
			contents = filter.processString(contents)
		Next

		' Save the contents over the original file.
		File_Util.PutFileContents(filename, contents)

	End Method


	' ------------------------------------------------------------
	' -- Configuration Helpers
	' ------------------------------------------------------------

	Method setFileset(files:Fileset)
		Self.files = files
	End Method

	Method setFilterchain(filters:FilterChain)
		Self.filters = filters
	End Method


	' ------------------------------------------------------------
	' -- Output Helpers
	' ------------------------------------------------------------

	Method printHeader()
		If Self.files = Null Then Return

		Local fromDirName:String = Self.files.dir
		Local toDirName:String   = Self.todir

		fromDirName = fromDirName.Replace(ExtractDir(Self.getProject().getFilePath()), "")
		toDirName	= toDirName.Replace(ExtractDir(Self.getProject().getFilePath()), "")

		Self.log("Copying from '" + fromDirName + "' to '" + toDirName + "'")
	End Method

End Type
