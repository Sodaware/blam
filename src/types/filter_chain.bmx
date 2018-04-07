' ------------------------------------------------------------------------------
' -- src/types/filter_chain.bmx
' --
' -- One (or more) filters. Used to process files.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2018 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection

Import "base_type.bmx"
Import "../filters/base_filter.bmx"

Type FilterChain Extends BaseType ..
	{ name="filterchain" }

	Field filters:TList


	' ------------------------------------------------------------
	' -- Getting and Setting Filters
	' ------------------------------------------------------------

	Method getFilters:TList()
		Return filters
	End Method

	''' <summary>Set child nodes of a filter.</summary>
	Method setChild(node:BuildNode)

		' Find all registered filters. If they match the node, set them.
		Local parent:TTypeId = TTypeId.ForName("BaseFilter")
		For Local filterType:TTypeId = EachIn parent.DerivedTypes()
			If node.Name.toLower() = filterType.MetaData("name") Then
				Local filter:BaseFilter = BaseFilter(filterType.NewObject())
				filter._builder = Self._builder
				filter.initialize(node)
				Self.filters.addLast(filter)
			End If
		Next

	End Method

	' ------------------------------------------------------------
	' -- Construction
	' ------------------------------------------------------------

	Method New()
		Self.filters = New TList
	End Method

End Type
