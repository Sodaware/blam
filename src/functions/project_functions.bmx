' ------------------------------------------------------------------------------
' -- src/functions/project_functions.bmx
' --
' -- Functions for getting information about the current blam project.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "function_set.bmx"

Type ProjectFunctions Extends FunctionSet
	
	
	' ------------------------------------------------------------
	' -- Project Information
	' ------------------------------------------------------------
	
	''' <summary>Gets the name of the current project.</summary>
	''' <returns>Project name</returns>
	Method GetName:String()													{ name="project::get-name"}
		Return Self.GetProject().getName()
	End Method
	
	''' <summary>Get the path of the current build file.</summary>
	''' <returns>Path of current build file.</returns>
	Method GetBuildfilePath:String()										{ name="project::get-buildfile-path" }
		Return ExtractDir(Self.GetProject().getFilePath())
	End Method
	
	''' <summary>Get the full name of the current build file.</summary>
	''' <returns>Full build file name.</returns>
	Method GetBuildfileName:String()										{ name="project::get-buildfile-name" }
		Return Self.GetProject().getFilePath()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Property Information
	' ------------------------------------------------------------

	''' <summary>Verifies that a project or current target has a property.</summary>
	''' <param name="propertyName">The property to find.</param>
	''' <returns>True if property found, false if not.</returns>
	Method PropertyExists:Int(propertyName:String)							{ name="project::property-exists"}
		
		Local hasProperty:Int	= False
		hasProperty = hasProperty Or Self.GetProject().hasProperty(propertyName)
		
		If Self.GetProject().getCurrentTarget() <> Null Then
			hasProperty = hasProperty Or Self.GetProject().getCurrentTarget().hasProperty(propertyName)			
		End If
		
		Return hasProperty			
			
	End Method
	
	
	' ------------------------------------------------------------
	' -- Deprecated functions
	' ------------------------------------------------------------
	
	Method _blitzBuild_PropertyExists:Int(propertyName:String)				{ name="blitzbuild::property-exists" }
		Return Self.PropertyExists(propertyName)
	End Method	
	
End Type
