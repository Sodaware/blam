' ------------------------------------------------------------------------------
' -- src/expressions/expression_tokeniser.bmx
' --
' -- Converts a string expression into tokens. These tokens are then used by
' -- the expression evaluator during execution.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import "char_helper.bmx"

' ----- List of valid tokens
Const ExpressionTokeniser_TokenType_BOF%				= 1
Const ExpressionTokeniser_TokenType_EOF%				= 2
Const ExpressionTokeniser_TokenType_Number%				= 3
Const ExpressionTokeniser_TokenType_String%				= 4
Const ExpressionTokeniser_TokenType_Keyword%			= 5
Const ExpressionTokeniser_TokenType_Equal%				= 6
Const ExpressionTokeniser_TokenType_NotEqual%			= 7
Const ExpressionTokeniser_TokenType_LT%					= 8
Const ExpressionTokeniser_TokenType_GT%					= 9
Const ExpressionTokeniser_TokenType_LE%					= 11
Const ExpressionTokeniser_TokenType_GE%					= 12
Const ExpressionTokeniser_TokenType_Plus%				= 13
Const ExpressionTokeniser_TokenType_Minus%				= 14
Const ExpressionTokeniser_TokenType_Mul%				= 15
Const ExpressionTokeniser_TokenType_Div%				= 16
Const ExpressionTokeniser_TokenType_Mod%				= 17
Const ExpressionTokeniser_TokenType_LeftParen%			= 18
Const ExpressionTokeniser_TokenType_RightParen%			= 19
Const ExpressionTokeniser_TokenType_LeftCurlyBrace%		= 20
Const ExpressionTokeniser_TokenType_RightCurlyBrace%	= 21
Const ExpressionTokeniser_TokenType_Not%				= 22
Const ExpressionTokeniser_TokenType_Punctuation%		= 23
Const ExpressionTokeniser_TokenType_Whitespace%			= 24
Const ExpressionTokeniser_TokenType_Dollar%				= 25
Const ExpressionTokeniser_TokenType_Comma%				= 26
Const ExpressionTokeniser_TokenType_Dot%				= 27
Const ExpressionTokeniser_TokenType_DoubleColon%		= 28

''' <summary>Class for tokenising strings into something usable.</summary>
Type ExpressionTokeniser
	
	' -- Options
	Field IgnoreWhitespace:Int			'''< Is whitespace ignored?
	Field SingleCharacterMode:Int		'''< Is every single char treated as a token?
	
	' -- Current Token info
	Field CurrentToken:Int				'''< Const TokenType for current token
	Field TokenText:String				'''< Text of the current token
	Field CurrentPosition:Int			'''< Current position within the expression
	
	' -- Internal fields
	Field m_ExpressionText:String		'''< The full text of the expression
	
	
	' ------------------------------------------------------------
	' -- Public Getters
	' ------------------------------------------------------------
	
	Method getExpressionText:String()
		Return Self.m_ExpressionText
	End Method
	
	
	' ------------------------------------------------------------
	' -- Main API methods
	' ------------------------------------------------------------
	
	''' <summary>Moves the to the next token and returns it.
	Method GetNextToken:Int()
		
		' TODO: Should this really throw an error?
		If self.CurrentToken	= ExpressionTokeniser_TokenType_EOF Then
			Throw "End of file reached"
		EndIf
		
		If self.IgnoreWhitespace Then
			Self._skipWhitespace()
		EndIf
		
		' Check for end of file
		If Self._peekChar() = -1 Then
			self.CurrentToken	= ExpressionTokeniser_TokenType_EOF
			Return 0
		EndIf
		
		' Get next character
		Local char$	= Chr(Self._readChar())
		
		If self.SingleCharacterMode = False Then
			
			If Self.IgnoreWhitespace = False And CharHelper.IsWhitespace(char) Then
				
				Local curString$
				Local ch2%
				
				While (ch2 = Self._peekChar()) <> -1
					
					If Not(CharHelper.IsWhitespace(Chr(ch2))) Then
						Exit
					EndIf
					
					curString$	= curString$ + Chr(ch2)
					Self._readChar()
					
					self.CurrentToken	= ExpressionTokeniser_TokenType_Whitespace
					self.TokenText		= curString$
					
					Return 0
					
				Wend
				
			EndIf
			
			' Read numbers
			If CharHelper.IsDigit(char) Then
				
				self.CurrentToken	= ExpressionTokeniser_TokenType_Number
				Local s$	= char
				
				While Self._peekChar() <> -1
					
					char = Chr(Self._peekChar())
					
					If CharHelper.IsDigit(char)
						s = s + Chr(Self._readChar())
					Else
						Exit
					EndIf
					
				Wend
				
				self.TokenText	= s
				Return 0
				
			EndIf
			
			' Read strings
			If char = "'" Then
				Self._ReadString()
				Return 0
			EndIf
			
			' Read keywords
			If char = "_" Or CharHelper.IsLetter(char) Then
				
				self.CurrentToken	= ExpressionTokeniser_TokenType_Keyword
				Local s:String = char
				
	            While Self._peekChar() <> -1
					
					If (Chr(Self._peekChar()) = "_" Or Chr(Self._peekChar()) = "-" Or CharHelper.IsLetterOrDigit(Chr(Self._peekChar()))) Then
						s = s + Chr(Self._readChar())
					Else
						Exit
					EndIf
					
				Wend
	            
	            self.TokenText	= s
	            If Self.TokenText.EndsWith("-") Then
					' Error
	            EndIf
	            Return 0
			
			EndIf
			
			' Move to next char?
		'	Self.ReadChar()
			
			' Read double character operators
			
			' Double colon - namespace seperator
			If (char = ":" And Self._peekChar() = Asc(":")) Then
				self.CurrentToken	= ExpressionTokeniser_TokenType_DoubleColon
				self.TokenText	  	= "::"
				Self._readChar()
				Return 0
			EndIf
			
			' Not equal
			If char = "!" And Self._peekChar() = Asc("=") Then
				self.CurrentToken	= ExpressionTokeniser_TokenType_NotEqual
				self.TokenText		= "!="
				Self._readChar()
				Return 0		 	
			EndIf
			
			' Not equal (alternative)
			If char = "<" And Self._peekChar() = Asc(">") Then
				self.CurrentToken	= ExpressionTokeniser_TokenType_NotEqual
				self.TokenText		= "<>"
				Self._readChar()
				Return 0			
			EndIf		
			
			' Equal (C++ style)
			If char = "=" And Self._peekChar() = Asc("=") Then
				self.CurrentToken	= ExpressionTokeniser_TokenType_Equal
				self.TokenText		= "=="
				Self._readChar()
				Return 0			
			EndIf	
			
			' Less than equal (<=)
			If char = "<" And Self._peekChar() = Asc("=") Then
				self.CurrentToken	= ExpressionTokeniser_TokenType_LE
				self.TokenText		= "<="
				Self._readChar()
				Return 0			
			EndIf	
			
			' Greater than equal (<=)
			If char = ">" And Self._peekChar() = Asc("=") Then
				self.CurrentToken	= ExpressionTokeniser_TokenType_GE
				self.TokenText		= ">="
				Self._readChar()
				Return 0			
			EndIf			
			
		Else
			
			Self._readChar()
			
		EndIf
		
		self.TokenText		= char
		self.CurrentToken	= ExpressionTokeniser_TokenType_Punctuation
		
		' Convert token types
		If Asc(char) >= 32 And Asc(char) <= 128 Then
			Self.CurrentToken	= ExpressionTokeniser.CharToToken(char)
		EndIf
		
		
	End Method

	''' <summary>Checks if the current token is a reserved keyword.</summary>
	''' <param name="word">The word to check against.</param>
	''' <returns>True if a keyword, false if not.</returns>
	Method IsKeyword:Int(word:String)
		Return (self.CurrentToken = ExpressionTokeniser_TokenType_Keyword) And (self.TokenText = word)
	End Method
	
	Method IsRelationalOperator%()
		
		Local result:Int	= False
		
		Select self.CurrentToken
			Case ExpressionTokeniser_TokenType_Equal 	; result = True
			Case ExpressionTokeniser_TokenType_NotEqual ; result = True
			Case ExpressionTokeniser_TokenType_LT 		; result = True
			Case ExpressionTokeniser_TokenType_GT 		; result = True
			Case ExpressionTokeniser_TokenType_LE 		; result = True
			Case ExpressionTokeniser_TokenType_GE 		; result = True
		End Select
		
		Return result
		
	End Method



	
	''' <summary>Gets the TokenType for a character.</summary>
	''' <oaram name="charValue">The character to lookup.</param>
	''' <returns>TokenType value.</returns>
	Function CharToToken:Int(charValue:String)
		
		Select charValue
			
			Case "+"		; Return ExpressionTokeniser_TokenType_Plus
			Case "-"		; Return ExpressionTokeniser_TokenType_Minus
			Case "*"		; Return ExpressionTokeniser_TokenType_Mul
			Case "/"		; Return ExpressionTokeniser_TokenType_Div 
			Case "%"		; Return ExpressionTokeniser_TokenType_Mod
			Case "<"		; Return ExpressionTokeniser_TokenType_LT
			Case ">"		; Return ExpressionTokeniser_TokenType_GT
			Case "("		; Return ExpressionTokeniser_TokenType_LeftParen
			Case ")"		; Return ExpressionTokeniser_TokenType_RightParen
			Case "{"		; Return ExpressionTokeniser_TokenType_LeftCurlyBrace
			Case "}"		; Return ExpressionTokeniser_TokenType_RightCurlyBrace
			Case "!"		; Return ExpressionTokeniser_TokenType_Not
			Case "$"		; Return ExpressionTokeniser_TokenType_Dollar
			Case ","		; Return ExpressionTokeniser_TokenType_Comma
			Case "."		; Return ExpressionTokeniser_TokenType_Dot
			
		End Select
		
		' -- Default to punctuation
		Return ExpressionTokeniser_TokenType_Punctuation
		
	End Function
	
	
	' ------------------------------------------------------------
	' -- Internal tokenising methods
	' ------------------------------------------------------------
	
	Method _readString:String()
		
		Local s$	= ""
		Local i%	= 0
		Local char$	= Chr(Self._peekChar())
		
		self.CurrentToken	= ExpressionTokeniser_TokenType_String
		
		While Self._peekChar() <> -1
			char = Chr(Self._peekChar())
			
			If char = "'" Then
				' Skip past the end of the string
				Self._readChar()
				Exit
			Else
				s = s + Chr(Self._readChar())
			EndIf
			
		Wend
		
		self.TokenText	= s
		
		Return s
		
	End Method
	
	''' <summary>Moves to the next character in the expression and returns its ascii value.</summary>
	Method _readChar:Int()
	
		Local charValue:Int = Self._peekChar()
		
		Self.CurrentPosition:+ 1
		
		Return charValue		
	End Method

	Method _peekChar%()
		
		Local charValue% = -1
		
		If Self.CurrentPosition < Len(Self.m_ExpressionText) Then
			charValue	= Asc(Mid(self.m_ExpressionText, self.CurrentPosition + 1, 1))
		EndIf
		
		Return charValue
		
	End Method

	''' <summary>Reads all whitespace characters until the next non-whitespace character.</summary>
	Method _skipWhitespace()
		
		While (Self._peekChar()) <> -1
			If CharHelper.IsWhitespace(Chr(Self._peekChar())) = False Then Return
			Self._readChar()
		Wend
		
	End Method

	
	' ------------------------------------------------------------
	' -- Creation and Destruction
	' ------------------------------------------------------------
	
	Function Create:ExpressionTokeniser(expression$)
		
		Local this:ExpressionTokeniser	= New ExpressionTokeniser
		
		' Initialise
		this.m_ExpressionText			= expression
		this.CurrentPosition			= 0
		this.CurrentToken				= ExpressionTokeniser_TokenType_BOF
		
		this.IgnoreWhitespace			= True
		this.SingleCharacterMode		= False
		
		' Start tokenising
		this.GetNextToken()
		
		Return this
		
	End Function

	
End Type
