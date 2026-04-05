-- ***************************************************************************
--                      Adacrash - Sdl.Video
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

package SDL.Video is

   use Interfaces.C;

   -- Opaque window type
   type Window is new System.Address;
   Null_Window : constant Window := Window (System.Null_Address);

   -- Window flags
   SDL_WINDOW_FULLSCREEN         : constant Uint32 := 16#00000001#;
   SDL_WINDOW_OPENGL             : constant Uint32 := 16#00000002#;
   SDL_WINDOW_SHOWN              : constant Uint32 := 16#00000004#;
   SDL_WINDOW_HIDDEN             : constant Uint32 := 16#00000008#;
   SDL_WINDOW_BORDERLESS         : constant Uint32 := 16#00000010#;
   SDL_WINDOW_RESIZABLE          : constant Uint32 := 16#00000020#;
   SDL_WINDOW_MINIMIZED          : constant Uint32 := 16#00000040#;
   SDL_WINDOW_MAXIMIZED          : constant Uint32 := 16#00000080#;
   SDL_WINDOW_INPUT_GRABBED      : constant Uint32 := 16#00000100#;
   SDL_WINDOW_INPUT_FOCUS        : constant Uint32 := 16#00000200#;
   SDL_WINDOW_MOUSE_FOCUS        : constant Uint32 := 16#00000400#;
   SDL_WINDOW_FULLSCREEN_DESKTOP : constant Uint32 := 16#00001001#;
   SDL_WINDOW_FOREIGN            : constant Uint32 := 16#00000800#;
   SDL_WINDOW_ALLOW_HIGHDPI      : constant Uint32 := 16#00002000#;
   SDL_WINDOW_MOUSE_CAPTURE      : constant Uint32 := 16#00004000#;
   SDL_WINDOW_ALWAYS_ON_TOP      : constant Uint32 := 16#00008000#;
   SDL_WINDOW_SKIP_TASKBAR       : constant Uint32 := 16#00010000#;
   SDL_WINDOW_UTILITY            : constant Uint32 := 16#00020000#;
   SDL_WINDOW_TOOLTIP            : constant Uint32 := 16#00040000#;
   SDL_WINDOW_POPUP_MENU         : constant Uint32 := 16#00080000#;
   SDL_WINDOW_VULKAN             : constant Uint32 := 16#10000000#;

   SDL_WINDOWPOS_UNDEFINED      : constant int := -1;
   SDL_WINDOWPOS_CENTERED       : constant int := -2;

   -- Create a window
   function CreateWindow
      (Title  : Interfaces.C.Strings.chars_ptr;
       X      : int;
       Y      : int;
       W      : int;
       H      : int;
       Flags  : Uint32) return Window
      with Import => True, Convention => C, External_Name => "SDL_CreateWindow";

   -- Destroy a window
   procedure DestroyWindow (Win : Window)
      with Import => True, Convention => C, External_Name => "SDL_DestroyWindow";

   -- Update window surface (for software rendering)
   function UpdateWindowSurface (Win : Window) return int
      with Import => True, Convention => C, External_Name => "SDL_UpdateWindowSurface";

   -- Set window title
   procedure SetWindowTitle (Win : Window; Title : Interfaces.C.Strings.chars_ptr)
      with Import => True, Convention => C, External_Name => "SDL_SetWindowTitle";

   -- Get window title
   function GetWindowTitle (Win : Window) return Interfaces.C.Strings.chars_ptr
      with Import => True, Convention => C, External_Name => "SDL_GetWindowTitle";

   -- Show window
   procedure ShowWindow (Win : Window)
      with Import => True, Convention => C, External_Name => "SDL_ShowWindow";

   -- Hide window
   procedure HideWindow (Win : Window)
      with Import => True, Convention => C, External_Name => "SDL_HideWindow";

   -- Raise window
   procedure RaiseWindow (Win : Window)
      with Import => True, Convention => C, External_Name => "SDL_RaiseWindow";

end SDL.Video;
