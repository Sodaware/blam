' ------------------------------------------------------------------------------
' -- src/filters/replace_tokens_filter.bmx
' --
' -- Replaces tokens.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2018 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "base_filter.bmx"

Type ReplaceTokensFilter Extends BaseFilter ..
	{ name = "replacetokens" }

	Field prefix:String
	Field suffix:String
	Field tokens:TList
	
	''' <summary>Replace tokens in `contents`.</summary>
	Method processString:String(contents:String)
		For Local token:ReplaceToken = EachIn Self.tokens

			' Create the key name and evaludate the value.
			Local toReplace:String   = Self.prefix + token.key + Self.suffix
			Local replaceWith:String = Self.getValue(token.value)

			' Run the replacement.
			contents = contents.Replace(toReplace, replaceWith)
		Next		

		Return contents
	End Method

	Method getValue:String(value:String)
		Return Self.parsePropertyValue(value)
	End Method

	Method initialize(node:BuildNode)
		' TODO: Should have default values.
		Self.prefix = node.getAttribute("prefix")
		Self.suffix = node.getAttribute("suffix")

		' Get all tokens.
		Self.tokens = New TList
		For Local tokenNode:BuildNode = EachIn node.children
			Local token:ReplaceToken = New ReplaceToken
			token.key   = tokenNode.getAttribute("key")
			token.value = tokenNode.getAttribute("value")
			Self.tokens.addLast(token)
		Next
		
	End Method
	
End Type

Private

Type ReplaceToken
	Field key:String
	Field value:String
End Type

Public