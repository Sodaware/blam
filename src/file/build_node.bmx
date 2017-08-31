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

import brl.map
import brl.linkedlist

Type BuildNode
	
	field Name:String
	field Contents:String
	Field Attributes:TMap
	field Children:TList
	
	Method setAttribute(name:String, val:String)
		self.Attributes.Insert(name, val)
	End Method
	
	Method addChild(child:BuildNode)
		Self.Children.AddLast(child)
	End Method
	
	Method New()
		Self.Attributes	= new TMap
		Self.Children	= new TList
	End Method
	
	Method getAttribute:String(name:String)
		Return String(Self.Attributes.ValueForKey(Name))
	End Method
	
End Type
