' ------------------------------------------------------------------------------
' -- src/functions/function_set.bmx
' --
' -- Base type that script function types must extend. A FunctionSet object
' -- contains multiple methods that are mapped to script functions.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../file/build_script.bmx"

Type FunctionSet

	Field _script:BuildScript


	' ------------------------------------------------------------
	' -- Build script functions
	' ------------------------------------------------------------

	Method getProject:BuildScript()
		Return Self._script
	End Method

	Method _setProject(script:BuildScript)
		Self._script = script
	End Method

End Type
