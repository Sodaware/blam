' ------------------------------------------------------------------------------
' -- src/services/service.bmx
' --
' -- Base type all services must extend.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Type Service Abstract

	''' <summary>
	''' Initialise the service. Load any resources and create objects here.
	''' </summary>
	Method initialiseService() Abstract
	
	''' <summary>
	''' Unload any resources created by the service and cleanup.
	''' </summary>
	Method unloadService() Abstract

End Type
