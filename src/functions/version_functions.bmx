' ------------------------------------------------------------------------------
' -- src/functions/version_functions.bmx
' --
' -- Functions for working with version numbers.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro

Import "function_set.bmx"

Type VersionFunctions Extends FunctionSet
	
	' -- Part offset functions
	Const VERSION_MAJOR:Int 	= 0
	Const VERSION_MINOR:Int		= 1
	Const VERSION_BUILD:Int		= 2
	Const VERSION_REVISION:Int	= 3
	
	
	' ------------------------------------------------------------
	' -- Version Parts
	' ------------------------------------------------------------
	
	''' <summary>Gets the "major" part of a version number (the first part).</summary>
	''' <param name="version">The version string to use.</param>
	''' <returns>"Major" part of version string, or 0 if not found.</returns>
	Method GetMajor:Int(version:String)					{ name="version::get-major" }
		Return VersionFunctions._getVersionPart(version, VERSION_MAJOR)	
	End Method
	
	''' <summary>Gets the "minor" part of a version number (the second part).</summary>
	''' <param name="version">The version string to use.</param>
	''' <returns>"Minor" part of version string, or 0 if not found.</returns>
	Method GetMinor:Int(version:String)					{ name="version::get-minor" }
		Return VersionFunctions._getVersionPart(version, VERSION_MINOR)	
	End Method
	
	''' <summary>Gets the "build" part of a version number (the third part).</summary>
	''' <param name="version">The version string to use.</param>
	''' <returns>"Build" part of version string, or 0 if not found.</returns>
	Method GetBuild:Int(version:String)					{ name="version::get-build" }
		Return VersionFunctions._getVersionPart(version, VERSION_BUILD)	
	End Method
	
	''' <summary>Gets the "revision" part of a version number (the fourth part).</summary>
	''' <param name="version">The version string to use.</param>
	''' <returns>"Revision" part of version string, or 0 if not found.</returns>
	Method GetRevision:Int(version:String)				{ name="version::get-revision" }
		Return VersionFunctions._getVersionPart(version, VERSION_REVISION)	
	End Method
	
	
	' ------------------------------------------------------------
	' -- Comparisons
	' ------------------------------------------------------------
	
	''' <summary>Checks if v1 is newer than v2.</summary>
	''' <param name="v1">First version number.</param>
	''' <param name="v2">Second version number.</param>
	''' <returns>True if v1 is newer, false if not.</returns>
	Method IsNewer:Int(v1:String, v2:String)			{ name="version::is-newer" }
		
		If v1 = v2 Then Return False
		
		' -- Get version parts
		Local v1_major:Int		= VersionFunctions._getVersionPart(v1, VERSION_MAJOR)
		Local v1_minor:Int		= VersionFunctions._getVersionPart(v1, VERSION_MINOR)
		Local v1_build:Int		= VersionFunctions._getVersionPart(v1, VERSION_BUILD)
		Local v1_revision:Int	= VersionFunctions._getVersionPart(v1, VERSION_REVISION)
		
		Local v2_major:Int		= VersionFunctions._getVersionPart(v2, VERSION_MAJOR)
		Local v2_minor:Int		= VersionFunctions._getVersionPart(v2, VERSION_MINOR)
		Local v2_build:Int		= VersionFunctions._getVersionPart(v2, VERSION_BUILD)
		Local v2_revision:Int	= VersionFunctions._getVersionPart(v2, VERSION_REVISION)
		
		' -- Compare
		If v1_major < v2_major Then Return False 
		If v1_minor < v2_minor Then Return False
		If v1_build < v2_build Then Return False
		If v1_revision < v2_revision Then Return False
		
		Return True
		
	End Method

	''' <summary>Checks if v1 is older than v2.</summary>
	''' <param name="v1">First version number.</param>
	''' <param name="v2">Second version number.</param>
	''' <returns>True if v1 is older, false if not.</returns>
	Method IsOlder:Int(v1:String, v2:String)			{ name="version::is-older" }
		If v1 = v2 Then Return False
		
		Return Not(Self.IsNewer(v1, v2))
	End Method
	
	''' <summary>Checks if v1 is equal to v2.</summary>
	''' <param name="v1">First version number.</param>
	''' <param name="v2">Second version number.</param>
	''' <returns>True if v1 is equal to v2, false if not.</returns>
	Method IsEqual:Int(v1:String, v2:String)			{ name="version::is-equal" }
		Return (v1 = v2)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal helpers
	' ------------------------------------------------------------
	
	''' <summary>Gets part of a version string.</summary>
	Function _getVersionPart:Int(version:String, offset:Int)
		
		' Split into version parts
		Local parts:String[]	= version.Split(".")
	
		' Get the major (part 1)
		If parts.Length > offset Then Return Int(parts[offset])
		
		Return 0
		
	End Function
	
End Type
