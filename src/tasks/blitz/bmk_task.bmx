' ------------------------------------------------------------------------------
' -- src/tasks/bmk_task.bmx
' --
' -- Task for working with the BlitzMax compiler. Can create executables and
' -- compile modules.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import sodaware.Console_Basic
Import sodaware.Console_Color
Import "../build_task.bmx"

' -- Needs config
Import "../../services/configuration_service.bmx"
Import "../../util/process_runner.bmx"
Import "../../util/compiler_error.bmx"

Type BmkTask Extends BuildTask

	Const SPINNER_CHARS:String	= "|/-\"

	Field _config:ConfigurationService

	Field source:String						'''< The input file or module to compile
	Field output:String						'''< [optional] The output file to create.
	Field action:String			= "makeapp"	'''< [optional] The build action to take.
	Field threaded:Int			= False		'''< [optional] Enable threading
	Field gui:Int				= False		'''< [optional] Enable GUI mode (hides the console if true)
	Field overwrite:Int			= False		'''< [optional] If true, will delete the "todir" if it already exists
	Field rebuild:Int			= False		'''< [optional] If true, fall source will be rebuilt
	Field debug:Int				= true		'''< [optional] If true, debug mode will be enabled
	Field fancy:Int				= false		'''< [optional] If true, will use fancy output
	Field failonerror:Int       = False     '''< [optional] If true, will fail the build if compilation fails

	Field _isCompiling:Int		= False
	Field _isLinking:Int		= False

	' ------------------------------------------------------------
	' -- Task Execution
	' ------------------------------------------------------------

	Method execute()

		' TODO: Add support for module compilation
		' TODO: Add support for handling "cannot open output file" error

		' -- Get configuration
		Self._config = ConfigurationService(Self._getService("ConfigurationService"))

		' -- Check the input file/mod is valid
		Self._verifyInput()

		' -- Remove .exe from output path if compiling on Linux/Mac
		Self._fixOutputExtension()

		' -- Create compiler command
		Local command:String = ProcessRunner.GetSafeName(Self._getCompilerPath())

		' -- Add action (makemod or makeapp)
		Select Self.action
			Case "makeapp"	; command:+ " makeapp"
			Case "makemods"	; command:+ " makemods"
			Default			; Throw "Unknown command: '" + Self.action + "'"
		End Select

		' -- Add options
		If Self.rebuild Then command:+ " -a"
		If Self.action = "makeapp" then
			if Self.Debug Then command:+ " -d" else command:+ " -r"
		EndIf
		If Self.threaded Then command:+ " -h"
		If Self.GUI Then command:+ " -t gui"
		If Self.action = "makeapp" And Self.output Then command:+ " -o " + ProcessRunner.GetSafeName(Self.output)

		' -- Add input (either a file or a mod name)
		command:+ " " + ProcessRunner.GetSafeName(Self.source)

		Local fileCount:Int		= 0

		' -- Execute
		Local compileProcess:ProcessRunner = ProcessRunner.Create(command)
		If compileProcess = Null Then Throw "Could not open BMK"

		Self.Log("Building %w~q" + Self.source + "~q%n")

		Local success:Byte = True

		While compileProcess.isRunning()

			compileProcess.update()

		'	If compileProcess.getError() <> "" Then Print "~nERROR/: " + compileProcess.getError()

			' -- Not found error
			If compileProcess.getLine().Contains("cannot open output file") Then
				Throw "Compile error: Cannot open output file ~q" + Self.output + "~q"
			End If

			' -- Update the spinner every time a file is compiled
			If Self.fancy Then

				If compileProcess.getLine().StartsWith("Compiling:") Then

					' Move to next char
					fileCount:+1

					' Clear the line + render
					ClearLine()
					WriteC(" [" + Chr(SPINNER_CHARS[fileCount Mod (SPINNER_CHARS.Length)]) + "] -- Compiling")

				End If

			Else

				If compileProcess.getLine().StartsWith("Compiling") Then
					If Self._isCompiling = False Then
						Self._isCompiling = True
						Self.Log("Compiling... ")
					endif

					' Display the name of the file that is compilinng
					Self.Log("  " + mid(compileProcess.getLine(), 11))

				ElseIf compileProcess.getLine().StartsWith("Linking:") Then
					If Self._isLinking = False Then
						Self._isLinking = True
						Self.Log("Linking...")
					End If
				End If

			End If

			' Check for link errors
			If Self._isLinking Then

				Local lineIn:String = compileProcess.getLine()

				' MinG link error
				If lineIn.Contains("libmingwex.a") Then
					If Self.fancy Then
						PrintC (" [%GX%n] -- Link failure")
					Else
						Self.Log("Linker failure", LEVEL_ERROR)
					End If

					Repeat
						If Self.fancy Then
							PrintC (" %RError: %r" + lineIn + "%n")
						Else
							Self.Log(lineIn, LEVEL_ERROR)
						End If
						compileProcess.update()
						lineIn = compileProcess.getLine()
					Until lineIn.StartsWith("Build Error") Or lineIn = ""

					compileProcess.stop()
					Return
				End If

				If compileProcess.getLine().StartsWith("Build Error") Then
					If Self.fancy Then
						PrintC (" [%GX%n] -- Link failure")
						PrintC (" %RError: %r" + lineIn + "%n")
					Else
						Self.Log("Linker failure", LEVEL_ERROR)
						Self.Log(lineIn, LEVEL_ERROR)
					End If
				End If

			Else

				If compileProcess.getLine().StartsWith("Compile Error") Then

					Local lineIn:String = compileProcess.getLine()

					If Self.fancy Then
						PrintC (" [%GX%n] -- Compilation failure")
						PrintC (" %RError: %r" + lineIn + "%n")
					Else
						Self.Log("Compilation failure", LEVEL_ERROR)
						Self.Log(lineIn, LEVEL_ERROR)
					EndIf

					Local errorLine:String = compileProcess.getError()
					Local error:CompilerError = Self._getCompilerError(String[][lineIn, errorLine])
					If error Then
						' TODO: Flag a global error in this file, so we can use it at the end for a summary
						Throw "Compile error: " + error.toString()

					'	PrintC("%RError in %r~q" + error.File + "~q%n")
					'	PrintC("%r" + error.Message + "%n")
					End If

				'	PrintC ("%RError: %r" + errorLine + "%n")
					compileProcess.stop()
					Return
				End If

			End If

			' TODO: What is this doing here?
			If compileProcess.getLine().startsWith("/usr/") Then
				compileProcess.stop()
				success = False
			EndIf

		Wend
		compileProcess.stop()

		If success Then
			Self.Log("Compilation success - output size " + FileSize(Self.output))
		Else
			Self.Log("Compilation failed")
		EndIf

	End Method


	' ------------------------------------------------------------
	' -- BlitzMax Actions
	' ------------------------------------------------------------


	' ------------------------------------------------------------
	' -- Internal helpers
	' ------------------------------------------------------------

	''' <summary>Parses an array of strings to find compiler errors.</summary>
	Method _getCompilerError:CompilerError(errorLines:String[])

		Local errorMessage:String = errorLines[0]
		Local errorLine:String    = errorLines[1]

		' Strip square brackets
		errorLine = errorLine.Replace("[", "")
		errorLine = errorLine.Replace("]", "")

		' Get parts
		Local errorParts:String[] = errorLine.Split(";")

		' Create & return
		Local error:CompilerError = New CompilerError
		error.File    = errorParts[0]

		if errorLine <> "" then
			error.Line    = Int(errorParts[1])
			error.Column  = Int(errorParts[2])
		endif

		error.Message = errorMessage

		Return error

	End Method

	Method _fixOutputExtension()
		?Win32
			If Self.output.ToLower().EndsWith(".exe") = False Then Self.output:+ ".exe"
		?Not Win32
			If Self.output.ToLower().EndsWith(".exe") Then Self.output = Left(Self.output, Self.output.Length - 4)
		?
	End Method

	Method _getCompilerPath:String()
		?Linux	Return Self._config.getKey("BlitzMax", "linux")
		?Win32	Return Self._config.getKey("BlitzMax", "win32")
		?MacOs	Return Self._config.getKey("BlitzMax", "macos")
		?
	End Method

	Method _verifyInput()

		If Self.action = "makemods" Then
			If FileType(Self._getModPath()) <> FILETYPE_DIR Then Throw "Mod '" + Self._getModPath() + "' not found"
		Else
			If FileType(Self.source) <> FILETYPE_FILE Then Throw "File '" + Self.source + "' not found"
		End If

	End Method

	Method _getModPath:String()

		' Get mod directory
		Local modsPath:String = File_util.PathCombine(ExtractDir(ExtractDir(Self._getCompilerPath())), "mod")

		' Get path for this mod
		Local sourceMod:String = Self.source.Replace(".", ".mod" + File_Util.SEPARATOR) + ".mod"

		' Put it all together
		Return File_Util.PathCombine(modsPath, sourceMod)

	End Method

End Type
