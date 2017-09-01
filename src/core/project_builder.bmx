' ------------------------------------------------------------------------------
' -- src/core/project_builder.bmx
' --
' -- Handles the execution of the build script.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

'Import brl.map
Import brl.linkedlist

Import brl.reflection
Import brl.retro

' -- Application level
Import "../service_manager.bmx"
Import "../services/task_manager/task_manager_service.bmx"

Import "../expressions/expression_evaluator.bmx"

' -- Build stuff
Import "../file/build_script.bmx"
Import "../file/build_logger.bmx"

' -- OUTPUT!
Import "../util/console_util.bmx"

' -- TASKS!
Import "../tasks/build_task.bmx"
Import "../tasks/briskvm_build_task.bmx"

Import "../tasks/blitz/blitzcc_task.bmx"
Import "../tasks/blitz/bmk_task.bmx"

Import "../tasks/core/echo_task.bmx"
Import "../tasks/core/property_task.bmx"
Import "../tasks/core/sleep_task.bmx"

Import "../tasks/file/copy_task.bmx"
Import "../tasks/file/delete_task.bmx"
Import "../tasks/file/mkdir_task.bmx"
Import "../tasks/file/zip_task.bmx"

' -- FUNCTIONS!
Import "../functions/environment_functions.bmx"
Import "../functions/directory_functions.bmx"
Import "../functions/version_functions.bmx"
Import "../functions/project_functions.bmx"

' -- TYPES!
Import "../types/fileset.bmx"


''' <summary>A project builder.</summary>
Type ProjectBuilder
	
	Field _serviceManager:ServiceManager    '''< Services

	Field _buildScript:BuildScript          '''< The script to execute. 
	Field _buildLog:BuildLogger             '''< The build log for the script
	
	Field _target:String                    '''< The target to execute
	Field _verboseMode:Byte                 '''< Is verbose mode enabled>
	
	Field _buildQueue:TList                 '''< A queue of targets to execute
	Field _targetExecutionStack:TList       '''< The stack of targets to execute
	Field _executedTargets:TList            '''< A list of target names that have been executed
	
	
	' ------------------------------------------------------------
	' -- Properties
	' ------------------------------------------------------------
	
	''' <summary>Set a global property that can be accessed by any target.</summary>
	''' <param name="name">Name of the property to set.</param>
	''' <param name="value">String value of the property.</param>
	Method setGlobalProperty(name:String, value:String)
		If Self._buildScript Then
			Self._buildScript.setProperty(name, value)
		End If
	End Method
	
	
	' ------------------------------------------------------------
	' -- Script options
	' ------------------------------------------------------------
	
	''' <summary>Enable or disable verbose mode.</summary>
	''' <param name="enabled">Enabled value</param>
	Method setVerboseMode(enabled:Byte = True)
		Self._verboseMode = enabled
	End Method
	
	''' <summary>Set the build script for this builder.</summary>
	''' <param name="script">Set the build script to be executed.</param>
	Method setScript(script:BuildScript)
		Self._buildScript = script
		Self._target      = script.getDefaultTargetName()
	End Method
	
	''' <summary>Set the build target to execute.</summary>
	''' <param name="target">Name of the target to execute.</param>
	Method setTarget(target:String)		
		' TODO: Check the target can be found
		Self._target = target
	End Method
	
	
	' ------------------------------------------------------------
	' -- Script Execution
	' ------------------------------------------------------------
	
	''' <summary>Run the current build script.</summary>
	Method run()
		
		' Start time
		Local startTime:Int = MilliSecs()
		
		' Run global tasks
		For Local task:BuildCommand = EachIn Self._buildScript.getGlobalTasks()
			Self._runTargetCommand(task)
		Next
		
		' Run main target
		Self.executeTarget()
		
		' Show execution time
		Local totalTime:Int 	= MilliSecs() - startTime
		Local timeInSeconds:Int	= Floor(totalTime / 1000)
		Local remainder:Float	= (totalTime / 1000.0) - timeInSeconds
		
		Print "~nTotal time: " + timeInSeconds + "." + (Mid(remainder, 3, 4)) + " seconds"
		
	End Method
	
	''' <summary>
	''' Execute a build target. Will either execute targetName, or the
	''' currently set build target, 
	''' </summary>
	''' <param name="targetName">Optional target to build.</param>
	Method executeTarget(targetName:String = "")
		
		' Get the target to execute (if non passed in)
		If targetName = "" Then targetName = Self._target
		
		Local target:BuildTarget = Self._buildScript.getTarget(targetName)
		If target = Null Then Throw "Target ~q" + targetName + "~q not found."
		
		' -- Check if target has any dependencies
		If target.hasDependencies() Then
			For Local depends:String = EachIn target.getDependencies()
				If Not(Self._executedTargets.Contains(depends)) Then
					Self.executeTarget(depends)
				End If
			Next
		End If
		
		' -- Enter the target
		Self._enterTarget(target)
		
		' -- Run each command
		For Local cmd:BuildCommand = EachIn target.m_BuildCommands
			Self._runTargetCommand(cmd)
		Next
		
		' -- Leave & complete
		Self._executedTargets.AddLast(target.getName())
		Self._leaveTarget()
		
	End Method
	
	
	' ------------------------------------------------------------
	' -- Internal execution helpers
	' ------------------------------------------------------------
	
	''' <summary>Enter a target and push it to the execution stack.</summary>
	''' <param name="target">The target to enter.</param>
	Method _enterTarget(target:BuildTarget)
		
		' Check target is valid
		If target = Null Then Throw "Attempt to execute invalid target"
		
		' TODO: Add option to hide or colorize this
		' Show target
		If Self._buildScript.getCurrentTarget() <> Null Then Print
		PrintC("%y" + target.getName() + ":%n")

		' Push to stack & set as current target
		Self._targetExecutionStack.AddLast(target)
		Self._buildScript.setCurrentTarget(target)
		
	End Method
	
	''' <summary>Runs a build command within a build target.</summary>
	''' <param name="cmd">The command to execute.</param>
	Method _runTargetCommand(cmd:BuildCommand)
	
		' TODO: Add proper error checking for when a property is not found
		' TODO: Clean all of this up! It's mostly test code, but it works
		' TODO: Add support for running multiple evaluators within a single property
		' TODO: Add support for functions. Possibly a "BuildFunctionService" to store them in ? [ should use reflection ]
		
		' Build task support
		Local taskManager:TaskManagerService = Self._getTaskManager()
		
		' Find the command handler
		Local taskHandler:BuildTask	= taskManager.findTask(cmd.m_Name)
		
		If taskHandler = Null Then Throw "Command '" + cmd.m_Name + "' not found"
		
		Local taskType:TTypeId		= TTypeId.ForObject(taskhandler)
		taskHandler._services		= Self._serviceManager
		taskHandler._project		= Self._buildScript

		' Set build target fields
		For Local fld:TField = EachIn taskType.Fields()

			' Skip private fields
			If fld.Name().StartsWith("_") Or fld.Name().StartsWith("m_") Then Continue

			' Get value for this field
			If cmd.m_Parameters.valueForKey(fld.Name()) <> Null Then
				Local val:String = String(cmd.m_Parameters.ValueForKey(fld.Name()))

				' If contains expressions, parse it
				If val.Contains("${") Then val = Self._parsePropertyValue(val)

				' Set the property
				ProjectBuilder._setTaskProperty(fld, taskHandler, val)
			EndIf
		Next
		
		' Set child types (if any present)
		If cmd.hasChildren() Then
		
			' Set each child
			For Local childNode:BuildNode = EachIn cmd.getChildren()
			
				' Create a BaseType object for child node name
				Local child:BaseType = Self._createTypeFromBuildNode(childNode)
				If child <> Null Then
					
					Local childName:String = TTypeId.ForObject(child).Name()
					
					' Get type
					Local setMethodName:String	= "set" + childName.ToLower()
					
					' Check task can set it
					If taskType.FindMethod(setMethodName) Then
						taskType.FindMethod(setMethodName).Invoke(taskHandler, [child])
					ElseIf taskType.FindField(childName) Then
						taskType.FindField(childName).Set(taskHandler, child)
					Else
						Print "Could not find setter: " + childName
					End If
				EndIf
				
			Next
			
		EndIf
		
		' -- Run this task
		ConsoleUtil.currentTask = cmd.m_Name
		taskHandler.execute()
	
	End Method
	
	''' <summary>Create a BaseType object fron a build node.</summary>
	''' <param name="node">The BuildNode object to create a type instance for.</param>
	''' <returns>A BaseType child instance.</returns>
	Method _createTypeFromBuildNode:BaseType(node:BuildNode)
		
		' Get reflection information
		Local childType:TTypeId = TTypeId.ForName(node.Name)
		If childType = Null Then Return Null
		
		' Create type
		Local child:BaseType = BaseType(childType.NewObject())
		
		' Set attributes
		For Local attName:String = EachIn node.Attributes.Keys()
			
			' Check type can set it
			Local setMethodName:String	= "set" + node.Name.ToLower()
			Local nodeValue:String		= Self._parsePropertyValue(String(node.Attributes.ValueForKey(attName)))
			
			If childType.FindMethod(setMethodName) Then
				childType.FindMethod(setMethodName).Invoke(child, [nodeValue])
			ElseIf childType.FindField(attName) Then
				childType.FindField(attName).Set(child, nodeValue)
			Else
				Print "Could not find setter: " + node.Name
			End If
			
		Next
		
		' Set children
		For Local childNode:BuildNode = EachIn node.Children
			
			' Set each child (if it has a setter)
			Local setMethodName:String	= "set" + childNode.Name.ToLower()
			
			If childType.FindMethod(setMethodName) Then
				childType.FindMethod(setMethodName).Invoke(child, [childNode])
			Else
				Print "Could not find setter: " + node.Name
			End If
		Next
		
		Return child
		
	End Method
	
	''' <summary>
	''' Parse a string property and return its value. Will evaluate any
	''' expressions and functions within the property.
	''' </summary>
	''' <param name="val">The value to parse</param>
	''' <return>The parsed value.</return> 
	Method _parsePropertyValue:String(val:String)
			
		Local propertyValue:String = val
		While Instr(propertyValue, "${") > 0
			
			Local myExp:String = Mid(propertyValue, Instr(propertyValue, "${") + 2, Instr(propertyValue, "}") - Instr(propertyValue, "${") - 2)
			
			If Instr(propertyValue, "}") < 1 Then 
				Throw "Missing closing brace in expression ~q" + propertyValue + "~q"
			EndIf
			
			' If expression has contents, work it !
			If myExp <> "" Then
			
				Local eval:ExpressionEvaluator = ExpressionEvaluator.Create(myExp)
				
				' -- Add project
				
				' -- Add functions
				eval.__autoload(Self._buildScript)
				
				' -- Add properties			
				eval.addProperties(Self._buildScript.getGlobalProperties())
				eval.addProperties(Self._buildScript.getCurrentTargetProperties())
								
				' -- Execute
				Local res:ScriptObject = eval.Evaluate()
				If res = Null Then
					Print "Expression '" + myExp + "' returned a null result"
				End If
				
				' -- Replace expression with value
				propertyValue = propertyValue.Replace("${" + myExp + "}", res.ToString())
			Else
				propertyValue = propertyValue.Replace("${" + myExp + "}", "")
			EndIf
			
		Wend
		
		Return propertyValue
		
	End Method
	
	Function _setTaskProperty(fieldType:TField, handler:BuildTask, taskValue:Object)
		
		' Convert boolean values
		If fieldType.TypeId().name().tolower() = "int" Then
			If taskValue.ToString().ToLower() = "true" Then taskValue = String(1)
			If taskValue.ToString().ToLower() = "false" Then taskValue = String(0)
		EndIf
	
		fieldType.Set(handler, taskValue)
		
	End Function
	
	Method _leaveTarget()
		If Self._targetExecutionStack.Count() < 1 Then Return
		BuildTarget(Self._targetExecutionStack.RemoveLast())
	End Method
	
	Method _getTaskManager:TaskManagerService()
		Return TaskManagerService( ..
			Self._serviceManager.GetService(TTypeId.ForName("TaskManagerService")) ..
		)
	End Method
	
	Method setServiceManager(manager:ServiceManager)
		Self._serviceManager = manager
	End Method

	
	' ------------------------------------------------------------
	' -- Creation & Destruction
	' ------------------------------------------------------------
	
	Method New()
		Self._buildQueue	 		= New TList
		Self._targetExecutionStack	= New TList
		Self._executedTargets		= New TList
	End Method
	
End Type
