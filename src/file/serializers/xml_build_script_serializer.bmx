' ------------------------------------------------------------------------------
' -- src/file/serializers/xml_build_script_serializer.bmx
' --
' -- Loads XML based build scripts.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import bah.libxml
Import brl.reflection

Import "build_script_serializer.bmx"

Type XmlBuildScriptSerializer extends BuildScriptSerializer

	Method canLoad:Byte(fileName:String)
		Return (ExtractExt(fileName).toLower() = "xml")
	End Method

	Method loadFile:BuildScript(fileName:String)

		' -- Set up file for loading
		Local script:BuildScript     = New BuildScript
		Local fileIn:TxmlDoc         = TxmlDoc.parseFile(fileName)
		Local rootNode:TxmlNode      = fileIn.getRootElement()
		Local xpath:TxmlXPathContext = fileIn.newXPathContext()

		If rootNode.getChildren().Count() = 0 Then Return Null

		' File and project info
		script._filePath      = fileName
		script._projectName   = xpath.evalExpression("//project/@name").castToString()
		script._defaultTarget = xpath.evalExpression("//project/@default").castToString()

		' Load global tasks
		Local task:TxmlNodeSet = xpath.evalExpression("//project/*").getNodeSet()
		For Local taskNode:TxmlNode = EachIn task.getNodeList()

			If taskNode.getName() = "target" Then Continue

			' TODO: Check if it's a command or a type
			' TODO: Move this to a single function (as command can appear in target as well)
			Local cmd:BuildCommand = Self._loadCommand(taskNode)

			script.addGlobalCommand(cmd)
		Next

		' Load targets
		Local targets:TxmlNodeSet = xpath.evalExpression("//project/target").getNodeSet()
		For Local targetNode:TxmlNode = EachIn targets.getNodeList()

			Local target:BuildTarget = New BuildTarget

			' -- Target details
			target._name        = targetNode.getAttribute("name")
			target._dependsOn   = targetNode.getAttribute("depends")
			target._description = targetNode.getAttribute("description")
			target._isHidden    = Self._isTrue(targetNode.getAttribute("hidden"))

			' -- Target commands
			If targetNode.getChildren() <> Null And targetNode.getChildren().Count() > 0 Then

				' Load each command
				For Local commandNode:TxmlNode = EachIn targetNode.getChildren()

					' Create command to hold this
					Local cmd:BuildCommand = New BuildCommand

					' Load name / any text
					cmd._name  = commandNode.getName()
					cmd._value = commandNode.GetText()

					' Load attributes
					If commandNode.getAttributeList() <> Null Then
						For Local ATT:TxmlAttribute	= EachIn commandNode.getAttributeList()
							If ATT <> Null Then cmd.addAttribute(ATT.getName(), ATT.getValue())
						Next
					EndIf

					' -- Load child types
					If commandNode.getChildren() <> Null Then
						For Local childNode:TxmlNode = EachIn commandNode.getChildren()
							Self._addChildToCommand(cmd, Self._loadChild(childNode))
						Next
					End If

					target.addCommand(cmd)
				Next
			EndIf

			script._buildTargets.Insert(target.getName(), target)
		Next

		' Cleanup & return
		fileIn.free()
		fileIn = Null
		Return script

	End Method

	Method _loadCommand:BuildCommand(node:TxmlNode)

		Local cmd:BuildCommand	= New BuildCommand

		cmd._name  = node.getName()
		cmd._value = node.GetText()

		For Local ATT:TxmlAttribute	= EachIn node.getAttributeList()
			if ATT then	cmd.addAttribute(ATT.getName(), ATT.getValue())
		Next

		Return cmd

	End Method

	Method _loadChild:BuildNode(node:TxmlNode)

		' Create the build node
		Local child:BuildNode = New BuildNode
		child.Name = node.getName()

		' Add attributes
		If node.getAttributeList() <> Null Then
			For Local ATT:TxmlAttribute	= EachIn node.getAttributeList()
				If ATT <> Null Then child.setAttribute(ATT.getName(), ATT.getValue())
			Next
		EndIf

		If node.getChildren() <> Null Then
			For Local childNode:TxmlNode = EachIn node.getChildren()
				child.addChild(Self._loadChild(childNode))
			Next
		EndIf

		Return child

	End Method

	Method _addChildToCommand(cmd:BuildCommand, child:BuildNode)

		' Check child is valid
		If child = Null Then Return

		' Check command has a child of this type
		Local commandType:TTypeId = Self._findTaskType(cmd._name)
		If commandType = Null Then Return

		' Check command has a method for setting this type
		cmd.addChild(child)

	End Method

	Method _findTaskType:TTypeId(taskName:String)

		Local baseTask:TTypeId = TTypeId.ForName("BuildTask")
		For Local task:TTypeId = EachIn baseTask.DerivedTypes()
			If Lower(Left(task.Name(), task.Name().Length - 4)) = Lower(taskName) Then
				Return task
			EndIf
		Next

		Return Null

	End Method

	Method _isTrue:Byte(value:String)
		Return value.ToLower() = "true"
	End Method

End Type
