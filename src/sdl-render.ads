-- ***************************************************************************
--                      Adacrash - Sdl.Render
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
with SDL.Video;
with SDL.Rect;
with SDL.Surface;

package SDL.Render is

   use Interfaces.C;

   -- Opaque renderer type
   type Renderer is new System.Address;
   Null_Renderer : constant Renderer := Renderer (System.Null_Address);

   -- Opaque texture type
   type Texture is new System.Address;
   Null_Texture : constant Texture := Texture (System.Null_Address);

   -- Renderer flags
   SDL_RENDERER_SOFTWARE      : constant Uint32 := 16#00000001#;
   SDL_RENDERER_ACCELERATED   : constant Uint32 := 16#00000002#;
   SDL_RENDERER_PRESENTVSYNC  : constant Uint32 := 16#00000004#;
   SDL_RENDERER_TARGETTEXTURE : constant Uint32 := 16#00000008#;

   -- Blend modes
   type BlendMode is
      (SDL_BLENDMODE_NONE,
       SDL_BLENDMODE_BLEND,
       SDL_BLENDMODE_ADD,
       SDL_BLENDMODE_MOD)
      with Convention => C;

   -- Flip modes for rendering
   type RendererFlip is
      (SDL_FLIP_NONE,
       SDL_FLIP_HORIZONTAL,
       SDL_FLIP_VERTICAL)
      with Convention => C;
   for RendererFlip use
      (SDL_FLIP_NONE       => 16#00000000#,
       SDL_FLIP_HORIZONTAL => 16#00000001#,
       SDL_FLIP_VERTICAL   => 16#00000002#);

   -- Create a 2D rendering context
   function CreateRenderer
      (Win    : SDL.Video.Window;
       Index  : int;
       Flags  : Uint32) return Renderer
      with Import => True, Convention => C, External_Name => "SDL_CreateRenderer";

   -- Destroy rendering context
   procedure DestroyRenderer (Ren : Renderer)
      with Import => True, Convention => C, External_Name => "SDL_DestroyRenderer";

   -- Clear the rendering target with the draw color
   function RenderClear (Ren : Renderer) return int
      with Import => True, Convention => C, External_Name => "SDL_RenderClear";

   -- Update screen with rendering performed
   procedure RenderPresent (Ren : Renderer)
      with Import => True, Convention => C, External_Name => "SDL_RenderPresent";

   -- Set the color for drawing operations
   function SetRenderDrawColor
      (Ren : Renderer;
       R   : Uint8;
       G   : Uint8;
       B   : Uint8;
       A   : Uint8) return int
      with Import => True, Convention => C, External_Name => "SDL_SetRenderDrawColor";

   -- Get the color used for drawing operations
   function GetRenderDrawColor
      (Ren : Renderer;
       R   : access Uint8;
       G   : access Uint8;
       B   : access Uint8;
       A   : access Uint8) return int
      with Import => True, Convention => C, External_Name => "SDL_GetRenderDrawColor";

   -- Draw a point
   function RenderDrawPoint
      (Ren : Renderer;
       X   : int;
       Y   : int) return int
      with Import => True, Convention => C, External_Name => "SDL_RenderDrawPoint";

   -- Draw a line
   function RenderDrawLine
      (Ren : Renderer;
       X1  : int;
       Y1  : int;
       X2  : int;
       Y2  : int) return int
      with Import => True, Convention => C, External_Name => "SDL_RenderDrawLine";

   -- Draw a rectangle
   function RenderDrawRect
      (Ren  : Renderer;
       Rect : access SDL.Rect.Rectangle) return int
      with Import => True, Convention => C, External_Name => "SDL_RenderDrawRect";

   -- Fill a rectangle
   function RenderFillRect
      (Ren  : Renderer;
       Rect : access SDL.Rect.Rectangle) return int
      with Import => True, Convention => C, External_Name => "SDL_RenderFillRect";

   -- Set blend mode
   function SetRenderDrawBlendMode
      (Ren  : Renderer;
       Mode : BlendMode) return int
      with Import => True, Convention => C, External_Name => "SDL_SetRenderDrawBlendMode";

   -- Create texture from surface
   function CreateTextureFromSurface
      (Ren  : Renderer;
       Surf : SDL.Surface.Surface) return Texture
      with Import => True, Convention => C, External_Name => "SDL_CreateTextureFromSurface";

   -- Destroy texture
   procedure DestroyTexture (Tex : Texture)
      with Import => True, Convention => C, External_Name => "SDL_DestroyTexture";

   -- Query texture properties
   function QueryTexture
      (Tex    : Texture;
       Format : access int;
       Access_Mode : access int;
       W      : access int;
       H      : access int) return int
      with Import => True, Convention => C, External_Name => "SDL_QueryTexture";

   -- Set texture blend mode
   function SetTextureBlendMode
      (Tex  : Texture;
       Mode : BlendMode) return int
      with Import => True, Convention => C, External_Name => "SDL_SetTextureBlendMode";

   -- Set texture alpha modulation
   function SetTextureAlphaMod
      (Tex   : Texture;
       Alpha : Uint8) return int
      with Import => True, Convention => C, External_Name => "SDL_SetTextureAlphaMod";

   -- Set texture color modulation
   function SetTextureColorMod
      (Tex : Texture;
       R   : Uint8;
       G   : Uint8;
       B   : Uint8) return int
      with Import => True, Convention => C, External_Name => "SDL_SetTextureColorMod";

   -- Copy texture to renderer
   function RenderCopy
      (Ren  : Renderer;
       Tex  : Texture;
       Srcrect : access SDL.Rect.Rectangle;
       Dstrect : access SDL.Rect.Rectangle) return int
      with Import => True, Convention => C, External_Name => "SDL_RenderCopy";

   -- Copy texture to renderer with rotation and flipping
   function RenderCopyEx
      (Ren    : Renderer;
       Tex    : Texture;
       Srcrect : access SDL.Rect.Rectangle;
       Dstrect : access SDL.Rect.Rectangle;
       Angle  : Interfaces.C.double;
       Center : access SDL.Rect.Point;
       Flip   : RendererFlip) return int
      with Import => True, Convention => C, External_Name => "SDL_RenderCopyEx";

end SDL.Render;
