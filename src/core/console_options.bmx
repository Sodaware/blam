' ------------------------------------------------------------------------------
' -- src/core/console_options.bmx
' --
' -- Command line options used by blam.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import brl.map
Import sodaware.Console_Color
Import sodaware.Console_CommandLine

Type ConsoleOptions Extends CommandLineOptions

	Field NoLogo:Int	= False				{ Description="Hides the copyright notice" LongName="nologo" ShortName="n" }
	Field File:String	= ""				{ Description="The build file to use" LongName="file-name" ShortName="f"  }
	Field Target:String = ""				{ Description="The build target to use" ShortName="t" }
	
	Field Silent:Int	= False				{ Description="Supresses output to the console" LongName="silent" ShortName="s" }
	Field Prop:TMap		= New tmap			{ Description="Properties to send to the project" }
	Field Verbose:Int   = False				{ Description="Enable verbose output" LongName="verbose" ShortName="v" }
    Field Bland:Byte    = False             { Description="Disable colourized output" LongName="bland" ShortName="b" }

	Field List:Byte		= False				{ Description="List all available targets in buildfile" LongName="list" ShortName="l"}
	
	Field Help:Int		= False
	
	Method ShowHelp() 
		
		PrintC "%_Usage%n: blitzbuild [options] [--file file] [--target target]"
		PrintC "" 
		PrintC "Builds a BlitzBuild project."
		PrintC ""
		
		' Args: Column Width, Use Colours
		PrintC "%YCommands:%n "
		PrintC(Super.CreateHelp(80, True))

	End Method

	' sorry :(
	Method New()
		Super.Init(AppArgs)
	End Method

End Type
