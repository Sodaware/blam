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
	''' <returns>The current project name.</returns>
	Method getName:String()													{ name="project::get-name"}
		Return Self.getProject().getName()
	End Method

	''' <summary>Get the path of the current build file.</summary>
	''' <returns>Full path of current build file, minus the file name.</returns>
	Method getBuildfilePath:String()										{ name="project::get-buildfile-path" }
		Return ExtractDir(Self.getProject().getFilePath())
	End Method

	''' <summary>Get the full name of the current build file.</summary>
	''' <returns>Full build file name.</returns>
	Method getBuildfileName:String()										{ name="project::get-buildfile-name" }
		Return Self.getProject().getFilePath()
	End Method


	' ------------------------------------------------------------
	' -- Property Information
	' ------------------------------------------------------------

	''' <summary>Verifies that a project or current target has a property.</summary>
	''' <param name="propertyName">The property to find.</param>
	''' <returns>True if property found, false if not.</returns>
	Method propertyExists:Int(propertyName:String)							{ name="project::property-exists"}

		Local hasProperty:Byte = Self.getProject().hasProperty(propertyName)

		If Self.getProject().getCurrentTarget() <> Null Then
			hasProperty = hasProperty Or Self.getProject().getCurrentTarget().hasProperty(propertyName)
		End If

		Return hasProperty

	End Method


	' ------------------------------------------------------------
	' -- Deprecated functions
	' ------------------------------------------------------------

	Method _blitzbuild_propertyExists:Int(propertyName:String)				{ name="blitzbuild::property-exists" }
		Return Self.propertyExists(propertyName)
	End Method

End Type
