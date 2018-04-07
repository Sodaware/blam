' ------------------------------------------------------------------------------
' -- src/file/build_script_loader.bmx
' --
' -- Handles loading of build scripts. Attempts to find a serializer for the
' -- build scrupt and loads it.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.reflection

Import "build_script.bmx"

' TODO: Import all serializers here, or in the main app?
Import "serializers/build_script_serializer.bmx"
Import "serializers/maxml_build_script_serializer.bmx"

Type BuildScriptLoader
	
	''' <summary>Load a build script from a filename.</summary>
	''' <param name="fileName">The name of the build script to load.</param>
	''' <return>The loaded script, or null if the file could not be loaded.</return>
	Function LoadScript:BuildScript(fileName:String)
		
		If FileType(fileName) <> FILETYPE_FILE Then Throw "Build script file not found!"
		
		' Get all serializers
		Local serializerBaseType:TTypeId = TTypeId.ForName("BuildScriptSerializer")
		
		' Attempt to load file with each serializer - return as soon as it succeeds
		For Local serializerType:TTypeId = EachIn serializerBaseType.DerivedTypes()
			Local serializer:BuildScriptSerializer = BuildScriptSerializer(serializerType.NewObject())
			If serializer.canLoad(fileName) Then Return serializer.loadFile(fileName)
		Next
		
		' No valid serializer found
		' TODO: Should it throw an exception here?
		Return Null
		
	End Function
	
End Type
