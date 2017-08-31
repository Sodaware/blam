' ------------------------------------------------------------------------------
' -- src/main.bmx
' --
' -- Main driver file for blam. "Blam" is a simple build application for the
' -- Blitz family of languages.
' --
' -- This file is part of "blam" (https://www.sodaware.net/blam/)
' -- Copyright (c) 2007-2017 Phil Newton
' --
' -- Blam is free software; you can redistribute it and/or modify
' -- it under the terms of the GNU General Public License as published by 
' -- the Free Software Foundation; either version 3 of the License, or 
' -- (at your option) any later version.
' --
' -- Blam is distributed in the hope that it will be useful,
' -- but WITHOUT ANY WARRANTY; without even the implied warranty of
' -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' -- GNU General Public License for more details.
' -- 
' -- You should have received a copy of the GNU General Public
' -- License along with Blam (see the file COPYING for more details); 
' -- If not, see <http://www.gnu.org/licenses/>.
' ------------------------------------------------------------------------------


SuperStrict
 
Framework brl.basic
Import "core/app.bmx"

Local theApp:App = New App
exit_(theApp.Run())
