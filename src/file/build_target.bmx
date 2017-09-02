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

	Field _name:String                  '''< The name of the target
	Field _dependsOn:String             '''< Any target this build target depends on
	Field _buildCommands:TList          '''< List of BuildCommand objects in this target
	Field _localProperties:TMAP         '''< Hash of project properties
	Field _description:String           '''< Description of what the target does
	Field _isHidden:Byte                '''< Is this a "hidden" task (won't show in --list)


	' ------------------------------------------------------------
	' -- Public querying
	' ------------------------------------------------------------

	''' <summary>Get the name of this target.</summary>
	Method getName:String()
		Return Self._name
	End Method

	''' <summary>Get the description for this target.</summary>
	Method getDescription:String()
		Return Self._description
	End Method

	''' <summary>Is this task hidden? Hidden tasks don't show up in --list.</summary>
	Method isHidden:Byte()
		Return Self._isHidden
	End Method

	''' <summary>Check if the target has a local property.</summary>
	''' <param name="propertyName">The name of the property to search for.</param>
	''' <return>True if property exists, false if not.</return>
	Method hasProperty:Byte(propertyName:String)
		Return (Self._localProperties.ValueForKey(propertyName) <> Null)
	End Method

	''' <summary>Get a list of target names that this target depends on.</summary>
	''' <return>Array of target names.</return>
	Method getDependencies:String[]()

		' Split dependencies into list
		Local targets:String[] = Self._dependsOn.Split(",")

		' Remove spaces from target names
		For Local i:Int = 0 To targets.Length - 1
			targets[i] = Trim(targets[i])
		Next

		Return targets

	End Method

	''' <summary>Get a list of all `BuildCommand` objects in this target.</summary>
	Method getBuildCommands:TList()
		Return Self._buildCommands
	End Method

	''' <summary>Gets the local properties for this target.</summary>
	Method getLocalProperties:TMap()
		Return Self._localProperties
	End Method

	Method hasDependencies:Byte()
		Return Self._dependsOn <> ""
	End Method


	' ------------------------------------------------------------
	' -- Public setters
	' ------------------------------------------------------------

	Method addCommand(cmd:BuildCommand)
		If cmd = Null Then Throw "Attempted to add an empty command"
		Self._buildCommands.AddLast(cmd)
	End Method

	Method setProperty(name:String, value:String)
		Self._localProperties.Insert(name, value)
	End Method


	' ------------------------------------------------------------
	' -- DEBUG
	' ------------------------------------------------------------

	Method __dump()
		Print "~tTarget: " + Self._name

		For Local cmd:BuildCommand	= EachIn Self._buildCommands
			cmd.__dump()
		Next

	End Method


	' ------------------------------------------------------------
	' -- Creation & Destruction
	' ------------------------------------------------------------

	Method New()
		Self._buildCommands   = New TList
		Self._localProperties = New TMap
	End Method

End Type
