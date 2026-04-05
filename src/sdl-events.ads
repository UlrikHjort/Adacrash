-- ***************************************************************************
--                      Adacrash - Sdl.Events
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
with System;
with SDL_Types; use SDL_Types;
with SDL.Keyboard;

package SDL.Events is

   use Interfaces.C;

   -- Event types
   SDL_FIRSTEVENT              : constant := 0;
   SDL_QUIT                    : constant := 16#100#;
   SDL_APP_TERMINATING         : constant := 16#101#;
   SDL_APP_LOWMEMORY           : constant := 16#102#;
   SDL_APP_WILLENTERBACKGROUND : constant := 16#103#;
   SDL_APP_DIDENTERBACKGROUND  : constant := 16#104#;
   SDL_APP_WILLENTERFOREGROUND : constant := 16#105#;
   SDL_APP_DIDENTERFOREGROUND  : constant := 16#106#;
   
   SDL_WINDOWEVENT             : constant := 16#200#;
   SDL_SYSWMEVENT              : constant := 16#201#;
   
   SDL_KEYDOWN                 : constant := 16#300#;
   SDL_KEYUP                   : constant := 16#301#;
   SDL_TEXTEDITING             : constant := 16#302#;
   SDL_TEXTINPUT               : constant := 16#303#;
   
   SDL_MOUSEMOTION             : constant := 16#400#;
   SDL_MOUSEBUTTONDOWN         : constant := 16#401#;
   SDL_MOUSEBUTTONUP           : constant := 16#402#;
   SDL_MOUSEWHEEL              : constant := 16#403#;

   -- Common event structure
   type CommonEvent is record
      Event_Type : Uint32;
      Timestamp  : Uint32;
   end record
      with Convention => C;

   -- Keyboard event
   type KeyboardEvent is record
      Event_Type : Uint32;
      Timestamp  : Uint32;
      WindowID   : Uint32;
      State      : Uint8;
      Repeat     : Uint8;
      Padding2   : Uint8;
      Padding3   : Uint8;
      Keysym     : SDL.Keyboard.Keysym;
   end record
      with Convention => C;

   -- Mouse motion event
   type MouseMotionEvent is record
      Event_Type : Uint32;
      Timestamp  : Uint32;
      WindowID   : Uint32;
      Which      : Uint32;
      State      : Uint32;
      X          : Sint32;
      Y          : Sint32;
      Xrel       : Sint32;
      Yrel       : Sint32;
   end record
      with Convention => C;

   -- Mouse button event
   type MouseButtonEvent is record
      Event_Type : Uint32;
      Timestamp  : Uint32;
      WindowID   : Uint32;
      Which      : Uint32;
      Button     : Uint8;
      State      : Uint8;
      Clicks     : Uint8;
      Padding1   : Uint8;
      X          : Sint32;
      Y          : Sint32;
   end record
      with Convention => C;

   -- Mouse wheel event
   type MouseWheelEvent is record
      Event_Type : Uint32;
      Timestamp  : Uint32;
      WindowID   : Uint32;
      Which      : Uint32;
      X          : Sint32;
      Y          : Sint32;
      Direction  : Uint32;
   end record
      with Convention => C;

   -- Event union (simplified - contains padding for largest event)
   type Event (Event_Type : Uint32 := SDL_FIRSTEVENT) is record
      case Event_Type is
         when SDL_QUIT =>
            Common : CommonEvent;
         when SDL_KEYDOWN | SDL_KEYUP =>
            Key : KeyboardEvent;
         when SDL_MOUSEMOTION =>
            Motion : MouseMotionEvent;
         when SDL_MOUSEBUTTONDOWN | SDL_MOUSEBUTTONUP =>
            Button : MouseButtonEvent;
         when SDL_MOUSEWHEEL =>
            Wheel : MouseWheelEvent;
         when others =>
            Padding : Interfaces.C.char_array (1 .. 56);
      end case;
   end record
      with Convention => C, Unchecked_Union;

   -- Poll for currently pending events
   -- Returns 1 if event available, 0 if not
   function PollEvent (Event : access SDL.Events.Event) return int
      with Import => True, Convention => C, External_Name => "SDL_PollEvent";

   -- Wait indefinitely for next event
   function WaitEvent (Event : access SDL.Events.Event) return int
      with Import => True, Convention => C, External_Name => "SDL_WaitEvent";

   -- Wait for event with timeout
   function WaitEventTimeout
      (Event   : access SDL.Events.Event;
       Timeout : int) return int
      with Import => True, Convention => C, External_Name => "SDL_WaitEventTimeout";

end SDL.Events;
