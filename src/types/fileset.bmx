' ------------------------------------------------------------------------------
' -- src/types/fileset.bmx
' --
' -- Build type for working with filesets.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.File_Util
Import sodaware.file_fnmatch

Import "base_type.bmx"

Type Fileset Extends BaseType ..
	{ name="fileset" }

	' Parameters
	Field defaultexcludes:Byte  = True
	Field failonempty:Byte      = False
	Field dir:String            = ""

	Field includes:TList        { name="include" }
	Field excludes:TList        { name="exclude" }

	Method New()
		Self.includes = New TList
		Self.excludes = New TList
	End Method

	Method getIncludedFiles:TList()
		' TODO: Set dir to the project's directory if empty.
		If Self.dir = "" Then
			Self.dir = ExtractDir(Self._project.getFilePath())
		EndIf

		' Evaluate the fileset
		If defaultexcludes Then Self._addDefaultExcludes()

		Local fileList:TList	= New TList
		Local fileNames:TList	= Self._getFileNames(Self.dir)

		For Local name:String = EachIn fileNames

			' Get the releative filename
			Local fileName:String	= name.Replace(dir, "")

			' Only add if it can be included
			If Self._includeFilename(fileName) Then
				fileList.AddLast(name)
			End If

		Next

		If Self.failonempty And fileList.isEmpty() Then
			' TODO: Throw a "BuildException" or something here.
			Throw "File list is empty"
		EndIf

		Return fileList

	End Method

	Method _includeFilename:Int(fileName:String)

		' Check excludes first
		For Local pattern:String = EachIn Self.excludes
			If fnmatch(fileName, pattern) Then
				Return False
			EndIf
		Next

		For Local pattern:String = EachIn Self.includes
			If fnmatch(fileName, pattern) Then
				Return True
			End If
		Next

		Return False

	End Method

	Method _getFileNames:TList(dir:String)

		Local list:TList = New TList

		Local files:String[] = LoadDir(dir)
		For Local fileName:String = EachIn files

			If FileType(dir + "/" + fileName) = FILETYPE_DIR Then

				Local ls:TList = Self._getFileNames(File_Util.PathCombine(dir, fileName))
				For Local file:String = EachIn ls
					list.AddLast(file)
				Next

			Else
				list.AddLast(File_Util.PathCombine(dir, fileName))
			EndIf

		Next

		Return list

	End Method

	Method _addDefaultExcludes()
		Self.excludes.addLast("**/.svn")
		Self.excludes.addLast("**/.git")
	End Method


	' ------------------------------------------------------------
	' -- Setting child elements
	' ------------------------------------------------------------

	Method setInclude(node:BuildNode)
		Self.includes.AddLast(node.getAttribute("name"))
	End Method

	Method setExclude(node:BuildNode)
		Self.excludes.AddLast(node.getAttribute("name"))
	End Method

End Type
