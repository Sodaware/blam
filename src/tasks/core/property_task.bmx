' ------------------------------------------------------------------------------
' -- src/tasks/core/property_task.bmx
' --
' -- Set a property or load several from an ini file.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.File_INI
Import sodaware.Console_Color

Import "../build_task.bmx"
Import "../../core/exceptions.bmx"

Type PropertyTask Extends BuildTask
	
	Field name:String						'''< The name of the property.
	Field value:String						'''< The value of the property.
	Field dynamic:Int	= False				'''< [optional] If true, will parse property when used. Otherwise will parse when set.
	Field file:String	= ""				'''< [optional] If true, will load properties from an INI file.
	Field readonly:Int	= False				'''< [optional] If true, will mark the property as read only.
	
	
	' ------------------------------------------------------------
	' -- Task Execution
	' ------------------------------------------------------------
	
	Method execute()
	
		' TODO: Add support for read only properties
		' TODO: Add support for dynamic properties
	
		If Self.file Then 
			Self._loadPropertyFile()
		Else
			Self._setProperty(Self.name, Self.value)
		End If
	
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal - Loading property files
	' ------------------------------------------------------------
	
	Method _loadPropertyFile()
		
		' TODO: Check file can be found and throw error (if required)
		
		Local ini:File_Ini	= file_ini.LoadFile(Self.file)
		If ini = Null Then Throw FileLoadException.Create("Could not load property file: " + Self.file)
		
		For Local grp:TIniSection = EachIn ini.Sections._Sections
			
			For Local keyName:String = EachIn grp.Values.Keys()
				Self._setProperty(grp.name + "." + keyName, grp.GetValue(keyName))
			Next
		
		Next
		
	End Method
		
End Type
