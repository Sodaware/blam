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


''' <summary>Main blam application.</summary>
Type App
	Field _options:ConsoleOptions               '''< Command line options
	Field _services:ServiceManager              '''< Application services
	Field _exitCode:Int                         '''< Code to return to application

	Field _configService:ConfigurationService   '''< Holds global configuration info.
	Field _taskService:TaskManagerService       '''< Holds information about available tasks.


	' ------------------------------------------------------------
	' -- Main application entry
	' ------------------------------------------------------------


	''' <summary>Application entry point.</summary>
	Method run:Int()

		' -- Setup the app.
		Self._setup()

		' -- Setup output options.
		If Self._options.Bland Then
			Console_Color_DisableFormatting()
		End If

		' -- Show version and quit if requested.
		If Self._options.Version Then
			Print(AssemblyInfo.Name + " " + AssemblyInfo.Version)

			Return Self._shutdown()
		End If

		' -- Show application header (if not hidden).
		If Not(Self._options.NoLogo) Then Self.writeHeader()

		' -- Show help message if requested - quit afterwards.
		If True = Self._options.Help Then
			Self._options.showHelp()

			Return Self._shutdown()
		End If

		' TODO: Check for a lack of build arguments here - show help if required

		' -- Add standard services to ServiceManager.
		Self._configService = ConfigurationService.Create(Self._options.Config)
		Self._taskService   = New TaskManagerService

		Self._services.addService(Self._configService)
		Self._services.addService(Self._taskService)

		' -- Initialise the services.
		Self._services.initaliseServices()

		' -- Run setup wizard if no configuration.
		If Not Self._configService.isAppConfigured() Then
			Local result:Byte = Self._runConfigurationWizard()
			If Not result Then
				Self._shutdown()
				Self._exitCode = -1

				Return Self._exitCode
			EndIf
		EndIf

		' -- Run the build script.
		Self._execute()

		' -- Cleanup and return.
		Self._shutdown()

		Return Self._exitCode

	End Method


	' ------------------------------------------------------------
	' -- Private execution
	' ------------------------------------------------------------

	''' <summary>Executes the selected build script & target.</summary>
	Method _execute()

		' Get the build file name.
		Local buildFile:String = Self._getBuildfilePath()

		PrintC("Build file: %w" + buildFile + "%n~n")

		' Load the build file.
		Local script:BuildScript = BuildScriptLoader.LoadScript(buildFile)

		' List targets and quit if user requested them.
		If Self._options.List Then
			Self.listTargets(script)
			Return
		End If

		' Create and configure project builder.
		Local builder:ProjectBuilder = ProjectBuilder.Create(script)
		builder.setServiceManager(Self._services)

		' Set build target.
		If Self._options.Target <> "" Then
			builder.setTarget(Self._options.Target)
		End If

		If Self._options.Target = "" And Self._options.countArguments() > 0 Then
			builder.setTarget(Self._options.getArgument(0))
		End If

		' Add properties from the command line.
		If Self._options.Prop <> Null Then
			For Local item:String = EachIn Self._options.Prop.Keys()
				builder.setGlobalProperty(item, String(Self._options.Prop.ValueForKey(item)))
			Next
		EndIf

		' Execute the build script..
		Try
			builder.run()
		Catch e:Object
			PrintC("%RBuild Error: %r" + e.ToString() + "%n")
			Self._exitCode = 1
		End Try

		' TODO: Write the build log (if required)

	End Method

	Method _runConfigurationWizard:Byte()
		Local r:String = Input("No configuration detected. Run setup wizard (y/n)? ")
		If r.toLower() <> "y" And r.toLower() <> "yes" Then Return False

		Local platform:String     = Self.getPlatform()
		Local platformName:String = Self.getPlatformName()
		Local bmkPath:String      = Self.guessBmkPath()
		Local newPath:String      = ""

		PrintC "No configuration file detected. Entering configuration setup."
		PrintC "Current platform: %Y" + platformName + "%n~n"

		If bmkPath Then
			PrintC "Please enter the path to the %Wbmk%n executable, or leave blank to set as:"
			PrintC "%w" + bmkPath + "%n"
			newPath = Input("> ")

			If newPath = "" Then newPath = bmkPath
		Else
			PrintC "Please enter the path to the %Wbmk%n executable:"
			newPath = Input("> ")
		EndIf

		Print

		If newPath = "" Then
			PrintC "~n%rNo path entered.%n Cannot continue. Please see README.d for manual setup instructions."

			Return -1
		Else
			Self._configService._config.setKey("BlitzMax", platform, newPath)

			Local savedTo:String = Self._configService.saveConfiguration()

			PrintC "%gPath set succesfully.%n"
			PrintC "Configuration saved to: " + savedTo
		EndIf

		Return True
	End Method


	' ------------------------------------------------------------
	' -- Output methods
	' ------------------------------------------------------------

	''' <summary>Writes the application header.</summary>
	Method writeHeader()
		PrintC "%gblam " + AssemblyInfo.Version + " (Released: " + AssemblyInfo.Date + ")"
		PrintC "(C)opyright 2006-2019 " + AssemblyInfo.Company
		PrintC "%chttps://www.sodaware.net/blam/%n"
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

		' Display formatted description list.
		Local longestTargetNameLength:Int = Self._longestTargetName(file).Length
		For Local target:BuildTarget = EachIn file.getTargets()
			If target.isHidden() Then Continue
			WriteC " " + LSet(target.getName(), longestTargetNameLength)
			WriteC "  " + target.getDescription()
			PrintC
		Next

	End Method


	' ------------------------------------------------------------
	' -- Application setup & shutdown
	' ------------------------------------------------------------

	Method _setup()
		' Get command line options.
		Self._options = New ConsoleOptions

		' Setup service manager.
		Self._services = New ServiceManager
	End Method

	Method _shutdown:Int()
		Self._services.stopServices()
	End Method


	' ------------------------------------------------------------
	' -- Internal Helpers
	' ------------------------------------------------------------

	Method _longestTargetName:String(file:BuildScript)
		Local longestString:String = ""
		For Local target:BuildTarget = EachIn file.getTargets()
			If target.isHidden() Then Continue
			If target.getName().Length > longestString.Length Then
				longestString = target.getName()
			End If
		Next

		Return longestString
	End Method

	''' <summary>Get the full path to the build file.</summary>
	Method _getBuildfilePath:String()

		' Get path from options. May be blank.
		Local buildFile:String = Self._options.File

		' Ensure buildFile path is relative to the launchdir if it is not
		' absolute.
		If buildFile <> "" And RealPath(buildFile) <> buildFile Then
			buildFile = File_Util.PathCombine(LaunchDir, buildFile)
		EndIf

		' If no build file was passed in, search for "build.xml" and "blam.xml"
		' in the current directory.
		If buildFile = "" Then
			buildFile = File_Util.PathCombine(LaunchDir, "build.xml")

			' Fallback to "blam.xml"
			If FileType(buildFile) = False Then
				buildFile = File_Util.PathCombine(LaunchDir, "blam.xml")
			End If
		End If

		Return buildFile
	End Method


	' ------------------------------------------------------------
	' -- Config Helpers
	' ------------------------------------------------------------

	Method getPlatform:String()
		?win32
		Return "win32"
		?linux
		Return "linux"
		?macos
		Return "macos"
		?
	End Method

	Method getPlatformName:String()
		?win32
		Return "Windows"
		?linux
		Return "GNU/Linux"
		?macos
		Return "MacOS"
		?
	End Method

	Method guessBmkPath:String()
		?win32
		Return ""
		?

		Local runner:ProcessRunner = ProcessRunner.Create("which bmk")
		While runner.isRunning()
			runner.update()
		Wend

		Return runner.getLine()
	End Method


	' ------------------------------------------------------------
	' -- Construction / destruction
	' ------------------------------------------------------------

	Function Create:App()
		Local this:App	= New App
		Return this
	End Function

End Type
