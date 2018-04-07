' ------------------------------------------------------------------------------
' -- src/file/build_node.bmx
' --
' -- Represents a generic node within a build script.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.stringtable
import brl.linkedlist

Type BuildNode

	Field Name:String
	Field Contents:String
	Field Attributes:StringTable
	Field Children:TList

	' ------------------------------------------------------------
	' -- Getting and setting attributes
	' ------------------------------------------------------------

	Method getAttribute:String(name:String)
		Return Self.Attributes.get(name)
	End Method

	Method setAttribute:BuildNode(name:String, value:String)
		Self.Attributes.set(name, value)
		Return Self
	End Method


	' ------------------------------------------------------------
	' -- Child Elements
	' ------------------------------------------------------------

	Method addChild(child:BuildNode)
		Self.Children.AddLast(child)
	End Method


	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Method New()
		Self.Attributes	= new StringTable
		Self.Children	= new TList
	End Method

End Type
