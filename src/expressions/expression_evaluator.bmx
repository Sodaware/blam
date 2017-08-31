' ------------------------------------------------------------------------------
' -- src/expressions/expression_evaluate.bmx
' --
' -- Used to evaluate expressions within properties. Anthing inside a ${} block
' -- is parsed and the approprate code called.
' --
' -- This is a port of code used by the original BlitzBuild so it's rather
' -- unpleasant in places.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.reflection

Import "expression_tokeniser.bmx"
Import "script_object.bmx"
Import "../functions/function_set.bmx"
Import "script_function.bmx"

Const EXPRESSIONEVALUATOR_MODE_EVALUATE%	= 1
Const EXPRESSIONEVALUATOR_MODE_PARSEONLY%	= 2

Type ExpressionEvaluator
	
	' Private fields for the evaluator
	Field m_EvalMode:Int
	Field m_Tokeniser:ExpressionTokeniser
	
	Field m_RegisteredFunctions:TMAP
	
	' BlitzBuild specific fields
	Field m_Properties:TMap			
'	Field m_Project.BuildScript	;;; 
	
	
	' ------------------------------------------------------------
	' -- Public API
	' ------------------------------------------------------------

	Method RegisterFunctionSet(set:FunctionSet)
		
		Local setType:TTypeId = TTypeId.ForObject(set)
		For Local fnc:TMethod = EachIn setType.Methods()
		
			' -- Skip private methods & constructor
			If fnc.Name().StartsWith("_") Or fnc.Name() = "New" Then Continue
			
			' -- Get function call name from meta
			Local meta:TMAP = ExpressionEvaluator.ParseMetaString(fnc.MetaData())
			Local name:String = String(meta.ValueForKey("name"))
			
			' -- Register the function
			Self.m_RegisteredFunctions.Insert(name, ScriptFunction.Create(set, fnc))
			
		Next
		
	End Method
	
	''' <summary>Register a ScriptFunction object to use.</summary>
	Method RegisterFunction:Int(func:ScriptFunction)
		Self.m_RegisteredFunctions.Insert(func.GetFullName(), func)
	End Method
	
	Method RegisterStringProperty:Int(propName:String, propValue:String)
		Self.m_Properties.Insert(propName, ScriptObjectFactory.NewString(propValue))
	End Method
	
	Method RegisterFloatProperty:Int(propName:String, propValue:Float)
		Self.m_Properties.Insert(propName, ScriptObjectFactory.NewFloat(propValue))
	End Method
	
	Method RegisterIntProperty:Int(propName:String, propValue:Int)
		Self.m_Properties.Insert(propName, ScriptObjectFactory.NewInt(propValue))
	End Method
	
	' Merge a list of properties
	Method AddProperties(propertyList:Tmap)
		If propertyList = Null Then Return
		For Local keyName:String = EachIn propertyList.Keys()
			Self.m_Properties.Insert(keyName, ScriptObjectFactory.NewString(String(propertyList.ValueForKey(keyName))))
		Next
	End Method
	
	' TODO: Implement this?
	rem
	Method SetBuildFile(project:BuildScript)
		
		Self.m_Project	= project
		
		' Add global properties
		Self.AddProperties(Self.m_Project.m_GlobalProperties)
		
	End Method
	end rem
	
	
	' ------------------------------------------------------------
	' -- MAIN ENTRY
	' ------------------------------------------------------------
	
	Function QuickEvaluate:ScriptObject(expression:String)
	
		If expression = Null Then Return Null
	
		Local eval:ExpressionEvaluator = ExpressionEvaluator.Create(expression)
		Local result:ScriptObject = eval.Evaluate()
		eval = Null
		Return result
		
	End Function
	
	Method Evaluate:ScriptObject()
		
		Local result:ScriptObject	=  Self.ParseExpression()
		
		If Self.m_Tokeniser.CurrentToken <> ExpressionTokeniser_TokenType_EOF Then
			Throw("Unexpected Char at end of expression: " + Self.m_Tokeniser.CurrentToken)
		EndIf
		
		Return result
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Evaluation Methods
	' ------------------------------------------------------------
	
	Method ParseExpression:ScriptObject()
		Return Self.ParseBooleanOr()
	End Method
	
	Method ParseBooleanOr:ScriptObject()
		
		' 
		' Local startPosition:Int		= Self.m_Tokeniser.CurrentPosition
		Local o1:ScriptObject		= Self.ParseBooleanAnd()
		' Local oldEvalMode:Int		= Self.m_EvalMode
		
		While(Self.m_Tokeniser.IsKeyword("or"))
			
			' Get the left hand side
			Local v1:ScriptObject	= ScriptObjectFactory.NewBool( True )
			
			If Self.m_EvalMode	<> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
				
				' If true, we're done (because it's an or)
				v1 = o1
				If Int(v1.ToString()) Then
					Self.m_EvalMode = EXPRESSIONEVALUATOR_MODE_PARSEONLY
				EndIf
				
			EndIf
			
			' Right hand side
			Self.m_Tokeniser.GetNextToken()
		'	Local p2% 			= Self.m_Tokeniser.CurrentPosition
			Local o2:ScriptObject		= Self.ParseBooleanAnd()
		'	Local p3:Int 		= Self.m_Tokeniser.CurrentPosition
			
			If Self.m_EvalMode	<> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
				Local v2:ScriptObject 	= o2
				o1 			= ScriptObjectFactory.NewBool( Int(v1.ToString()) Or Int(v2.ToString()) )
			EndIf
			
		Wend
		
		Return o1
		
	End Method
	
	Method ParseBooleanAnd:ScriptObject()
		
		Local p0:Int	= Self.m_Tokeniser.CurrentPosition
		Local o:ScriptObject	= Self.ParseRelationalExpression()
		
		Local oldEvalMode:Int	= Self.m_EvalMode
		
		While(Self.m_Tokeniser.IsKeyword("and"))
			
			' Get the left hand side
			Local v1:ScriptObject	= ScriptObjectFactory.NewBool( True )
			
			If Self.m_EvalMode	<> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
				
				'  If false, we're done (because it's an and)
				v1 = o
				
				If Int(v1.ToString()) = False Then
					' We're done - result must be false now
					Self.m_EvalMode = EXPRESSIONEVALUATOR_MODE_PARSEONLY	
				EndIf
				
			EndIf
			
			' Right hand side
			Self.m_Tokeniser.GetNextToken()
			
			Local p2% 		= Self.m_Tokeniser.CurrentPosition
			Local o2:ScriptObject	= Self.ParseRelationalExpression()
			Local p3:Int 	= Self.m_Tokeniser.CurrentPosition
			
			If Self.m_EvalMode	<> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
				Local v2:ScriptObject 	= o2
				o 				= ScriptObjectFactory.NewBool( v1 And v2 )
			EndIf
			
		Wend
		
		Return o
		
	End Method
	
	' TODO: Fix all of these :D
	Method ParseRelationalExpression:ScriptObject()
	
		Local p0:Int	= Self.m_Tokeniser.CurrentPosition
		Local o:ScriptObject	= Self.ParseAddSubtract()
		
		If Self.m_Tokeniser.IsRelationalOperator() Then
			
			Local op:Int	= Self.m_Tokeniser.CurrentToken
			Self.m_Tokeniser.GetNextToken()
			
			Local o2:ScriptObject	= Self.ParseAddSubtract()
			Local p2:Int		= Self.m_Tokeniser.CurrentPosition
			
			If Self.m_EvalMode = EXPRESSIONEVALUATOR_MODE_PARSEONLY Then Return Null
			
			Select op
				
				' Equals operator
				Case ExpressionTokeniser_TokenType_Equal
				
					Return ScriptObjectFactory.NewBool(o = o2)	
				'	If o\m_Type = OBJ_STRING And o2\m_Type = OBJ_STRING Then Return ScriptObjectFactory.NewBool(o\m_ValueString = o2\m_ValueString)
				'	If o\m_Type = OBJ_BOOL And o2\m_Type = OBJ_BOOL Then Return ScriptObjectFactory.NewBool(o\m_ValueInt = o2\m_ValueInt)
				'	If o\m_Type = OBJ_INT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueInt = o2\m_ValueInt)
					
				'	If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat = o2\m_ValueFloat)
				'	If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat = Float(o2\m_ValueInt))
				'	If o\m_Type = OBJ_INT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(Float(o\m_ValueInt) = o2\m_ValueFloat)
					
					RuntimeError("Can't compare values")
				
				Case ExpressionTokeniser_TokenType_NotEqual
					Return ScriptObjectFactory.NewBool(o <> o2)
					
					'If o\m_Type = OBJ_STRING And o2\m_Type = OBJ_STRING Then Return ScriptObjectFactory.NewBool(o\m_ValueString <> o2\m_ValueString)
					'If o\m_Type = OBJ_BOOL And o2\m_Type = OBJ_BOOL Then Return ScriptObjectFactory.NewBool(o\m_ValueInt <> o2\m_ValueInt)
					'If o\m_Type = OBJ_INT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueInt <> o2\m_ValueInt)
					
					'If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat <> o2\m_ValueFloat)
					'If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat <> Float(o2\m_ValueInt))
					'If o\m_Type = OBJ_INT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(Float(o\m_ValueInt) <> o2\m_ValueFloat)
					
					RuntimeError("Can't compare values")
				
				Case ExpressionTokeniser_TokenType_LT
				
					Return ScriptObjectFactory.NewBool(Int(o.ToString()) < Int(o2.ToString()))
	
					'If o\m_Type = OBJ_STRING And o2\m_Type = OBJ_STRING Then Return ScriptObjectFactory.NewBool(o\m_ValueString < o2\m_ValueString)
					'If o\m_Type = OBJ_BOOL And o2\m_Type = OBJ_BOOL Then Return ScriptObjectFactory.NewBool(o\m_ValueInt < o2\m_ValueInt)
					'If o\m_Type = OBJ_INT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueInt < o2\m_ValueInt)
					
					'If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat < o2\m_ValueFloat)
					'If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat < Float(o2\m_ValueInt))
					'If o\m_Type = OBJ_INT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(Float(o\m_ValueInt) < o2\m_ValueFloat)
					
					RuntimeError("Can't compare values")
				
				Case ExpressionTokeniser_TokenType_GT
					Return ScriptObjectFactory.NewBool(Int(o.ToString()) > Int(o2.ToString()))
				'	If o\m_Type = OBJ_STRING And o2\m_Type = OBJ_STRING Then Return ScriptObjectFactory.NewBool(o\m_ValueString > o2\m_ValueString)
				'	If o\m_Type = OBJ_BOOL And o2\m_Type = OBJ_BOOL Then Return ScriptObjectFactory.NewBool(o\m_ValueInt > o2\m_ValueInt)
				'	If o\m_Type = OBJ_INT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueInt > o2\m_ValueInt)
					
				'	If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat > o2\m_ValueFloat)
				'	If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat > Float(o2\m_ValueInt))
					'If o\m_Type = OBJ_INT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(Float(o\m_ValueInt) > o2\m_ValueFloat)
					
					RuntimeError("Can't compare values")
				
				Case ExpressionTokeniser_TokenType_LE
					Return ScriptObjectFactory.NewBool(Int(o.ToString()) <= Int(o2.ToString()))
				rem
					If o\m_Type = OBJ_STRING And o2\m_Type = OBJ_STRING Then Return ScriptObjectFactory.NewBool(o\m_ValueString <= o2\m_ValueString)
					If o\m_Type = OBJ_BOOL And o2\m_Type = OBJ_BOOL Then Return ScriptObjectFactory.NewBool(o\m_ValueInt <= o2\m_ValueInt)
					If o\m_Type = OBJ_INT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueInt <= o2\m_ValueInt)
					
					If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat <= o2\m_ValueFloat)
					If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat <= Float(o2\m_ValueInt))
					If o\m_Type = OBJ_INT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(Float(o\m_ValueInt) <= o2\m_ValueFloat)
					
					end rem
					RuntimeError("Can't compare values")
				
				Case ExpressionTokeniser_TokenType_GE
				
					Return ScriptObjectFactory.NewBool(Int(o.ToString()) >= Int(o2.ToString()))
	
					rem
					If o\m_Type = OBJ_STRING And o2\m_Type = OBJ_STRING Then Return ScriptObjectFactory.NewBool(o\m_ValueString >= o2\m_ValueString)
					If o\m_Type = OBJ_BOOL And o2\m_Type = OBJ_BOOL Then Return ScriptObjectFactory.NewBool(o\m_ValueInt >= o2\m_ValueInt)
					If o\m_Type = OBJ_INT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueInt >= o2\m_ValueInt)
					
					If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat >= o2\m_ValueFloat)
					If o\m_Type = OBJ_FLOAT And o2\m_Type = OBJ_INT Then Return ScriptObjectFactory.NewBool(o\m_ValueFloat >= Float(o2\m_ValueInt))
					If o\m_Type = OBJ_INT And o2\m_Type = OBJ_FLOAT Then Return ScriptObjectFactory.NewBool(Float(o\m_ValueInt) >= o2\m_ValueFloat)
					end rem
					RuntimeError("Can't compare values")
				
			End Select
			
		EndIf
	
		Return o
		
	End Method
	
	Method ParseAddSubtract:ScriptObject()
		
		Local p0:Int	= Self.m_Tokeniser.CurrentPosition
		Local o:ScriptObject	= Self.ParseMulDiv()
		Local o2:ScriptObject
		Local p3:Int
		
		While(True)
			
			If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Plus Then
				
				Self.m_Tokeniser.GetNextToken()
				o2:ScriptObject 	= Self.ParseMulDiv()
				p3		= Self.m_Tokeniser.CurrentPosition
				
				If Self.m_EvalMode <> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
			
					If ScriptObject.CanAdd(o, o2) Then
						o = ScriptObject.AddObjects(o, o2)
					Else
						RuntimeError("Can't ADD")
					EndIf
				
				EndIf
				
			ElseIf Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Minus Then
				
				Self.m_Tokeniser.GetNextToken()
				o2:ScriptObject 	= Self.ParseMulDiv()
				p3		= Self.m_Tokeniser.CurrentPosition
				
				If Self.m_EvalMode <> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
					If ScriptObject.CanAdd(o, o2) Then
						o = ScriptObject.SubtractObjects(o, o2)
					Else
						RuntimeError("Can't SUBTRACT")
					EndIf
			
				EndIf
				
			Else
				Exit
			EndIf
			
		Wend
		
		Return o
	
	End Method
	
	Method ParseMulDiv:ScriptObject()
		
		Local p0:Int	= Self.m_Tokeniser.CurrentPosition
		Local o:ScriptObject	= Self.ParseValue()
		Local o2:ScriptObject
		Local p3:Int
		
		Repeat
			
			If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Mul Then
				
				Self.m_Tokeniser.GetNextToken()
				o2	= Self.ParseValue()
				p3	= self.m_Tokeniser.CurrentPosition
				
				If self.m_EvalMode <> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
					if ScriptObject.CanMultiply(o, o2) Then
						o = ScriptObject.MultiplyObjects(o, o2)
					Else 
						RuntimeError("Can't MULTIPLY")
					End If
					
				EndIf
				
			ElseIf Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Div Then
				
				Self.m_Tokeniser.GetNextToken()
				o2	= Self.ParseValue()
				p3	= Self.m_Tokeniser.CurrentPosition
				
				If o2 = Null Then Self._throwSyntaxError()
				
				If self.m_EvalMode <> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
					
					If ScriptObject.CanMultiply(o, o2) Then
						o = ScriptObject.DivideObjects(o, o2)
					Else 
						RuntimeError("Can't DIVIDE")
					End If			
					
				EndIf
				
			ElseIf  Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Mod Then
				
				Self.m_Tokeniser.GetNextToken()
				o2	= Self.ParseValue()
				p3	= self.m_Tokeniser.CurrentPosition
				
				If self.m_EvalMode <> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
					
					' Check for division by zero
				'	If (o2\m_Type = OBJ_INT And o2\m_ValueInt = 0) Or (o2\m_Type = OBJ_FLOAT And o2\m_ValueFloat = 0) Then
				'		RuntimeError("attempted mod by zero")
				'	EndIf
					
					If ScriptObject.CanMultiply(o, o2) Then
						o = ScriptObject.ModObjects(o, o2)
					Else 
						RuntimeError("Can't MOD")
					End If
					
				EndIf
				
			Else
				
				Exit
				
			EndIf
			
		Forever
		
		Return o
		
	End Method
	
	Method ParseConditional:ScriptObject()
		Throw "Not implemented :("
		Return Null
	End Method
	
	Method ParseValue:ScriptObject()
		
		' -- Setup
		Local val:ScriptObject
		Local p0:Int
		Local p1:Int
		
		' -- Plain string values
		If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_String Then
			val = ScriptObjectFactory.NewString(Self.m_Tokeniser.TokenText)
			Self.m_Tokeniser.GetNextToken()
			Return val
		EndIf
		
		' -- Plain number values
		If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Number Then
			
			Local number$	= Self.m_Tokeniser.TokenText
			
			p0	= self.m_Tokeniser.CurrentPosition
			Self.m_Tokeniser.GetNextToken()
			p1	= self.m_Tokeniser.CurrentPosition - 1
			
			' Check for fractions
			If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Dot Then
				number = number + "."
				Self.m_Tokeniser.GetNextToken()
				
				' Check there's a number after the decimal point
				If Self.m_Tokeniser.CurrentToken <> ExpressionTokeniser_TokenType_Number Then
					Self._throwSyntaxError()
				EndIf
				
				number = number + Self.m_Tokeniser.TokenText
				
				Self.m_Tokeniser.GetNextToken()
				
				' Check for error
				p1 = self.m_Tokeniser.CurrentPosition
				
				' Done
				Return ScriptObjectFactory.NewFloat(Float(number))
			
			' Integer
			Else
				Return ScriptObjectFactory.NewInt(Int(number))
			EndIf
			
		EndIf
		
		' -- Negative numbers
		If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Minus Then
			
			Self.m_Tokeniser.GetNextToken()
			
			' Unary minus
			p0	= self.m_Tokeniser.CurrentPosition
			val	= Self.ParseValue()
			p1	= self.m_Tokeniser.CurrentPosition
			
			If self.m_EvalMode <> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
				
				' Update object value
				'Select val\m_Type
			'		Case OBJ_INT	: val\m_ValueInt 	= -val\m_ValueInt
			'		Case OBJ_FLOAT	: val\m_ValueFloat 	= -val\m_ValueFloat
			'	End Select
			
				val = ScriptObject.SubtractObjects(ScriptObjectFactory.NewInt(0), val)
				
				Return val
				
			EndIf
			
			Return Null
			
		EndIf
		
		' Boolean "NOT"
		If Self.m_Tokeniser.IsKeyword("not") Then
			
			Self.m_Tokeniser.GetNextToken()
			
			p0	= self.m_Tokeniser.CurrentPosition
			val	= Self.ParseValue()
			p1	= self.m_Tokeniser.CurrentPosition
			
			If self.m_EvalMode <> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then
				
				' Update object value
				' TODO: Fix this
				val = ScriptObjectFactory.NewInt(Not(Int(val.m_Value.ToString())))
			'	val\m_ValueInt = Not(val\m_ValueInt)			
				Return val
				
			EndIf
			
			Return Null
			
		EndIf
		
		' Brackets
		If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_LeftParen Then
			
			Self.m_Tokeniser.GetNextToken()
			
			val	= Self.ParseExpression()
			
			If Self.m_Tokeniser.CurrentToken <> ExpressionTokeniser_TokenType_RightParen Then
				' Throw error
				RuntimeError("')' expected at " + self.m_Tokeniser.CurrentPosition)
			EndIf
			
			Self.m_Tokeniser.GetNextToken()
			Return val
			
		EndIf
		
		' Keywords (big chunk of code)
		If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Keyword Then
			
			p0 = self.m_Tokeniser.CurrentPosition 
			
			Local functionOrPropertyName$	= Self.m_Tokeniser.TokenText
			
			Select Lower(functionOrPropertyName)
				Case "if"		; Return Self.ParseConditional()
				Case "true"		; Self.m_Tokeniser.GetNextToken() ; Return ScriptObjectFactory.NewBool(True)
				Case "false"	; Self.m_Tokeniser.GetNextToken()  ; Return ScriptObjectFactory.NewBool(False)
			End Select
			
			' Switch off "ignore whitespace" as properties shouldn't contain spaces
			'this\m_Tokeniser\IgnoreWhitespace = False
			Self.m_Tokeniser.GetNextToken()
			
			Local args:TList	= New TList
			Local isFunction%	= False
			
			' Get the current property or function name
			If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_DoubleColon Then
				
				' Function
				isFunction = True		
				functionOrPropertyName = functionOrPropertyName + "::"
				Self.m_Tokeniser.GetNextToken()
				
				' Check the :: is followed by a keyword
				If Self.m_Tokeniser.CurrentToken <> ExpressionTokeniser_TokenType_Keyword Then
					RuntimeError("Function name expected")
				EndIf
				
				functionOrPropertyName = functionOrPropertyName + Self.m_Tokeniser.TokenText
				Self.m_Tokeniser.GetNextToken()
				
			Else
				
				' Property
				While(Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Dot Or Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Minus Or Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Keyword Or Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Number)
					functionOrPropertyName = functionOrPropertyName + Self.m_Tokeniser.TokenText
					Self.m_Tokeniser.GetNextToken()
				Wend
				
			EndIf
			
			' Switch whitespace back on
			Self.m_Tokeniser.IgnoreWhitespace = True
			
			' If we're at a space, get the next token
			If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_Whitespace Then
				Self.m_Tokeniser.GetNextToken()
			EndIf
			
			' -- Execute the function
			
			' TODO: Split this into a new method
			If isFunction Then
				
				' Check for opening bracket (for params)
				If Self.m_Tokeniser.CurrentToken <> ExpressionTokeniser_TokenType_LeftParen Then
					RuntimeError("'(' expected at " + self.m_Tokeniser.CurrentPosition)
				EndIf
				
				Self.m_Tokeniser.GetNextToken()
				
				' TODO: Fix function arguments
				Local currentArgument%			= 0
				Local parameterCount:Int		= Self._countFunctionParameters(functionOrPropertyName)
				
				' TODO: Replace with proper bug checking
'				If formalParameters = Null Then 
'					RuntimeError("Function '" + functionOrPropertyName + "' not found")
'				EndIf
				
				While (Self.m_Tokeniser.CurrentToken <> ExpressionTokeniser_TokenType_RightParen And Self.m_Tokeniser.CurrentToken <> ExpressionTokeniser_TokenType_EOF)
					
					If currentArgument > parameterCount Then
						RuntimeError("Function ~q" + functionOrPropertyName + "~q -- Too many parameters")
					EndIf
					
					' Only parse if we have parameters
					If parameterCount > 0 Then
						
						Local beforeArg%		= Self.m_Tokeniser.CurrentPosition
						Local e:ScriptObject	= Self.ParseExpression()
						Local afterArg%			= self.m_Tokeniser.CurrentPosition
						
						' Evaluate (will skip in parse only mode)
						If self.m_EvalMode <> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then 
							
							' Convert to the required param & add to the list of params 
							Local convertedValue:ScriptObject	= e
							
							args.AddLast(convertedValue.ToString())
							'args.AddLast(formalParameters.ValueAtIndex(currentArgument))
							
						EndIf
						
						currentArgument = currentArgument + 1
						
					EndIf
					
					' Check if we're at the end
					If Self.m_Tokeniser.CurrentToken = ExpressionTokeniser_TokenType_RightParen Then
						Exit
					EndIf
					
					' Check if there was no comma (syntax error)
					If Self.m_Tokeniser.CurrentToken <> ExpressionTokeniser_TokenType_Comma Then
						RuntimeError("',' expected at " + Self.m_Tokeniser.CurrentPosition + " -- found " + Self.m_Tokeniser.CurrentToken)
					EndIf
					
					Self.m_Tokeniser.GetNextToken()
					
				Wend
				
				If currentArgument < parameterCount Then
					RuntimeError("Function ~q" + functionOrPropertyName + "~q -- Not enough parameters")
				EndIf
				
				If Self.m_Tokeniser.CurrentToken <> ExpressionTokeniser_TokenType_RightParen Then
					RuntimeError("')' expected at " + self.m_Tokeniser.CurrentPosition)
				EndIf
				
				Self.m_Tokeniser.GetNextToken()
				
			EndIf
			
			' Either run a function or get a property value
			If self.m_EvalMode <> EXPRESSIONEVALUATOR_MODE_PARSEONLY Then 
				If isFunction
					Return Self.EvaluateFunction(functionOrPropertyName, args)
				Else
					Return Self.EvaluateProperty(functionOrPropertyName)
				EndIf
			Else
				' Return nothing if we're just checking syntax
				Return Null
			EndIf
			
		EndIf
		
		Return Null
		
	End Method
	
	Method EvaluateFunction:ScriptObject(functionName:String, argList:TList)
		
		' Get the function object
		Local func:ScriptFunction = scriptfunction(Self.m_RegisteredFunctions.ValueForKey(functionName))
		If func = Null Then Throw "No handler found for function '" + functionName + "'"
	
		Return func.__invoke(argList)
		
	End Method
	
	Method EvaluateProperty:ScriptObject(propertyName:String)
		Return ScriptObject(Self.m_Properties.ValueForKey(propertyName))
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal script stuff
	' ------------------------------------------------------------
	
	Method _countFunctionParameters:Int(functionName:String)
		Local func:ScriptFunction = scriptfunction(Self.m_RegisteredFunctions.ValueForKey(functionName))
		If func = Null Then Throw "No handler found for function '" + functionName + "'"
		
		Return func.m_Method.ArgTypes().Length
	End Method
	
	
	' ------------------------------------------------------------
	' -- Auto setup support
	' ------------------------------------------------------------
	
	Method __autoload(script:BuildScript)
		
		' Auto add functionset objects
		Local base:TTypeId = TTypeId.ForName("FunctionSet")
		For Local setType:TTypeId = EachIn base.DerivedTypes()
		
			' Create a function set
			Local set:FunctionSet	= FunctionSet(setType.NewObject())
			
			set._setProject(script:BuildScript)
			
			' Setup args
			Self.RegisterFunctionSet(set)
		Next
		
	End Method
	
	Function ParseMetaString:TMap(meta:String)
		
		Local metaData:TMap	      = New TMap
		
		Local currentField:String = ""
		Local currentValue:String = ""
		Local inString:Int        = False
		Local isField:Int         = True
		
		For Local pos:Int = 0 To meta.Length
			
			Local currentChar:String = Mid(meta, pos, 1) 'Chr(meta[pos])
			
			Select currentChar
				
				Case "="
					If Not(inString) Then isField = Not(isField)
					
				Case "~q"
					inString = Not(inString)
					
				Case " "
					' If not in a string, we're at the end of a field
					If inString = False Then
						metaData.Insert(currentField, currentValue)
						currentField = ""
						currentValue = ""
						isField = True
					Else
						If isField Then 
							currentField:+ currentChar	
						Else 
							currentValue:+ currentChar	
						End If
					End If
					
				Default
				
					' No special character - add to field name / value
					If isField Then 
						currentField:+ currentChar	
					Else 
						currentValue:+ currentChar	
					End If
					
			End Select
			
		Next
		
		' Add last field
		If currentField <> " " And currentField <> "" And isField = False Then
			metaData.Insert(currentField, currentValue)
		EndIf
			
		Return metaData
		
	End Function
	
	
	' ------------------------------------------------------------
	' -- Error handling
	' ------------------------------------------------------------
	
	Method _throwSyntaxError()
		Throw "Syntax error in expression: + ~q" + Self.m_Tokeniser.getExpressionText() + "~q"
	End Method
	
	' ------------------------------------------------------------
	' -- Creation / Destruction
	' ------------------------------------------------------------
	
	Function Create:ExpressionEvaluator(expression:String)
		
		Local this:ExpressionEvaluator	= New ExpressionEvaluator
		this.m_Tokeniser	= ExpressionTokeniser.Create(expression)
		Return this
		
	End Function

		' == debug
	Method __dumpProperties()
		For Local key:String = EachIn Self.m_Properties.Keys()
			Print LSet(key, 20) + " => " + Self.m_Properties.ValueForKey(key).ToString()
		Next
	End Method
	
	Method New()
		Self.m_RegisteredFunctions	= New TMap
		Self.m_Properties			= New TMap
		Self.m_EvalMode				= EXPRESSIONEVALUATOR_MODE_EVALUATE
	End Method
	
End Type
