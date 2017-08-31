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

		' Load configuration file
		Self._config = New Config
		IniConfigSerializer.Load(Self._config, File_Util.pathcombine(AppDir, "blitzbuild.ini"))

		' TODO: Check that important values are set

	End Method
	
	Method unloadService()
		Self._config = Null
		GCCollect()
	End Method

End Type
