' ------------------------------------------------------------------------------
' -- src/file/build_command.bmx
' --
' -- Represents a single command within a build script.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.Map
Import brl.retro

Type BuildCommand
	
	Field m_Name:String
	Field m_Value:String
	
	' Location (used for error messages)
	Field m_StartLine:Int
	Field m_EndLine:Int
	Field m_StartCol:Int
	Field m_EndCol:Int
	
	Field m_Parameters:TMap
	Field m_ChildElements:TList
	
'	Field m_FileNode.XML_Node
'	Field m_Schema.CommandHandler
	
'	Field m_ParameterList%
'	Field m_ChildElements%		;;; List of child elements
	
	Method hasChildren:Int()
		Return (Self.m_ChildElements.Count() > 0)
	End Method
	
	Method getChildren:TList()
		Return Self.m_ChildElements
	End Method

	Method addAttribute(name:String, value:String)
		Self.m_Parameters.Insert(name, value)
	End Method
	
	Method addChild(value:Object)
		Self.m_ChildElements.AddLast(value)
	End Method

	Method New()
		Self.m_Parameters = New TMap
		Self.m_ChildElements = New TList
	End Method
	
	Method __dump()
		If Self.m_Value Then
			Print "~t~t" + Self.m_Name + " [" + Self.m_Value + "]"
		Else
			Print "~t~t" + Self.m_Name
		EndIf	
		
		For Local param:String = EachIn Self.m_Parameters.Keys()
			Print "~t~t~t" + LSet(param, 20) + " => " + String(Self.m_Parameters.ValueForKey(param))
		Next
		
	End Method

End Type
