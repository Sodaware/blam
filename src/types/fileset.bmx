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
	Field basename:String		= "/"
	Field id:String
	Field refid:String
	Field casesensitive:Int		= False
	Field defaultexcludes:Int	= True
	Field failonempty:Int		= False
	Field dir:String			= ""

	Field includes:TList		{ name="include" }
	Field excludes:TList		{ name="exclude" }
	Field includesfile:TList	{ name="includesfile" }
	Field excludesfile:TList	{ name="excludesfile" }
	' Child Elements
	'include
	'exclude
	'includesfile
	'excludesfile
	
	Method New()
		Self.includes		= New TList
		Self.excludes		= New TList
		Self.includesfile	= New TList
		Self.excludesfile	= New TList
		
'		Self.dir			= CurrentDir()
	End Method
	
	Method getIncludedFiles:TList()
		
		' Evaluate the fileset
		If defaultexcludes Then Self._addDefaultExcludes()
		
		Local fileList:TList 	= New TList
		Local fileNames:TList	= Self._getFileNames(Self.dir)
		
		For Local name:String = EachIn fileNames
			
			' Get the releative filename
			Local fileName:String 	= name.Replace(dir, "")
			
			' Only add if it can be included
			If Self._includeFilename(fileName) Then
				fileList.AddLast(name)
			End If
			
		Next
		
		Return fileList
		
	End Method
	
	Method _includeFilename:Int(fileName:String)
		
		'Print "Checking: " + fileName
	
		' Check excludes first
		For Local pattern:String = EachIn Self.excludes
		'	If fileName.Find("Thumbs.db") <> - 1 Then
		'		Print pattern
		'	End If
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
		Self.excludes.AddLast("**/.svn")
		Self.excludes.AddLast("**/.git")
		Self.excludes.AddLast("**/.svn")
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
