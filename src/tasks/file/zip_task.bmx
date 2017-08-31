' ------------------------------------------------------------------------------
' -- src/tasks/file/zip_task.bmx
' --
' -- Compress files. Can pack a single file or a fileset of files.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- See COPYING for full license information.
' ------------------------------------------------------------------------------


SuperStrict

Import sodaware.Console_Color
import pub.zlib
import gman.zipengine
Import "../build_task.bmx"
Import "../../types/fileset.bmx"

Type ZipTask Extends BuildTask
	
	Field destfile:String
	Field files:Fileset
	field includeemptydirs:int	= False
	Field verbose:Int			= False			'''< [optional] Show verbose output
	field level:Int 			= 5

	Method execute()

		' [todo] - Add some error checking here!

' [todo] - Add an info header here

		Local filesToPack:TList = self.files.getIncludedFiles()
		local packedFiles:Int   = 0
		Local startSize:int 	= 0

		' Create the output
		Local zipOut:Byte Ptr 	= zipOpen(self.destfile, APPEND_STATUS_CREATE )

		' Add each file
		For local file:String = eachin filesToPack

			' Get the short file name
			Local fileName:String = file.replace(self.files.dir, "")

			If Self.verbose Then
				self.log(" + " + fileName)
			EndIf
			
			' Read file contents into a bank
			Local fileIn:TStream = OpenFile(file)
			Local inSize:Int = StreamSize(fileIn)
			Local inData:TBank = TBank.Create(inSize)
			
			ReadBank(inData, fileIn, 0, inSize)
			
			' Cleanup
			fileIn.Close()
			
			' Add the file to the zip
			zipOpenNewFileInZip(zipOut, fileName, Null, Null, Null, Null, Null, Null, Z_DEFLATED, self.level)
			zipWriteInFileInZip(zipOut, inData.buf(), inSize)
			
			startSize:+ inSize
			packedFiles:+ 1

		next
		
		zipClose(zipOut, self.destfile)

		self.log("Packed " + packedFiles + " (" + startSize + " to " + filesize(self.destfile) + ")")

	End Method

	Method setFileset(files:Fileset)
		self.files = files
	end method

End Type
