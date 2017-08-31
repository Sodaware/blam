' ------------------------------------------------------------------------------
' -- src/expressions/script_function.bmx
' --
' -- Base type for functions that can be executed in an expression. Each script
' -- function must extend this type and 
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection

Import "script_object.bmx"
Import "../functions/function_set.bmx"


Type ScriptFunction

	Field m_FullName:String

	Field m_ParentSet:FunctionSet
	Field m_Method:TMethod
	

	Function Create:ScriptFunction(set:FunctionSet, handler:TMethod)
		Local this:ScriptFunction = New ScriptFunction	
		
		this.m_ParentSet	= set
		this.m_Method		= handler
		
		Return this
	End Function
	
	Method __invoke:ScriptObject(argList:TList)
		
		Local result:Object = Self.m_Method.Invoke(Self.m_ParentSet, argList.ToArray())
		Return ScriptObjectFactory.FromObject(result)
	
	End Method
	

	Method GetFullName:String()
		Return Self.m_FullName
	End Method

	Method GetArgList:TList()
		Return New TList
	End Method
	
	Method _getParam:Object(offset:Int)
	
	End Method
	
	Method Execute:ScriptObject()
		Return ScriptObjectFactory.NewInt(20)
	End Method
	
End Type
