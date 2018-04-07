' ------------------------------------------------------------------------------
' -- src/file/serializers/xml_build_script_serializer.bmx
' --
' -- Loads XML based build scripts. Uses prime.maxml for serialization instead
' -- of libxml.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import prime.maxml
Import brl.reflection

Import "build_script_serializer.bmx"

Type MaxmlBuildScriptSerializer extends BuildScriptSerializer

	Method canLoad:Byte(fileName:String)
		Return (ExtractExt(fileName).toLower() = "xml")
	End Method

	Method loadFile:BuildScript(fileName:String)

		' -- Set up file for loading
		Local script:BuildScript = New BuildScript
		Local fileIn:xmlDocument = xmlDocument.Create(fileName)
		Local root:xmlNode       = fileIn.Root()

		If root.ChildList.Count() = 0 Then
			Throw "Build file contains no targets or properties"
		End If

		' File and project info
		script._filePath      = fileName
		script._projectName   = Self._attributeValue(root, "name")
		script._defaultTarget = Self._attributeValue(root, "default")

		' Load global tasks (not targets).
		For Local taskNode:xmlNode = EachIn root.childList
			If taskNode.name = "target" Then Continue

			' TODO: Check if it's a command or a type
			script.addGlobalCommand(Self._loadCommand(taskNode))
		Next

		' Load all target nodes
		For Local targetNode:xmlNode = EachIn root.childList
			If targetNode.name <> "target" Then Continue

			Local target:BuildTarget = New BuildTarget

			' -- Target details
			target._name        = Self._attributeValue(targetNode, "name")
			target._dependsOn   = Self._attributeValue(targetNode, "depends")
			target._description = Self._attributeValue(targetNode, "description")
			target._isHidden    = Self._isTrue(Self._attributeValue(targetNode, "hidden"))

			' -- Target commands
			For Local commandNode:xmlNode = EachIn targetNode.childList
				target.addCommand(Self._loadCommand(commandNode))
			Next

			script._buildTargets.Insert(target.getName(), target)
		Next

		Return script

	End Method

	Method _loadCommand:BuildCommand(node:xmlNode)

		Local cmd:BuildCommand= New BuildCommand

		cmd._name  = node.name
		cmd._value = node.value

		For Local attribute:xmlAttribute = EachIn node.attributeList
			cmd.addAttribute(attribute.name, attribute.value)
		Next

		' -- Load child types
		For Local childNode:xmlNode = EachIn node.childList
			Self._addChildToCommand(cmd, Self._loadChild(childNode))
		Next

		Return cmd

	End Method

	Method _loadChild:BuildNode(node:xmlNode)

		' Create the build node
		Local child:BuildNode = New BuildNode
		child.Name = node.Name

		' Add attributes
		For Local attribute:xmlAttribute = EachIn node.attributeList
			child.setAttribute(attribute.Name, attribute.Value)
		Next

		For Local childNode:xmlNode = EachIn node.childList
			child.addChild(Self._loadChild(childNode))
		Next

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

	Method _attributeValue:String(node:xmlNode, name:String, defaultValue:String = "")
		Local att:xmlAttribute = node.attribute(name)
		If att = Null Then Return defaultValue
		Return att.value
	End Method

	Method _isTrue:Byte(value:String)
		Return value.ToLower() = "true"
	End Method

End Type
