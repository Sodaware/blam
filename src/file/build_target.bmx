' ------------------------------------------------------------------------------
' -- src/file/build_target.bmx
' --
' -- Holds all the information about a single target within a build file. This
' -- includes local properties, a list of build commands and a list of targets
' -- that must be executed first.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map

Import "build_command.bmx"

Type BuildTarget

	Field m_Name:String					'''< The name of the target
	Field m_DependsOn:String			'''< Any target this build target depends on
	Field m_BuildCommands:TList			'''< List of BuildCommand objects in this target
	Field m_LocalProperties:TMAP		'''< Hash of project properties
	Field m_Description:String			'''< Description of what the target does
	Field m_IsHidden:Byte				'''< Is this a "hidden" task (won't show in --list)
	
	
	' ------------------------------------------------------------
	' -- Public querying
	' ------------------------------------------------------------
	
	''' <summary>Get the name of this target.</summary>
	Method getName:String()
		Return Self.m_Name
	End Method
	
	Method isHidden:Byte()
		Return Self.m_IsHidden
	End Method
	
	''' <summary>Check if the target has a local property.</summary>
	''' <param name="propName">The name of the property to search for.</param>
	''' <return>True if property exists, false if not.</return>
	Method hasProperty:Int(propName:String)
		Return (Self.m_LocalProperties.ValueForKey(propName) <> Null)
	End Method
	
	''' <summary>Get a list of target names that this target depends on.</summary>
	''' <return>Array of target names.</return>
	Method getDependencies:String[]()
		
		' Split dependencies into list
		Local targets:String[] = Self.m_DependsOn.Split(",")
		
		' Remove spaces from target names
		For Local i:Int = 0 To targets.Length - 1
			targets[i] = Trim(targets[i])
		Next
		
		Return targets
		
	End Method
	
	''' <summary>Gets the local properties for this target.</summary>
	Method getLocalProperties:TMap()
		Return Self.m_LocalProperties
	End Method
	
	Method hasDependencies:Byte()
		Return Self.m_DependsOn <> ""
	End Method
	
	
	' ------------------------------------------------------------
	' -- Public setters
	' ------------------------------------------------------------
	
	Method addCommand(cmd:BuildCommand)
		If cmd = Null Then Throw "Attempted to add an empty command"
		Self.m_BuildCommands.AddLast(cmd)
	End Method

	Method setProperty(name:String, value:String)
		Self.m_LocalProperties.Insert(name, value)
	End Method
	
	
	' ------------------------------------------------------------
	' -- DEBUG
	' ------------------------------------------------------------
	
	Method __dump()
		Print "~tTarget: " + Self.m_Name
		
		For Local cmd:BuildCommand	= EachIn Self.m_BuildCommands
			cmd.__dump()
		Next
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation & Destruction
	' ------------------------------------------------------------
	
	Method New()
		Self.m_BuildCommands	= New TList
		Self.m_LocalProperties	= New TMap
	End Method
		
End Type
