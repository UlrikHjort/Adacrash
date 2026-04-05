-- ***************************************************************************
--                      Adacrash - Sdl.Surface
--
--           Copyright (C) 2026 By Ulrik Hørlyk Hjort
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ***************************************************************************
with Interfaces.C;
with Interfaces.C.Strings;
with System;
with SDL_Types; use SDL_Types;

package SDL.Surface is

   use Interfaces.C;

   -- Opaque surface type
   type Surface is new System.Address;
   Null_Surface : constant Surface := Surface (System.Null_Address);

   -- SDL_RWops type
   type RWops is new System.Address;

   -- Surface flags
   SDL_SWSURFACE : constant Uint32 := 0;
   SDL_PREALLOC  : constant Uint32 := 16#00000001#;
   SDL_RLEACCEL  : constant Uint32 := 16#00000002#;
   SDL_DONTFREE  : constant Uint32 := 16#00000004#;

   -- Free a surface
   procedure FreeSurface (Surf : Surface)
      with Import => True, Convention => C, External_Name => "SDL_FreeSurface";

   -- Create RWops from file
   function RWFromFile
      (File : Interfaces.C.Strings.chars_ptr;
       Mode : Interfaces.C.Strings.chars_ptr) return RWops
      with Import => True, Convention => C, External_Name => "SDL_RWFromFile";

   -- Load BMP from RWops
   function LoadBMP_RW
      (Src      : RWops;
       Freesrc  : int) return Surface
      with Import => True, Convention => C, External_Name => "SDL_LoadBMP_RW";

   -- Set color key (transparency)
   function SetColorKey
      (Surf   : Surface;
       Flag   : int;
       Key    : Uint32) return int
      with Import => True, Convention => C, External_Name => "SDL_SetColorKey";

end SDL.Surface;
