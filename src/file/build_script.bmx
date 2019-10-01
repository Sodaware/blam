' ------------------------------------------------------------------------------
' -- src/file/build_script.bmx
' --
' -- A format-agnostic representation of a build script. A build script os made
' -- up of targets and properties.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.linkedlist

Import "build_target.bmx"
Import "build_node.bmx"

''' <summary>BlitzBuild build script.</summary>
Type BuildScript

	' Project Info
	Field _projectName:String           '''< The name of the project
	Field _filePath:String              '''< Full path to the build file

	' Properties
	Field _globalTasks:TList            '''< A list of tasks outside of the main task
	Field _globalProperties:TMap        '''< A map of property name => value

	' Build targets
	Field _buildTargets:TMap            '''< Hash of target name => BuildTarget
	Field _defaultTarget:String         '''< The name of the default target
	Field _currentTarget:BuildTarget    '''< The current target being executed


	' ------------------------------------------------------------
	' -- Public Setters
	' ------------------------------------------------------------

	''' <summary>Check if a global property is set.</summary>
	''' <param name="propertyName">Name of the property to search for.</param>
	''' <return>True if the global property exists, false if not.</return>
	Method hasProperty:Byte(propertyName:String)
		Return (Self._globalProperties.ValueForKey(propertyName) <> Null)
	End Method

	Method addGlobalCommand(task:BuildCommand)
		If task = Null Then Throw "Attempted to add NULL task"
		Self._globalTasks.AddLast(task)
	End Method

	Method addTarget(target:BuildTarget)
		If target = Null Then Throw "Attempted to add NULL target"
		Self._buildTargets.Insert(target.getName().tolower(), target)
	End Method

	Method setProperty(name:String, value:String)
		Self._globalProperties.Insert(name, value)
	End Method


	' ------------------------------------------------------------
	' -- Public Getters
	' ------------------------------------------------------------

	''' <summary>Get the name of the current project.</summary>
	Method getName:String()
		Return Self._projectName
	End Method

	''' <summary>Get the full path to the current build file.</summary>
	Method getFilePath:String()
		Return Self._filePath
	End Method

	''' <summary>Get a list of all global tasks in the build script.</summary>
	Method getGlobalTasks:TList()
		Return Self._globalTasks
	End Method

	''' <summary>Get all global properties for the build script.</summary>
	Method getGlobalProperties:TMap()
		Return Self._globalProperties
	End Method

	''' <summary>Get the default build target for this script.</summary>
	Method getDefaultTargetName:String()
		Return Self._defaultTarget
	End Method

	''' <summary>Get a build target by its name.</summary>
	''' <param name="targetName">The name of the target to retrieve.</param>
	Method getTarget:BuildTarget(targetName:String)
		Return BuildTarget(Self._buildTargets.ValueForKey(targetName))
	End Method

	''' <summary>Get the currently executing build target.</summary>
	Method getCurrentTarget:BuildTarget()
		Return Self._currentTarget
	End Method

	''' <summary>Get all properties set in the currently selected target.</summary>
	''' <return>A TMap of properties, or null if the target is invalid.</return>
	Method getCurrentTargetProperties:TMap()
		If Self._currentTarget = Null Then Return Null
		Return Self._currentTarget.getLocalProperties()
	End Method

	''' <summary>Get a list of all targets defined in this build file.</summary>
	''' <return>A TList of BuildTarget objects.</return>
	Method getTargets:TList()
		Local targets:TList = New TList
		For Local t:BuildTarget = EachIn Self._buildTargets.Values()
			targets.AddLast(t)
		Next
		Return targets
	End Method

	''' <summary>Set the current build target.</summary>
	Method setCurrentTarget(target:BuildTarget)
		Self._currentTarget = target
	End Method


	' ------------------------------------------------------------
	' -- DEBUG
	' ------------------------------------------------------------

	Method __dump()
		Print "BuildScript: " + Self._projectName
		For Local targets:BuildTarget = EachIn Self._buildTargets.Values()
			targets.__dump()
		Next
	End Method


	' ------------------------------------------------------------
	' -- Creation & Destruction
	' ------------------------------------------------------------

	Method New()
		Self._globalProperties  = New TMap
		Self._buildTargets      = New TMap
		Self._globalTasks       = New TList
	End Method

End Type
