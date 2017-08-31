SuperStrict

Import gman.zipengine
Import bah.libxml

Import sodaware.File_Util

'Import brl.reflection


Type Plugin
	
	Field IsActive:Int						' Whether Or Not the Plugin is active
	
	Field GUID:String						' Unique identifier of the plugin
	Field Name:String						' Name of the plugin
	Field Description:String				' A brief description of the plugin
	Field Version:String					' Version of the plugin
	Field Location:String					' Location of the plugin on disk
	Field FileHandle:Int					' Handle of the PAK that this plugin belongs to
	
	Field m_Resources:Int					''' StringHash of resource names -> file names
	
	'== BVM Fields =='
	Field m_BvmContext:Int					' Context that this module runs in
	Field m_BvmModule:Int					' ID of module in mem
	
	'== Function Handles =='
	Field fnc_OnInitialise:Int				' Called when plugin is first loaded.
	Field fnc_OnDispose:Int					' Called when plugin is being diposed
	Field fnc_onLoad:Int
	
	' Plugin Hooks
	Method onLoad()
		If fnc_onLoad Then
			Return
		End If
		
		DebugLog "On load loaded"
	End Method
	
	
End Type