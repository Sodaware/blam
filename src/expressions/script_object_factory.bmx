' ------------------------------------------------------------------------------
' -- src/expressions/script_object_factory.bmx
' --
' -- Creates `ScriptObject` instances.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


Type ScriptObjectFactory
	
	Function FromObject:ScriptObject(val:Object)
		Local objectType:TTypeId = TTypeId.ForObject(val)
		Select objectType.Name().ToLower()
			Case "string"	; Return ScriptObjectFactory.NewString(String(val))
			Case "int"		; Return ScriptObjectFactory.NewInt(Int(val.ToString()))
			Case "float"	; Return ScriptObjectFactory.NewFloat(Float(val.ToString()))
		End Select
		
		Throw "Unknown type: " + objectType.Name()
	End Function

	Function NewBool:ScriptObject(val:Int)
		Local this:ScriptObject = New ScriptObject
		this.m_Type = OBJECT_BOOL
		this.m_Value = String(val)
		Return this
	End Function
	
	Function NewInt:ScriptObject(val:Int)
		Local this:ScriptObject = New ScriptObject
		this.m_Type = OBJECT_INT
		this.m_Value = String(val)
		Return this
	End Function

	Function NewFloat:ScriptObject(val:Float)
		Local this:ScriptObject = New ScriptObject
		this.m_Type = OBJECT_FLOAT
		this.m_Value = String(val)
		Return this
	End Function
	
	Function NewString:ScriptObject(val:String)
		Local this:ScriptObject = New ScriptObject
		this.m_Type = OBJECT_STRING
		this.m_Value = String(val)
		Return this
	End Function

End Type
