SuperStrict

Import brl.retro
Import koriolis.briskvm
Import sodaware.File_Util

Import "../service.bmx"
Import "plugin.bmx"

Import "../../scripting/blitzbuild_invoker_host.bmx"

Type PluginManager Extends Service
	
	Field _plugins:TList

	Method loadPlugins(pluginDirectory:String)
		
		' Iterate through files
		Local pluginDir:Int		= ReadDir(pluginDirectory)
		Local pluginFile:String = NextFile(pluginDir)
		
		While (pluginFile <> "")
		
			' Check it's not a directory command
			If pluginFile <> "." And pluginFile <> ".." Then
			
				' Check the file type
				If FileType(File_Util.PathCombine(pluginDirectory, pluginFile)) = FILETYPE_DIR Then
				
					' Check if we should ignore it
					If pluginFile <> ".svn" Then 
					
						' Directory - Load it
						Self.loadPlugins(File_Util.PathCombine(pluginDirectory, pluginFile))
					
					EndIf
				
				Else
				
					Local newPlugin:Plugin	= Null
					
					' Regular file - Check extension
					Select Lower(ExtractExt(pluginFile))
					
						' bbm = regular, bbp = compressed
						Case "bvm"
							DebugLog "   -- Adding plugin file: " + pluginFile
							newPlugin = Self.loadPluginFromFile(pluginDirectory + "/" + pluginFile)
						
						Case "bbp"
							DebugLog "   -- Adding plugin zip: " + pluginFile
							newPlugin = Self.loadPluginFromArchive(pluginDirectory + "/" + pluginFile)
					
					End Select
				
					If newPlugin <> Null Then Self.RegisterPlugin(newPlugin)
			
				EndIf
		
			EndIf
				
			' Get next file
			pluginFile = NextFile(pluginDir)
		Wend
		
		' Cleanup
		CloseDir(pluginDir);
		
	End Method
	
	Method registerPlugin(pluginObject:Plugin)
		Self._plugins.AddLast(pluginObject)
	End Method
	
		' ----- Plugin Creation ----- '
	
	Method loadPluginFromFile:Plugin(fileName:String)
		
		Local this:Plugin	= New Plugin
		
		this.m_BvmContext	= BVM_CreateContext()
		BVM_SelectContext(this.m_BvmContext)
		
		this.m_BvmModule	= BVM_LoadModule(fileName)
		
		If this.m_BvmModule = BVM_INVALID_MODULE Then 
			RuntimeError(BVM_GetLastErrorMsg())
		EndIf
		
		If Not BVM_MapModule(this.m_BvmContext, this.m_BvmModule) Then RuntimeError(BVM_GetLastErrorMsg())
		
		Local entry:Int = BVM_FindEntryPoint(this.m_BvmContext, this.m_BvmModule, "on_init")
		If entry = BVM_INVALID_ENTRY_POINT Then
			RuntimeError(BVM_GetLastErrorMsg())
		End If
		BVM_SelectEntryPoint(entry)
		
		' Test some stuff
		BVM_Invoke()
		BVM_PopInt()
		
		Return this
	
	End Method

	Method loadPluginFromArchive:Plugin(fileName:String)
		
'		Local this:Plugin = New Plugin
'		this._loadFromZip(fileName)
'		Return this
	
	End Method
	
	rem
	
	Method _loadFromZip:Int(fileName:String)
	
		' Get template definition file from zip
		Local zipIn:ZipReader = New ZipReader 
		zipIn.OpenZip(fileName)
		
		Local fileContents:String
		Local fileStream:TStream =		zipIn.ExtractFile("plugin.xml")

		While Not(fileStream.Eof())
			fileContents:+ fileStream.ReadLine()
		Wend
		
		zipIn.CloseZip()
		
		' Parse template doc
		Local fileIn:TxmlDoc         = TxmlDoc.parseDoc(fileContents)
		Local rootNode:TxmlNode      = fileIn.getRootElement()
		Local xpath:TxmlXPathContext = fileIn.newXPathContext()
		
		If rootNode.getChildren().Count() = 0 Then Return False
		
		' Load info
		Self.Name            = xpath.evalExpression("/Plugin/Info/Name").castToString()
		Self.Description     = xpath.evalExpression("/Plugin/Info/Description").castToString()
		Self.Version         = xpath.evalExpression("/Plugin/Info/Version").castToString()
	
		' Load files
		zipIn.OpenZip(fileName)
		Local files:TxmlNodeSet = xpath.evalExpression("/Plugin/Files/File").getNodeSet()
		For Local fileNode:TxmlNode = EachIn files.getNodeList()
		'	Print "Has file: " + fileNode.getContent()
			
			Self._loadScript(zipIn, fileNode.getContent())
			
			' Load the script file
			
			'Local tmp:FileSubTemplate = FileSubTemplate.Create(fileNode.getAttribute("name"), fileNode.getContent())
			'If tmp Then Self.m_FileTemplates.AddLast(tmp)
		Next
		zipIn.CloseZip()
		
	End Method
	
	
	
	Method _loadScript(zipIn:ZipReader, fileName:String)
		
		Local tempName:String = file_util.PathCombine(File_Util.GetTempDir(), "temp_" + filename)
		zipIn.ExtractFileToDisk(fileName, tempName)
		
		Self.m_BvmContext	= BVM_CreateContext()
		Self.m_BvmModule	= BVM_LoadModule(tempName)
		
		DeleteFile(tempName)
	end rem
	rem
	Local hModule2% = BVM_LoadModule("Triangles.bvm") ; BVM_CheckError()()

' We create a new execution context. An execution context holds the current state of execution.
Local hContext% = BVM_CreateContext() ; BVM_CheckError()()

' We map the modules to this context
BVM_MapModule(hContext, hModule1) ; BVM_CheckError()()
BVM_MapModule(hContext, hModule2) ; BVM_CheckError()()

' We get "entry point" handles for the functions we want to execute :
' 	Find the function "doIt_1()" of the module hModule1 in the context hContext
Local hEntryPoint1% = BVM_FindEntryPoint(hContext, hModule1, "doIt_1")  ; BVM_CheckError()()

' 	Find the function "doIt_2()" of the module hModule1 in the context hContext
Local hEntryPoint2% = BVM_FindEntryPoint(hContext, hModule2, "doIt_2")  ; BVM_CheckError()()

' We select the current execution context
BVM_SelectContext(hContext) ; BVM_CheckError()()

' We select the entry point corresponding to doIt_1() in the module "Balls.bvm"
BVM_SelectEntryPoint(hEntryPoint1) ; BVM_CheckError()()

' We run the code (that is, we execute the code of the selected function of the selected context,
' which is here the function doIt_1() of the module "Balls.bvm"
BVM_Invoke() ; BVM_CheckError()()
	end rem
	
	'End Method
	
	Method initialiseService()
	
		Self._plugins = New TList
	
		DebugLog "Initializing plugin service"
		
		DebugLog " -- setting up bvm"
		BVM_SetLibSearchFolders("lib")
		
		DebugLog " -- scanning for plugins"
		Self.loadPlugins(File_Util.PathCombine(AppDir, "plugins/"))
		
	End Method
	
	Method UnloadService()
		
	End Method
	
End Type
