-- ***************************************************************************
--                      Adacrash - Sdl.Keyboard
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
with SDL_Types; use SDL_Types;

package SDL.Keyboard is

   use Interfaces.C;

   -- Scancode definitions (physical key positions)
   type Scancode is
      (SDL_SCANCODE_UNKNOWN,
       SDL_SCANCODE_A, SDL_SCANCODE_B, SDL_SCANCODE_C, SDL_SCANCODE_D,
       SDL_SCANCODE_E, SDL_SCANCODE_F, SDL_SCANCODE_G, SDL_SCANCODE_H,
       SDL_SCANCODE_I, SDL_SCANCODE_J, SDL_SCANCODE_K, SDL_SCANCODE_L,
       SDL_SCANCODE_M, SDL_SCANCODE_N, SDL_SCANCODE_O, SDL_SCANCODE_P,
       SDL_SCANCODE_Q, SDL_SCANCODE_R, SDL_SCANCODE_S, SDL_SCANCODE_T,
       SDL_SCANCODE_U, SDL_SCANCODE_V, SDL_SCANCODE_W, SDL_SCANCODE_X,
       SDL_SCANCODE_Y, SDL_SCANCODE_Z)
      with Convention => C;
   for Scancode use
      (SDL_SCANCODE_UNKNOWN => 0,
       SDL_SCANCODE_A => 4, SDL_SCANCODE_B => 5, SDL_SCANCODE_C => 6, SDL_SCANCODE_D => 7,
       SDL_SCANCODE_E => 8, SDL_SCANCODE_F => 9, SDL_SCANCODE_G => 10, SDL_SCANCODE_H => 11,
       SDL_SCANCODE_I => 12, SDL_SCANCODE_J => 13, SDL_SCANCODE_K => 14, SDL_SCANCODE_L => 15,
       SDL_SCANCODE_M => 16, SDL_SCANCODE_N => 17, SDL_SCANCODE_O => 18, SDL_SCANCODE_P => 19,
       SDL_SCANCODE_Q => 20, SDL_SCANCODE_R => 21, SDL_SCANCODE_S => 22, SDL_SCANCODE_T => 23,
       SDL_SCANCODE_U => 24, SDL_SCANCODE_V => 25, SDL_SCANCODE_W => 26, SDL_SCANCODE_X => 27,
       SDL_SCANCODE_Y => 28, SDL_SCANCODE_Z => 29);

   -- Virtual key codes
   subtype Keycode is Sint32;
   
   SDLK_UNKNOWN  : constant Keycode := 0;
   SDLK_RETURN   : constant Keycode := 16#0D#;
   SDLK_ESCAPE   : constant Keycode := 16#1B#;
   SDLK_SPACE    : constant Keycode := 16#20#;
   SDLK_a        : constant Keycode := 16#61#;
   SDLK_b        : constant Keycode := 16#62#;
   SDLK_c        : constant Keycode := 16#63#;
   SDLK_d        : constant Keycode := 16#64#;
   SDLK_e        : constant Keycode := 16#65#;
   SDLK_w        : constant Keycode := 16#77#;
   SDLK_s        : constant Keycode := 16#73#;
   SDLK_UP       : constant Keycode := 16#40000052#;
   SDLK_DOWN     : constant Keycode := 16#40000051#;
   SDLK_RIGHT    : constant Keycode := 16#4000004F#;
   SDLK_LEFT     : constant Keycode := 16#40000050#;

   -- Key modifiers
   KMOD_NONE     : constant Uint16 := 16#0000#;
   KMOD_LSHIFT   : constant Uint16 := 16#0001#;
   KMOD_RSHIFT   : constant Uint16 := 16#0002#;
   KMOD_LCTRL    : constant Uint16 := 16#0040#;
   KMOD_RCTRL    : constant Uint16 := 16#0080#;
   KMOD_LALT     : constant Uint16 := 16#0100#;
   KMOD_RALT     : constant Uint16 := 16#0200#;

   -- Key symbol structure
   type Keysym is record
      Scancode : SDL.Keyboard.Scancode;
      Sym      : Keycode;
      Modifiers : Uint16;
      Unused   : Uint32;
   end record
      with Convention => C;

end SDL.Keyboard;
