' ------------------------------------------------------------------------------
' -- src/core/console_options.bmx
' --
' -- Command line options used by blam.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2019 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import sodaware.Console_Color
Import sodaware.Console_CommandLine

Type ConsoleOptions Extends CommandLineOptions

	Field NoLogo:Byte   = False             { Description="Hide the copyright notice" LongName="nologo" ShortName="n" }
	Field File:String   = ""                { Description="The build file to use" LongName="file-name" ShortName="f"  }
	Field Target:String = ""                { Description="The build target to use" LongName="target" ShortName="t" }
	Field Config:String = ""                { Description="Optional path of configuration file" LongName="config" ShortName="c" }

	Field Silent:Byte   = False             { Description="Supress output to the console" LongName="silent" ShortName="s" }
	Field Prop:TMap     = New TMap          { Description="Properties to send to the project" NoHelp }
	Field Verbose:Byte  = False             { Description="Enable verbose output" LongName="verbose" ShortName="v" }
	Field Bland:Byte    = False             { Description="Disable colourized output" LongName="bland" ShortName="b" }
	Field Version:Byte  = False             { Description="Show the current version" LongName="version" ShortName="r" }

	Field List:Byte     = False             { Description="List all available targets in buildfile" LongName="list" ShortName="l"}

	Field Help:Byte     = False

	Method showHelp()
		PrintC "%_Usage%n: blam [options] [--file file] [--target target]"
		PrintC ""
		PrintC "Build a blam project."
		PrintC ""

		' Args: Column Width, Use Colours
		PrintC "%YCommands:%n "
		PrintC(Self.wrapHelpText("--prop:<NAME>", "  Set property <NAME> to a value"))
		PrintC(Super.createHelp(80, True))
	End Method

	' sorry :(
	Method New()
		Super.Init(AppArgs)
	End Method

End Type
