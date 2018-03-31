' ------------------------------------------------------------------------------
' -- src/core/app.bmx
' --
' -- Main application logic. Handles pretty much everything.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.Console_Color
Import brl.reflection
Import brl.retro

' -- Application info & console
Import "../assembly_info.bmx"
Import "console_options.bmx"

' -- Services
Import "../service_manager.bmx"
Import "../services/configuration_service.bmx"
Import "../services/task_manager/task_manager_service.bmx"

' -- Build script
Import "project_builder.bmx"
Import "../file/build_script_loader.bmx"
Import "../file/build_script.bmx"


''' <summary>Main BlitzBuild application.</summary>
Type App
	
	Field _options:ConsoleOptions			'''< Command line options
	Field _services:ServiceManager			'''< Application services
	Field _exitCode:Int						'''< Code to return to application
	
	
	' ------------------------------------------------------------
	' -- Main application entry
	' ------------------------------------------------------------
	
	''' <summary>Application entry point.</summary>
	Method run:Int()
	
		' -- Setup the app
		Self._setup()

        ' -- Setup output options.
        If Self._options.Bland Then
            Console_Color_DisableFormatting()
        End If

		' -- Show application header (if not hidden)
		If Not(Self._options.NoLogo) Then Self.writeHeader()
		
		' -- Show help message if requested - quit afterwards
		If True = Self._options.Help Then
			Self._options.showHelp()
			Return Self._shutdown()
		End If
		
		' TODO: Check for a lack of build arguments here - show help if required
			
		' -- Add standard services to ServiceManager
		Self._services.AddService(New ConfigurationService)
		Self._services.AddService(New TaskManagerService)
		
		' -- Initialise the services
		Self._services.initaliseServices()
		
		' -- Run the build script
		Self._execute()
		
		' -- Cleanup and return
		Self._shutdown()
		
		Return Self._exitCode
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Private execution
	' ------------------------------------------------------------
	
	''' <summary>Executes the selected build script & target.</summary>
	Method _execute()
		
		Local buildFile:String	= Self._options.File
		If buildFile = "" Then buildFile = File_Util.PathCombine(LaunchDir, "build.xml")
		
		PrintC("Build file: %w" + buildFile + "%n~n")
		
		' -- Load the build file
		Local script:BuildScript	= BuildScriptLoader.LoadScript(buildFile)

		' -- Create a project builder
		Local builder:ProjectBuilder = New ProjectBuilder
		
		' -- Populate its options
		builder.setServiceManager(Self._services)
		
		' - Set build file
		builder.setScript(script)
		
		' - List?
		If Self._options.List Then
			Self.listTargets(script)
			Return
		End If
		
		' - Set build target 
		If Self._options.Target <> "" Then	builder.setTarget(Self._options.Target)
		If Self._options.Target = "" And Self._options.countarguments() > 0 Then
			builder.setTarget(Self._options.GetArgument(0))
		End If
	
		' - Add properties from the command line
		If Self._options.Prop <> Null Then 
			For Local item:String = EachIn Self._options.Prop.Keys()
				builder.setGlobalProperty(item, String(Self._options.Prop.ValueForKey(item)))
			Next
		EndIf
				
		' - Execute
		Try
			builder.run()
		Catch e:Object
			PrintC("%RBuild Error: %r" + e.ToString() + "%n")
			Self._exitCode = 1
		End Try
		
		' -- Write the build log (if required)
				
	End Method
	
	
	' ------------------------------------------------------------
	' -- Output methods
	' ------------------------------------------------------------
	
	''' <summary>Writes the application header.</summary>
	Method writeHeader()
		
		PrintC "%gBlitzBuild " + AssemblyInfo.Version + " (Released: " + AssemblyInfo.Date + ")"
		PrintC "(C)opyright 2006-2017 Sodaware"
		PrintC "%chttps://sodaware.net/dev/tools/blam/%n"
		PrintC ""
		
	End Method
	
	Method listTargets(file:BuildScript)
	
		' [todo] - Also display subTargets (any target which is not included in a "dependson")
	
		' Default target
		PrintC "Default target:"
		PrintC "--------------------------------------------------"
		PrintC " " + file.getDefaultTargetName() + "~n"
		
		PrintC "Main targets:"
		PrintC "--------------------------------------------------"
	
		' Get longest string
		' [todo] - Extract this
		Local longestString:String = ""
		For Local target:BuildTarget = EachIn file.getTargets()
			If target.isHidden() Then Continue
			If target.getName().Length > longestString.Length Then
				longestString = target.getName()
			End If
		Next
		
		For Local target:BuildTarget = EachIn file.getTargets()
			If target.isHidden() Then Continue
			WriteC " " + LSet(target.getName(), longestString.Length)
			WriteC "  " + target.getDescription()
			PrintC 
		Next
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Application setup & shutdown
	' ------------------------------------------------------------
	
	Method _setup()
	
		' Get command line options
		Self._options = New ConsoleOptions
		
		' Setup service manager
		Self._services = New ServiceManager
		
	End Method
	
	Method _shutdown:Int()
		Self._services.stopServices()
	End Method
	
	
	' ------------------------------------------------------------
	' -- Construction / destruction
	' ------------------------------------------------------------
	
	Function Create:App()
		Local this:App	= New App
		Return this
	End Function
	
End Type
