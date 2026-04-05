-- ***************************************************************************
--                      Adacrash - Sdl
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
with SDL_Types; use SDL_Types;

package SDL is

   pragma Preelaborate;

   use Interfaces.C;

   -- SDL subsystem flags
   SDL_INIT_TIMER          : constant Uint32 := 16#00000001#;
   SDL_INIT_AUDIO          : constant Uint32 := 16#00000010#;
   SDL_INIT_VIDEO          : constant Uint32 := 16#00000020#;
   SDL_INIT_JOYSTICK       : constant Uint32 := 16#00000200#;
   SDL_INIT_HAPTIC         : constant Uint32 := 16#00001000#;
   SDL_INIT_GAMECONTROLLER : constant Uint32 := 16#00002000#;
   SDL_INIT_EVENTS         : constant Uint32 := 16#00004000#;
   SDL_INIT_SENSOR         : constant Uint32 := 16#00008000#;
   SDL_INIT_EVERYTHING     : constant Uint32 := 
      SDL_INIT_TIMER or SDL_INIT_AUDIO or SDL_INIT_VIDEO or
      SDL_INIT_EVENTS or SDL_INIT_JOYSTICK or SDL_INIT_HAPTIC or
      SDL_INIT_GAMECONTROLLER or SDL_INIT_SENSOR;

   -- Initialize SDL subsystems
   -- Returns 0 on success, -1 on error
   function Init (Flags : Uint32) return int
      with Import => True, Convention => C, External_Name => "SDL_Init";

   -- Initialize specific SDL subsystems
   function InitSubSystem (Flags : Uint32) return int
      with Import => True, Convention => C, External_Name => "SDL_InitSubSystem";

   -- Shut down specific SDL subsystems
   procedure QuitSubSystem (Flags : Uint32)
      with Import => True, Convention => C, External_Name => "SDL_QuitSubSystem";

   -- Check which subsystems are initialized
   function WasInit (Flags : Uint32) return Uint32
      with Import => True, Convention => C, External_Name => "SDL_WasInit";

   -- Clean up all initialized subsystems
   procedure Quit
      with Import => True, Convention => C, External_Name => "SDL_Quit";

   -- Get the last error message
   function GetError return Interfaces.C.Strings.chars_ptr
      with Import => True, Convention => C, External_Name => "SDL_GetError";

   -- Clear the error message
   procedure ClearError
      with Import => True, Convention => C, External_Name => "SDL_ClearError";

end SDL;
