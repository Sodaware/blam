' ------------------------------------------------------------------------------
' -- src/services/service_manager.bmx
' --
' -- Manages application services. Keeps track of all services and can start
' -- and stop them.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import brl.reflection

Import "services/service.bmx"

Type ServiceManager
	
	Field m_Services:TList			= New TList
	Field m_ServiceLookup:TMap		= New TMap
	
	Method AddService(service:Service)
		Self.m_Services.AddLast(service)
		Self.m_ServiceLookup.Insert(TTypeId.ForObject(service), service)
	End Method
	
	Method GetService:Service(serviceName:TTypeId)
		
		' Get service from lookup
		Local theService:Service	= Service(Self.m_ServiceLookup.ValueForKey(serviceName))
		
		' If not found, search the list of services
		If theService = Null Then
			
			For Local tService:Service = EachIn Self.m_Services
				If TTypeId.ForObject(tService) = serviceName Then
					theService = tService
					Exit
				End If
			Next
			' If still not found, throw an error
		EndIf
		
		' Done
		Return theService
		
	End Method
	
	Method InitaliseServices()
		For Local tService:Service = EachIn Self.m_Services
			tService.InitialiseService()
		Next
	End Method
	
	Method StopServices()
		Self.m_Services.Reverse()
		For Local tService:Service = EachIn Self.m_Services
			tService.UnloadService()
		Next	
	End Method
	
End Type
