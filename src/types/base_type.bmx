' ------------------------------------------------------------------------------
' -- src/types/base_type.bmx
' --
' -- Base type that build script types must extend.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../file/build_node.bmx"
Import "../file/build_script.bmx"

Type BaseType
	Field _builder:Object
	Field _project:BuildScript

	Method setProject:BaseType(project:BuildScript)
		Self._project = project

		Return Self
	End Method
End Type
