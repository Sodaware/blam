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

import gman.zipengine

Import "../build_task.bmx"
Import "../../types/fileset.bmx"

Type ZipTask Extends BuildTask

	Field destfile:String                       '''< Zip file to write to.
	Field files:Fileset                         '''< Fileset of files to include.
	Field verbose:Int           = False         '''< [optional] Show verbose output.
	field level:Int             = 5             '''< [optional] Compression level between 0-9.

	Method execute()

		' [todo] - Add some error checking here!
		Local filesToPack:TList = Self.files.getIncludedFiles()
		local packedFiles:Int   = 0
		Local startSize:Int     = 0

		' Create the output file.
		Local zipOut:Byte Ptr   = zipOpen(Self.destfile, APPEND_STATUS_CREATE )

		' Add each file in the fileset.
		For local file:String = eachin filesToPack

			' Get the short file name.
			Local fileName:String = file.replace(self.files.dir, "")

			' Remove leading slashes.
			If fileName.startsWith("/") Or fileName.startsWith("\") Then
				fileName = fileName[1..]
			End If

			If Self.verbose Then
				Self.log(" + " + fileName)
			EndIf

			' Read file contents into a bank.
			Local fileIn:TStream = OpenFile(file)
			Local inSize:Int     = StreamSize(fileIn)
			Local inData:TBank   = TBank.Create(inSize)

			ReadBank(inData, fileIn, 0, inSize)

			' Cleanup.
			fileIn.Close()

			' Load file info (file time).
			Local infoBank:TBank = Self._getFileInfo(file)

			' Add the file to the zip.
			zipOpenNewFileInZip(zipOut, fileName, BankBuf(infoBank), Null, Null, Null, Null, Null, Z_DEFLATED, self.level)
			zipWriteInFileInZip(zipOut, inData.buf(), inSize)

			' Update stats.
			startSize:+ inSize
			packedFiles:+ 1

		Next

		' Close zup handle.
		zipClose(zipOut, self.destfile)

		Self.log("Packed " + packedFiles + " (" + startSize + " to " + FileSize(Self.destfile) + ")")

	End Method

	Method setFileset(files:Fileset)
		self.files = files
	end Method

	Method _getFileInfo:TBank(file:String)
		Local time:Int        = FileTime(file)
		Local pointer:Int Ptr = Int Ptr(localtime_(Varptr(time)))

		Local info:zip_fileinfo = New zip_fileinfo

		info.tmz_date.tm_sec  = pointer[0]
		info.tmz_date.tm_Min  = pointer[1]
		info.tmz_date.tm_hour = pointer[2]
		info.tmz_date.tm_mday = pointer[3]
		info.tmz_date.tm_mon  = pointer[4]
		info.tmz_date.tm_year = (pointer[5] + 1900)

		Return info.getBank()
	End Method

End Type
