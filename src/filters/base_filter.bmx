' ------------------------------------------------------------------------------
' -- src/filters/base_filter.bmx
' --
' -- Base filter for use with the FilterChain type.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2018 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection

Import "../file/build_node.bmx"

Type BaseFilter

	Field _builder:Object

	''' <summary>Process fileName.</summary>
''	Method processFile(fileName:String) Abstract
	Method processString:String(contents:String) Abstract

	' Overwrite this to set stuff.
	Method initialize(node:BuildNode)
	End Method

	' TODO: This is horrific.
	Method parsePropertyValue:String(value:String)
		If Self._builder = Null Then
			DebugLog "Could not evaluate - no builder"
			Return value
		End If

		Local parseMethod:TMethod = TTypeId.forObject(Self._builder).findMethod("_parsePropertyValue")
		return String(parseMethod.invoke(Self._builder, [value]))
	End Method

End Type
