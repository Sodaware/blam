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

Type Service
	
	Method InitialiseService() Abstract
	Method UnloadService() Abstract
	
End Type
