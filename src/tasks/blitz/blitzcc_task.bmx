' ------------------------------------------------------------------------------
' -- src/tasks/blitz/blitzcc_task.bmx
' --
' -- Task for compiling Blitz3D and BlitzPlus applications.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.retro
Import sodaware.Console_Color
Import "../build_task.bmx"

' -- Needs config
Import "../../services/configuration_service.bmx"
Import "../../util/process_runner.bmx"
Import "../../util/compiler_error.bmx"

Type BlitzccTask Extends BuildTask
	
	Field _config:ConfigurationService

	Field source:String						'''< The input file or module to compile
	field compiler:string					'''< The name of the compiler to use (either BlitzPlus or Blitz3D)
	field createexe:int						'''< If true, will create an executable
	Field output:String						'''< [optional] The output file to create.
	Field debug:Int				= False		'''< [optional] Enable debug mode
	
	' -- legacy fields
	field input:string
	
	
	' ------------------------------------------------------------
	' -- Task Execution
	' ------------------------------------------------------------

	Method execute()
		
		' -- Check we're on a Windows machine
		?not win32
		throw "Cannot compile BlitzPlus / Blitz3D apps on non-windows machines"
		?
		
		' -- Check input
		If Self.Input <> "" And Self.source = "" Then Self.source = Self.Input
		If FileType(Self.source) <> FILETYPE_FILE Then Throw "File '" + Self.source + "' not found"
				
		' -- Get configuration & check
		Self._config = ConfigurationService(Self._getService("ConfigurationService"))
		
		' TODO: Attempt to find compilers?
		if Self._config.getKey("Compilers", "BlitzPlus") = "" AND self._config.getKey("Compilers", "Blitz3D") = "" then
			Throw "No valid Blitz compilers installed"
		EndIf
			
		' -- Fix output filename if required
		If Self.output.ToLower().EndsWith(".exe") = False Then Self.output:+ ".exe"
			
		' -- Create compiler command
		Local command:String = ProcessRunner.GetSafeName(Self._getCompilerPath())
				
		' -- Add options
		If Self.Debug Then command:+ " -d"
		If Self.output Then command:+ " -o " + ProcessRunner.GetSafeName(Self.output)
		
		command:+ " " + ProcessRunner.GetSafeName(Self.source)
		
		' -- Setup the environment	
		putenv_("blitzpath=" + Self._getBlitzPath())

		' -- Execute 	
		Local result:CompilerResult = Self._executeRequest(command)
		Select result.ResultCode
		
			Case CompilerResult.COMPILERRESULT_SUCCESS
				PrintC("Compilation success: " + result.m_ResultSize)
			
			Case CompilerResult.COMPILERRESULT_ERROR
				PrintC("Compiler error")
				PrintC("    Filename : " + result.m_ErrorFile)
				PrintC("    Message  : " + result.m_ErrorMessage)
			
			Default
				PrintC("%RUnknown error in command%n")		
				PrintC("    %r" + command + "%n")		
		
		End Select
		

		
	End Method
	
	
	' ------------------------------------------------------------
	' -- BlitzMax Actions
	' ------------------------------------------------------------
	
	
	' ------------------------------------------------------------
	' -- Internal helpers
	' ------------------------------------------------------------
	
	Method _executeRequest:CompilerResult(command:String)
		
		Local result:CompilerResult
		Local compileProcess:ProcessRunner = ProcessRunner.Create(command)
		If compileProcess = Null Then Throw "Could not open blitzcc"
		
		While compileProcess.isRunning()
			
			compileProcess.update()
			
			' -- Catch major errors (don't think blitzcc uses this)
			If compileProcess.getError() <> "" Then Print "ERROR: " + compileProcess.getError()
			If compileProcess.getLine().startsWith("Can't find blitzpath") Then 
				Throw "BlitzCC Error -- Could not find blitzpath ('" + Self._getBlitzPath() + "')"
			EndIf
				
			' -- Read past compiling etc
			Local lineIn:String 	= compileProcess.getLine().tolower()
			If lineIn.StartsWith("compiling ") Then Continue
			If lineIn.StartsWith("parsing...") Then Continue
			
			' -- Get result (if required)
			If compileProcess.getLine().tolower().StartsWith("creating executable") Then
				result = New CompilerResult
				result.ResultCode	= CompilerResult.COMPILERRESULT_SUCCESS
			ElseIf compileProcess.getline().contains(":") Then
				result = CompilerResult.FromErrorLine(compileProcess.getLine())
			End If
			
		Wend
		compileProcess.stop()
		
		' Get filesize if required
		If result <> Null And result.ResultCode = CompilerResult.COMPILERRESULT_SUCCESS Then
			result.m_ResultSize	= FileSize(Self.output)
		End If
		
		Return result
	End Method
	
	Method _getBlitzPath:String()
		Return _removeQuotes(ExtractDir(ExtractDir(Self._getCompilerPath())))
	End Method
	
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
		error.Line    = Int(errorParts[1])
		error.Column  = Int(errorParts[2])
		error.Message = errorMessage
		
		Return error
		
	End Method
	
	Method _getCompilerPath:String()
		
		select lower(self.compiler)
			case "blitzplus"	; Return Self._config.getKey("Compilers", "BlitzPlus")
			case "blitz3d"		; Return Self._config.getKey("Compilers", "Blitz3D") 
			default				; throw "Unknown compiler: '" + self.compiler + "'"
		end select

	End Method
	
	Method _removeQuotes:String(path:String)
		If path.StartsWith("~q") Then path = Right(path, path.Length - 1)
		If path.EndsWith("~q") Then path = Left(path, path.Length - 1)
		
		Return path
	End Method
	
End Type

Private

Type CompilerResult
	
	Const COMPILERRESULT_ERROR:Int		= 1
	Const COMPILERRESULT_SUCCESS:Int	= 2
	Const COMPILERRESULT_READONLY:Int	= 3
	
	Const BLITZCOMPILER_BLITZ3D:Int		= 1
	Const BLITZCOMPILER_BLITZPLUS:Int	= 1
	Const BLITZCOMPILER_BLITZMAX:Int	= 2

	Field ResultCode:Int
	
	Field m_ErrorStartLine:Int
	Field m_ErrorStartColumn:Int
	Field m_ErrorEndLine:Int
	Field m_ErrorEndColumn:Int
	Field m_ErrorFile:String
	Field m_ErrorMessage:String
	
	Field m_ResultSize:Int
	
	
	
	Function FromErrorLine:CompilerResult(errorLine:String)
		
		' -- Create new result
		Local result:CompilerResult = New CompilerResult
		
		If Lower(Trim(errorLine)) = Lower("error creating executable") Then
			result.m_ErrorMessage	= "Error creating executable"
			result.ResultCode	 	= COMPILERRESULT_READONLY
			Return result
		EndIf
		
		' -- Get the error file
		result.ResultCode			= COMPILERRESULT_ERROR
		result.m_ErrorFile			= Mid(errorLine, 2, Instr(errorLine, "~q", 2) - 2)
		
		' Get the error location
		Local colonCount:Int 		= 0
		Local textPos:Int			= Len(result.m_ErrorFile) + 2
		
		While colonCount < 5 And textPos <= Len(errorLine)
			
			If Mid(errorLine, textPos, 1) = ":" Then
				colonCount = colonCount + 1
				
				' Get text between this colon and the next
				Local currentText$	= Mid(errorLine, textPos + 1, Instr(errorLine, ":", textPos + 1) - textPos - 1)
				
				' Set up the error
				Select colonCount
					Case 1;	result.m_ErrorStartColumn	= Int(currentText)
					Case 2;	result.m_ErrorStartLine		= Int(currentText)
					Case 3;	result.m_ErrorEndColumn		= Int(currentText)
					Case 4;	result.m_ErrorEndLine		= Int(currentText)
					Case 5;	result.m_ErrorMessage		= currentText
				End Select
				
				textPos = textPos + Len(currentText)
				
			EndIf
			
			' Next colon
			textPos = textPos + 1
			
		Wend
		
		' -- Done
		Return result
		
	End Function
	
End Type
