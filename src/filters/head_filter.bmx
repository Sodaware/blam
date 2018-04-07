' ------------------------------------------------------------------------------
' -- src/filters/head_filter.bmx
' --
' -- Returns the first X lines of a file.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2018 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "base_filter.bmx"

Type HeadFilter Extends BaseFilter ..
	{ name = "headfilter" }

	Field lines:Int
	Field skip:Int

	''' <summary>Replace tokens in `contents`.</summary>
	Method processString:String(contents:String)

		' Split content into lines.
		Local contentLines:String[] = contents.split("~n")
		Local headLines:String      = ""
		Local pos:Int               = Self.skip

		While pos < Self.lines + Self.skip And pos < contentLines.length
			headLines :+ contentLines[pos] + "~n"
			pos :+ 1
		Wend

		Return headLines

	End Method

	Method initialize(node:BuildNode)
		Self.lines = Int(node.getAttribute("lines"))
		Self.skip  = Int(node.getAttribute("skip"))
	End Method

End Type
