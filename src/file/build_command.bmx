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

	Field _name:String              '''< The name of the command (i.e. what task to call)
	Field _value:String             '''< Optional value of the node. Usually empty.

	' Location (used for error messages)
	Field _startLine:Int
	Field _endLine:Int
	Field _startCol:Int
	Field _endCol:Int

	' TODO: Convert this to a StringTable
	Field _parameters:TMap
	Field _childElements:TList


	' ------------------------------------------------------------
	' -- Getting Information
	' ------------------------------------------------------------

	Method getName:String()
		Return Self._name
	End Method

	Method hasChildren:Byte()
		Return Not(Self._childElements.IsEmpty())
	End Method

	Method getChildren:TList()
		Return Self._childElements
	End Method

	Method hasAttribute:Byte(name:String)
		Return (Self._parameters.valueForKey(name.toLower()) <> Null)
	End Method

	Method getAttribute:String(name:String)
		Return String(Self._parameters.ValueForKey(name.toLower()))
	End Method


	' ------------------------------------------------------------
	' -- Setting Internals
	' ------------------------------------------------------------

	Method addAttribute(name:String, value:String)
		Self._parameters.Insert(name, value)
	End Method

	Method addChild(value:Object)
		Self._childElements.AddLast(value)
	End Method


	' ------------------------------------------------------------
	' -- Debug Helpers
	' ------------------------------------------------------------

	Method __dump()
		If Self._value Then
			Print "~t~t" + Self._name + " [" + Self._value + "]"
		Else
			Print "~t~t" + Self._name
		EndIf

		For Local param:String = EachIn Self._parameters.Keys()
			Print "~t~t~t" + LSet(param, 20) + " => " + String(Self._parameters.ValueForKey(param))
		Next

	End Method


	' ------------------------------------------------------------
	' -- Construction / Destruction
	' ------------------------------------------------------------

	Method New()
		Self._parameters = New TMap
		Self._childElements = New TList
	End Method

End Type
