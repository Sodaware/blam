' ------------------------------------------------------------------------------
' -- src/services/configuration_service.bmx
' --
' -- Service that maintains the application's configuration.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import sodaware.File_Util
Import sodaware.file_config
Import sodaware.file_config_iniserializer

Import "service.bmx"

Type ConfigurationService Extends Service

	Field _config:Config            '''< Internal configuration object
	Field _path:String              '''< Path to configuration file.


	' ------------------------------------------------------------
	' -- Configuration API
	' ------------------------------------------------------------

	''' <summary>Get a value from the configuration file.</summary>
	''' <param name="sectionName">The section the key belongs to.</param>
	''' <param name="keyName">The key name to retrieve.</param>
	''' <returns>
	''' The value for the section + key, or an empty string if not found.
	''' </returns>
	Method getKey:String(sectionName:String, keyName:String)
		Return Self._config.getKey(sectionName, keyName)
	End Method


	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method initialiseService()
		' Set default path if not passed in.
		If Self._path = "" Then Self._path = Self._getDefaultConfigPath()

		' Normalize the path.
		If RealPath(Self._path) <> Self._path Then Self._normalizePath()

		' Load configuration file.
		Self._loadConfig()

		' TODO: Check that important values are set
	End Method

	Method unloadService()
		Self._config = Null
		GCCollect()
	End Method


	' ------------------------------------------------------------
	' -- Creation
	' ------------------------------------------------------------

	Function Create:ConfigurationService(path:String)
		Local this:ConfigurationService = New ConfigurationService

		this._path = path

		Return this
	End Function


	' ------------------------------------------------------------
	' -- Internal helpers
	' ------------------------------------------------------------

	''' <summary>
	''' Get the full path to the default configuration file.
	'''
	''' Tests for `blam.ini`, then `blitzbuild.ini` in the application directory.
	''' </summary>
	Method _getDefaultConfigPath:String()
		' Test for configuration files in the application directory.
		If FILETYPE_FILE = FileType(File_Util.PathCombine(AppDir, "blam.ini")) Then
			Return File_Util.PathCombine(AppDir, "blam.ini")
		ElseIf FILETYPE_FILE = FileType(File_Util.PathCombine(AppDir, "blitzbuild.ini")) Then
			Return File_Util.PathCombine(AppDir, "blitzbuild.ini")
		EndIf

		Return ""
	End Method

	Method _normalizePath()
		Self._path = File_Util.PathCombine(LaunchDir, Self._path)
	End Method

	Method _loadConfig()
		Self._config = New Config
		IniConfigSerializer.Load(Self._config, Self._path)
	End Method

End Type
