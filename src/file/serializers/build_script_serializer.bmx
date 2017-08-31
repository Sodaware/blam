' ------------------------------------------------------------------------------
' -- src/file/serializers/build_script_serializer.bmx
' --
' -- Base type all build script serializers must extend.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import "../build_script.bmx"


Type BuildScriptSerializer

	Method canLoad:Int(fileName:String) Abstract
	Method loadFile:BuildScript(fileName:String) Abstract

End Type
