' ------------------------------------------------------------
' -- assembly_info.bmx	- Information about the current assembly 
' -- Copyright (C) 2003 - 2009 Phil Newton
' ------------------------------------------------------------

' This file is auto-generated
SuperStrict

Const FINAL_BUILD:Int		= True

''' <summary>Type containing information about this assembly (application)</summary>
Type AssemblyInfo
	
	Const Name:String        = "<?php echo $name; ?>" 		''' Name of the app
	Const Version:String     = "<?php echo $version; ?>"		''' Version of the app
	Const Company:String     = "<?php echo $company; ?>"		''' Company that made this app
	Const VersionName:String = "<?php echo $codename; ?>"	''' Version codename
	Const Date:String        = "<?php echo date('F jS, Y', time()); ?>"
		
End Type