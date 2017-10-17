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
	Field required:Byte = True				'''< [optional] If true, will fail if the property file is not found.
	
	
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

		Local ini:IniFile = File_Ini.LoadFile(Self.file)
		If ini = Null Then
			If Self.required Then
				Throw FileLoadException.Create("Could not load property file: " + Self.file)
			EndIf
			Return
		EndIf

		For Local section:IniFileSection = EachIn ini.getSections()
			For Local keyName:String = EachIn section.getKeyNames()
				Self._setProperty(section.getName() + "." + keyName, section.getValue(keyName))
			Next
		Next

	End Method

End Type
