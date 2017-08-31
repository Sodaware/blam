' ------------------------------------------------------------------------------
' -- src/file/build_script.bmx
' --
' -- A format-agnostic representation of a build script.
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
Import "../types/base_type.bmx"

''' <summary>BlitzBuild build script.</summary>
Type BuildScript

	' Project Info
	Field m_ProjectName:String			'''< The name of the project
	Field m_FilePath:String				'''< Full path to the build file
	
	' Properties
	Field m_GlobalTasks:TList			'''< A list of tasks outside of the main task
	Field m_GlobalProperties:TMAP		'''< A DDS_ObjectHash of properties
	
	' Build targets
	Field m_BuildTargets:TMap			'''< Hash of targets
	Field m_DefaultTarget:String		'''< The name of the default target
	Field m_CurrentTarget:BuildTarget	'''< The current target being executed
	
	
	' ------------------------------------------------------------
	' -- Public Setters
	' ------------------------------------------------------------
	
	''' <summary>Check if a global property is set.</summary>
	''' <param name="propertyName">Name of the property to search for.</param>
	''' <return>True if the global property exists, false if not.</return>
	Method hasProperty:Int(propertyName:String)
		Return (Self.m_GlobalProperties.ValueForKey(propertyName) <> Null)
	End Method
	
	Method addGlobalCommand(task:BuildCommand)
		If task = Null Then Throw "Attempted to add NULL task"
		Self.m_GlobalTasks.AddLast(task)
	End Method
		
	Method addTarget(target:BuildTarget)
		If target = Null Then Throw "Attempted to add NULL target"
		Self.m_BuildTargets.Insert(target.getName().tolower(), target)
	End Method
	
	Method setProperty(name:String, value:String)
		Self.m_GlobalProperties.Insert(name, value)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Public Getters
	' ------------------------------------------------------------
	
	''' <summary>Get the name of the current project.</summary>
	Method getName:String()
		Return Self.m_ProjectName
	End Method
	
	''' <summary>Get the full path to the current build file.</summary>
	Method getFilePath:String()
		Return Self.m_FilePath
	End Method
	
	''' <summary>Get a build target by its name.</summary>
	''' <param name="targetName">The name of the target to retrieve.</param>
	Method getTarget:BuildTarget(targetName:String)
		Return BuildTarget(Self.m_BuildTargets.ValueForKey(targetName))
	End Method
	
	''' <summary>Get all properties set in the currently selected target.</summary>
	''' <return>A TMap of properties, or null if the target is invalid.</return>
	Method getCurrentTargetProperties:TMap()
		If Self.m_CurrentTarget = Null Then Return Null
		Return Self.m_CurrentTarget.getLocalProperties()
	End Method

	''' <summary>Get a list of all targets defined in this build file.</summary>
	''' <return>A TList of BuildTarget objects.</return>
	Method getTargets:TList()
		Local targets:TList = New TList
		For Local t:BuildTarget = EachIn Self.m_BuildTargets.Values()
			targets.AddLast(t)
		Next
		Return targets
	End Method
	
	
	' ------------------------------------------------------------
	' -- DEBUG
	' ------------------------------------------------------------

	Method __dump()
		Print "BuildScript: " + Self.m_ProjectName
		
		For Local targets:BuildTarget = EachIn Self.m_BuildTargets.Values()
			targets.__dump()
		Next
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Creation & Destruction
	' ------------------------------------------------------------
	
	Method New()
		Self.m_GlobalProperties	= New TMap
		Self.m_BuildTargets		= New TMap
		Self.m_GlobalTasks		= New TList
	End Method
	
End Type
