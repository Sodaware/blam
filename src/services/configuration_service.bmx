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

	Field m_Config:Config			'''< Internal configuration object
	
	
	' ------------------------------------------------------------
	' -- Configuration API
	' ------------------------------------------------------------
	
	Method getKey:String(sectionName:String, keyName:String)
		Return Self.m_Config.getKey(sectionName, keyName)
	End Method
	
	
	' ------------------------------------------------------------
	' -- Standard service methods
	' ------------------------------------------------------------

	Method InitialiseService()
		
		' Load configuration file
		Self.m_Config	= New Config
		IniConfigSerializer.Load(Self.m_Config, File_Util.pathcombine(AppDir, "blitzbuild.ini"))
		
		' TODO: Check that important values are set
		
	End Method
	
	Method UnloadService()
		
		' Save settings
		Self.m_Config = Null
		GCCollect()
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction & Destruction
	' ------------------------------------------------------------
	
	Method New()
	
	End Method

End Type
