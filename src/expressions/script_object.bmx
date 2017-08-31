' ------------------------------------------------------------------------------
' -- src/expressions/script_object.bmx
' --
' -- Generic object used to represent values within scripts. Originally used 
' -- because BlitzPlus lacked reflection and various OO features.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection

Include "script_object_factory.bmx"

Const OBJECT_INT:Int	= 1
Const OBJECT_FLOAT:Int	= 2
Const OBJECT_STRING:Int = 4
Const OBJECT_BOOL:Int   = 8

Type ScriptObject
	
	Field m_Type:Int
	
	Field m_Value:Object
	
	Method ValueInt:Int()
		Return Int(m_Value.ToString())
	End Method

	Method ValueFloat:Float()
		Return Float(m_Value.ToString())
	End Method
	
	Method ValueString:String()
		Return m_Value.ToString()
	End Method

	Method ToString:String()
		Return Self.m_Value.ToString()
	End Method
			
	' TODO: Refactory these to remove crappy conversions
	Function AddObjects:ScriptObject(o1:ScriptObject, o2:ScriptObject)
		
		' Can always add strings
		If o1.m_Type = OBJECT_STRING Or o2.m_Type = OBJECT_STRING Then 
			Return ScriptObjectFactory.NewString(o1.ValueString() + o2.ValueString())
		EndIf
		
		' Adding ints
		If o1.m_Type = OBJECT_INT And o1.m_Type = OBJECT_INT Then
			Return ScriptObjectFactory.newint(Int(o1.m_Value.ToString()) + Int(o2.m_Value.ToString()))
		End If

		' Adding floats
		If o1.m_Type = OBJECT_FLOAT And o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) + Float(o2.m_Value.ToString()))
		End If
		
		' Adding mixed
		If o1.m_Type = OBJECT_FLOAT Or o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) + Float(o2.m_Value.ToString()))
		End If
					
		Return Null
		
	End Function
	
	Function SubtractObjects:ScriptObject(o1:ScriptObject, o2:ScriptObject)
		
		' Can always dubtract strings
		If o1.m_Type = OBJECT_STRING Or o2.m_Type = OBJECT_STRING Then 
			Return ScriptObjectFactory.NewString(String(o1.m_Value).Replace(String(o2.m_Value), ""))
		EndIf
		
		' Subtracting ints
		If o1.m_Type = OBJECT_INT And o1.m_Type = OBJECT_INT Then
			Return ScriptObjectFactory.newint(Int(o1.m_Value.ToString()) - Int(o2.m_Value.ToString()))
		End If

		' Subtracting floats
		If o1.m_Type = OBJECT_FLOAT And o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) - Float(o2.m_Value.ToString()))
		End If
		
		' Subtracting mixed
		If o1.m_Type = OBJECT_FLOAT Or o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) - Float(o2.m_Value.ToString()))
		End If
					
		Return Null
		
	End Function
	
	Function MultiplyObjects:ScriptObject(o1:ScriptObject, o2:ScriptObject)
		
		If o1.m_Type = OBJECT_INT And o1.m_Type = OBJECT_INT Then
			Return ScriptObjectFactory.newint(Int(o1.m_Value.ToString()) * Int(o2.m_Value.ToString()))
		End If

		' Subtracting floats
		If o1.m_Type = OBJECT_FLOAT And o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) * Float(o2.m_Value.ToString()))
		End If
		
		' Subtracting mixed
		If o1.m_Type = OBJECT_FLOAT Or o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) * Float(o2.m_Value.ToString()))
		End If
					
		Return Null
		
	End Function
	
	Function DivideObjects:ScriptObject(o1:ScriptObject, o2:ScriptObject)
		
		If o1.m_Type = OBJECT_INT And o1.m_Type = OBJECT_INT Then
			Return ScriptObjectFactory.newint(Int(o1.m_Value.ToString()) / Int(o2.m_Value.ToString()))
		End If

		' Subtracting floats
		If o1.m_Type = OBJECT_FLOAT And o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) / Float(o2.m_Value.ToString()))
		End If
		
		' Subtracting mixed
		If o1.m_Type = OBJECT_FLOAT Or o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) / Float(o2.m_Value.ToString()))
		End If
					
		Return Null
		
	End Function	
	
	Function ModObjects:ScriptObject(o1:ScriptObject, o2:ScriptObject)
		
		If o1.m_Type = OBJECT_INT And o1.m_Type = OBJECT_INT Then
			Return ScriptObjectFactory.newint(Int(o1.m_Value.ToString()) Mod Int(o2.m_Value.ToString()))
		End If

		' Subtracting floats
		If o1.m_Type = OBJECT_FLOAT And o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) Mod Float(o2.m_Value.ToString()))
		End If
		
		' Subtracting mixed
		If o1.m_Type = OBJECT_FLOAT Or o1.m_Type = OBJECT_FLOAT Then
			Return ScriptObjectFactory.NewFloat(Float(o1.m_Value.ToString()) Mod Float(o2.m_Value.ToString()))
		End If
					
		Return Null
		
	End Function
	
	Function CanAdd:Int(o1:ScriptObject, o2:ScriptObject)
		
		' Easy
		If o1.m_Type = o2.m_Type Then Return True
		If o1.m_Type + o2.m_Type = 3 Then Return True
		If o1.m_Type Or o2.m_Type = OBJECT_STRING Then Return True
		
		' Can't add
		Return False
	
	End Function

	Function CanMultiply:Int(o1:ScriptObject, o2:ScriptObject)
		
		If (o1.m_Type = o2.m_Type) And (o1.m_Type = OBJECT_INT Or o1.m_Type = OBJECT_FLOAT) Then Return True
		Return False
	
	End Function
	
	
End Type
