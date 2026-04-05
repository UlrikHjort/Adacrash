-- ***************************************************************************
--                      Adacrash - Main
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
with SDL;
with SDL.Video;
with SDL.Render;
with SDL.Rect;
with SDL.Events;
with SDL.Keyboard;
with SDL.Timer;
with SDL_Types;
with Interfaces.C;
with Interfaces.C.Strings;
with Ada.Text_IO;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics;
with Ada.Numerics.Discrete_Random;

procedure Adacrash is

   use type Interfaces.C.int;
   use type SDL.Video.Window;
   use type SDL.Render.Renderer;
   use type SDL_Types.Uint32;
   use Ada.Numerics.Elementary_Functions;

   SCREEN_W    : constant := 800;
   SCREEN_H    : constant := 600;
   TRAIL_SIZE  : constant := 3;         -- normal trail half-width in pixels
   TRAIL_THICK : constant := 5;         -- thick-trail half-width (powerup)
   SPEED       : constant Float := 1.8;
   SPEED_BOOST : constant Float := 2.7; -- speed whil fast powerup active
   SPEED_SLOW  : constant Float := 0.9; -- speed while slow powerup active
   TURN_SPEED  : constant Float := Float (Ada.Numerics.Pi) / 55.0;
   MAX_TRAIL   : constant := 60_000;
   GAP_PERIOD  : constant := 90;
   GAP_LEN     : constant := 14;
   AI_SCAN_N    : constant := 13;
   AI_LOOKAHEAD : constant := 120;
   AI_SCAN_HALF : constant Float := Float (Ada.Numerics.Pi) / 2.0;
   HEAD_GRACE  : constant := 14;

   -- Power-up constants
   EFFECT_FRAMES  : constant := 360;   -- ~6 s at 60 fps
   RESPAWN_FRAMES : constant := 300;   -- ~5 s respawn delay
   MAX_PU         : constant := 5;
   PU_HALF        : constant := 7;
   PU_PICKUP_R_SQ : constant Float := 18.0 ** 2;

   -- -------------------------------------------------------------------------
   -- Types
   -- -------------------------------------------------------------------------

   type Trail_Entry is record
      X : Interfaces.C.int;
      Y : Interfaces.C.int;
   end record;

   type Trail_Array is array (1 .. MAX_TRAIL) of Trail_Entry;

   type Row_Type  is array (0 .. SCREEN_W - 1) of Boolean;
   type Grid_Type is array (0 .. SCREEN_H - 1) of Row_Type;

   type Player_Type is record
      X, Y        : Float;
      Angle       : Float;
      Alive       : Boolean;
      Frame_Count : Natural;
      In_Gap      : Boolean;
      Gap_Counter : Natural;
      -- Active effect timers (count down to 0)
      Fast_Timer  : Natural;   -- speed boost
      Slow_Timer  : Natural;   -- slowed down (by opponent's red powerup)
      Thick_Timer : Natural;   -- trail is thicker (by opponent's red powerup)
      Wrap_Timer  : Natural;   -- walls are passable (wrap to opposite side)
   end record;

   -- Power-up kinds:
   --   Green  (benefit picker):  Erase_All, Speed_Up, Wrap_Walls
   --   Red    (hurt opponent):   Thick_Opp, Slow_Opp
   type PU_Kind is (Erase_All, Speed_Up, Wrap_Walls, Thick_Opp, Slow_Opp);

   type PU_Rec is record
      X, Y       : Integer;
      Kind       : PU_Kind;
      Active     : Boolean;
      Respawn    : Natural;   -- frames remaining before re-spawn
   end record;

   type PU_Array is array (1 .. MAX_PU) of PU_Rec;

   -- Random generators for pwoerup placement
   subtype PU_RX is Integer range 60 .. SCREEN_W - 60;
   subtype PU_RY is Integer range 60 .. SCREEN_H - 60;
   package Rand_X is new Ada.Numerics.Discrete_Random (PU_RX);
   package Rand_Y is new Ada.Numerics.Discrete_Random (PU_RY);
   Gen_X : Rand_X.Generator;
   Gen_Y : Rand_Y.Generator;

   -- -------------------------------------------------------------------------
   -- State
   -- -------------------------------------------------------------------------

   Grid         : Grid_Type;
   P1_Trail     : Trail_Array;
   P1_Trail_Len : Natural := 0;
   P2_Trail     : Trail_Array;
   P2_Trail_Len : Natural := 0;

   P1, P2           : Player_Type;
   P1_Wins, P2_Wins : Natural := 0;

   Powerups : PU_Array;

   Win      : SDL.Video.Window;
   Renderer : SDL.Render.Renderer;
   Ev       : aliased SDL.Events.Event;
   Quit     : Boolean := False;
   Title    : Interfaces.C.Strings.chars_ptr;

   Left_Held  : Boolean := False;
   Right_Held : Boolean := False;

   type Game_State_Type is (Playing, Game_Over);
   State : Game_State_Type := Playing;

   -- -------------------------------------------------------------------------
   -- Helpers
   -- -------------------------------------------------------------------------

   procedure Set_Color (R, G, B : SDL_Types.Uint8) is
   begin
      if SDL.Render.SetRenderDrawColor (Renderer, R, G, B, 255) /= 0 then
         null;
      end if;
   end Set_Color;

   procedure Draw_Filled_Rect (X, Y, Half : Interfaces.C.int) is
      Rect : aliased SDL.Rect.Rectangle;
   begin
      Rect := (X => X - Half, Y => Y - Half, W => Half * 2, H => Half * 2);
      if SDL.Render.RenderFillRect (Renderer, Rect'Access) /= 0 then null; end if;
   end Draw_Filled_Rect;

   -- Mark a square neighbourhood of radius Half in the occupancy grid
   procedure Mark_Pixel (IX, IY, Half : Integer) is
   begin
      for DY in -Half .. Half loop
         for DX in -Half .. Half loop
            declare
               GX : constant Integer := IX + DX;
               GY : constant Integer := IY + DY;
            begin
               if GX >= 0 and then GX < SCREEN_W and then
                  GY >= 0 and then GY < SCREEN_H
               then
                  Grid (GY)(GX) := True;
               end if;
            end;
         end loop;
      end loop;
   end Mark_Pixel;

   -- Trail_Only = True skip the wall (out-of-bounds) kill check,
   -- used when a player has the Wrap_Walls powerup active.
   function Is_Collision (X, Y : Float;
                           Trail_Only : Boolean := False) return Boolean is
      IX : constant Integer := Integer (X);
      IY : constant Integer := Integer (Y);
   begin
      for DY in -1 .. 1 loop
         for DX in -1 .. 1 loop
            declare
               GX : constant Integer := IX + DX;
               GY : constant Integer := IY + DY;
            begin
               if GX < 0 or else GX >= SCREEN_W or else
                  GY < 0 or else GY >= SCREEN_H
               then
                  if not Trail_Only then return True; end if;
               elsif Grid (GY)(GX) then
                  return True;
               end if;
            end;
         end loop;
      end loop;
      return False;
   end Is_Collision;

   function Look_Ahead (X, Y, Angle : Float; Steps : Integer) return Integer is
      CX : Float := X;
      CY : Float := Y;
   begin
      for I in 1 .. Steps loop
         CX := CX + SPEED * Cos (Angle);
         CY := CY + SPEED * Sin (Angle);
         if Is_Collision (CX, CY) then
            return I - 1;
         end if;
      end loop;
      return Steps;
   end Look_Ahead;

   -- -------------------------------------------------------------------------
   -- AI
   -- -------------------------------------------------------------------------

   function Score_Direction (X, Y, Current_Angle, D_Angle : Float;
                              Opp_X, Opp_Y : Float) return Float is
      A    : constant Float   := Current_Angle + D_Angle;
      Free : constant Integer := Look_Ahead (X, Y, A, AI_LOOKAHEAD);

      function Wall_At (Steps : Integer) return Float is
         PX : constant Float := X + Float (Steps) * SPEED * Cos (A);
         PY : constant Float := Y + Float (Steps) * SPEED * Sin (A);
      begin
         return Float'Min (Float'Min (PX,                   Float (SCREEN_W) - 1.0 - PX),
                           Float'Min (PY,                   Float (SCREEN_H) - 1.0 - PY));
      end Wall_At;

      Min_Wall : constant Float :=
         Float'Min (Wall_At (Integer'Max (1, Free / 3)),
         Float'Min (Wall_At (Integer'Max (1, Free * 2 / 3)),
                    Wall_At (Integer'Max (1, Free))));

      Opp_Dx      : constant Float := Opp_X - X;
      Opp_Dy      : constant Float := Opp_Y - Y;
      Opp_Dist    : constant Float := Sqrt (Opp_Dx * Opp_Dx + Opp_Dy * Opp_Dy);
      Dir_Dot     : constant Float :=
         (Opp_Dx * Cos (A) + Opp_Dy * Sin (A)) / Float'Max (Opp_Dist, 1.0);
      Opp_Penalty : constant Float :=
         Float'Max (0.0, Dir_Dot) * (200.0 / Float'Max (Opp_Dist, 60.0)) * 25.0;

      Turn_Penalty : constant Float := abs (D_Angle) / TURN_SPEED * 1.5;
   begin
      return Float (Free) * 3.0
           + Float'Max (0.0, Min_Wall) * 2.0
           - Turn_Penalty
           - Opp_Penalty;
   end Score_Direction;

   procedure AI_Turn (P : in out Player_Type; Opp_X, Opp_Y : Float) is
      Step       : constant Float := 2.0 * AI_SCAN_HALF / Float (AI_SCAN_N - 1);
      Best_Score : Float := Float'First;
      Best_D     : Float := 0.0;
      D_Angle    : Float;
      S          : Float;
   begin
      for I in 0 .. AI_SCAN_N - 1 loop
         D_Angle := -AI_SCAN_HALF + Float (I) * Step;
         S       := Score_Direction (P.X, P.Y, P.Angle, D_Angle, Opp_X, Opp_Y);
         if S > Best_Score then
            Best_Score := S;
            Best_D     := D_Angle;
         end if;
      end loop;

      if Best_D < -0.001 then
         P.Angle := P.Angle - TURN_SPEED;
      elsif Best_D > 0.001 then
         P.Angle := P.Angle + TURN_SPEED;
      end if;
   end AI_Turn;

   -- -------------------------------------------------------------------------
   -- Power-ups
   -- -------------------------------------------------------------------------

   procedure Spawn_Powerup (I : Positive) is
   begin
      Powerups (I).X      := Rand_X.Random (Gen_X);
      Powerups (I).Y      := Rand_Y.Random (Gen_Y);
      Powerups (I).Active := True;
      Powerups (I).Respawn := 0;
   end Spawn_Powerup;

   procedure Apply_Powerup (Kind : PU_Kind; Picker_Is_P1 : Boolean) is
   begin
      case Kind is
         when Erase_All =>
            -- Clear all trails - the grid is reset, trail display arrays cleared.
            -- Both players get fresh HEAD_GRACE so they dont immediately
            -- self-collide; we reset Frame_Count to avoid marking old positions.
            Grid         := (others => (others => False));
            P1_Trail_Len := 0;
            P2_Trail_Len := 0;
            Ada.Text_IO.Put_Line ("[Powerup] All trails erased!");

         when Speed_Up =>
            if Picker_Is_P1 then
               P1.Fast_Timer := EFFECT_FRAMES;
               Ada.Text_IO.Put_Line ("[Powerup] You are faster!");
            else
               P2.Fast_Timer := EFFECT_FRAMES;
               Ada.Text_IO.Put_Line ("[Powerup] Computer is faster!");
            end if;

         when Wrap_Walls =>
            P1.Wrap_Timer := EFFECT_FRAMES;
            P2.Wrap_Timer := EFFECT_FRAMES;
            Ada.Text_IO.Put_Line ("[Powerup] Everyone can pass through walls!");

         when Thick_Opp =>
            if Picker_Is_P1 then
               P2.Thick_Timer := EFFECT_FRAMES;
               Ada.Text_IO.Put_Line ("[Powerup] Computer trail is thicker!");
            else
               P1.Thick_Timer := EFFECT_FRAMES;
               Ada.Text_IO.Put_Line ("[Powerup] Your trail is thicker!");
            end if;

         when Slow_Opp =>
            if Picker_Is_P1 then
               P2.Slow_Timer := EFFECT_FRAMES;
               Ada.Text_IO.Put_Line ("[Powerup] Computer is slowed!");
            else
               P1.Slow_Timer := EFFECT_FRAMES;
               Ada.Text_IO.Put_Line ("[Powerup] You are slowed!");
            end if;
      end case;
   end Apply_Powerup;

   procedure Update_Powerups is
      Dist_Sq : Float;
   begin
      for I in 1 .. MAX_PU loop
         if Powerups (I).Active then
            -- Check P1 pickup
            Dist_Sq := (P1.X - Float (Powerups (I).X)) ** 2
                      + (P1.Y - Float (Powerups (I).Y)) ** 2;
            if P1.Alive and then Dist_Sq < PU_PICKUP_R_SQ then
               Apply_Powerup (Powerups (I).Kind, True);
               Powerups (I).Active  := False;
               Powerups (I).Respawn := RESPAWN_FRAMES;

            else
               -- Check P2 pickup
               Dist_Sq := (P2.X - Float (Powerups (I).X)) ** 2
                         + (P2.Y - Float (Powerups (I).Y)) ** 2;
               if P2.Alive and then Dist_Sq < PU_PICKUP_R_SQ then
                  Apply_Powerup (Powerups (I).Kind, False);
                  Powerups (I).Active  := False;
                  Powerups (I).Respawn := RESPAWN_FRAMES;
               end if;
            end if;

         elsif Powerups (I).Respawn > 0 then
            Powerups (I).Respawn := Powerups (I).Respawn - 1;
            if Powerups (I).Respawn = 0 then
               Spawn_Powerup (I);
            end if;
         end if;
      end loop;
   end Update_Powerups;

   procedure Tick_Effect_Timers is
      procedure Tick (T : in out Natural) is
      begin if T > 0 then T := T - 1; end if; end Tick;
   begin
      Tick (P1.Fast_Timer);  Tick (P1.Slow_Timer);  Tick (P1.Thick_Timer);  Tick (P1.Wrap_Timer);
      Tick (P2.Fast_Timer);  Tick (P2.Slow_Timer);  Tick (P2.Thick_Timer);  Tick (P2.Wrap_Timer);
   end Tick_Effect_Timers;

   -- -------------------------------------------------------------------------
   -- Player update
   -- -------------------------------------------------------------------------

   procedure Update_Player (P          : in out Player_Type;
                             Is_AI      : Boolean;
                             Turn_L     : Boolean;
                             Turn_R     : Boolean;
                             Opp_X      : Float;
                             Opp_Y      : Float;
                             Trail      : in out Trail_Array;
                             Trail_Len  : in out Natural) is
      Eff_Speed  : constant Float :=
         (if P.Fast_Timer > 0 then SPEED_BOOST
          elsif P.Slow_Timer > 0 then SPEED_SLOW
          else SPEED);
      Trail_Half : constant Integer :=
         (if P.Thick_Timer > 0 then TRAIL_THICK else TRAIL_SIZE);
      New_X, New_Y : Float;
   begin
      if not P.Alive then
         return;
      end if;

      if Is_AI then
         AI_Turn (P, Opp_X, Opp_Y);
      else
         if Turn_L then P.Angle := P.Angle - TURN_SPEED; end if;
         if Turn_R then P.Angle := P.Angle + TURN_SPEED; end if;
      end if;

      New_X := P.X + Eff_Speed * Cos (P.Angle);
      New_Y := P.Y + Eff_Speed * Sin (P.Angle);

      P.Frame_Count := P.Frame_Count + 1;
      if P.In_Gap then
         P.Gap_Counter := P.Gap_Counter + 1;
         if P.Gap_Counter >= GAP_LEN then
            P.In_Gap      := False;
            P.Gap_Counter := 0;
         end if;
      elsif P.Frame_Count >= GAP_PERIOD then
         P.In_Gap      := True;
         P.Frame_Count := 0;
         P.Gap_Counter := 0;
      end if;

      -- Wrap-walls: bring position back in-bounds, then only trail-collide.
      -- Normal mode: regular collision including walls.
      if P.Wrap_Timer > 0 then
         if New_X < 2.0 then              New_X := Float (SCREEN_W) - 4.0;
         elsif New_X > Float (SCREEN_W) - 3.0 then New_X := 3.0; end if;
         if New_Y < 2.0 then              New_Y := Float (SCREEN_H) - 4.0;
         elsif New_Y > Float (SCREEN_H) - 3.0 then New_Y := 3.0; end if;
         if Is_Collision (New_X, New_Y, Trail_Only => True) then
            P.Alive := False;
            return;
         end if;
      else
         if Is_Collision (New_X, New_Y) then
            P.Alive := False;
            return;
         end if;
      end if;

      P.X := New_X;
      P.Y := New_Y;

      if not P.In_Gap and then Trail_Len < MAX_TRAIL then
         Trail_Len := Trail_Len + 1;
         Trail (Trail_Len) := (X => Interfaces.C.int (Integer (P.X)),
                               Y => Interfaces.C.int (Integer (P.Y)));
         if Trail_Len > HEAD_GRACE then
            Mark_Pixel (Integer (Trail (Trail_Len - HEAD_GRACE).X),
                        Integer (Trail (Trail_Len - HEAD_GRACE).Y),
                        Trail_Half);
         end if;
      end if;
   end Update_Player;

   -- -------------------------------------------------------------------------
   -- Rendering
   -- -------------------------------------------------------------------------

   procedure Render_Frame is
      Rect   : aliased SDL.Rect.Rectangle;
      Border : aliased SDL.Rect.Rectangle;

      -- Visual size of each trail segment - expand  when thick powerup active
      P1_Half : constant Interfaces.C.int :=
         (if P1.Thick_Timer > 0 then TRAIL_THICK else TRAIL_SIZE);
      P2_Half : constant Interfaces.C.int :=
         (if P2.Thick_Timer > 0 then TRAIL_THICK else TRAIL_SIZE);

   begin
      Set_Color (0, 0, 0);
      if SDL.Render.RenderClear (Renderer) /= 0 then null; end if;

      Border := (X => 0, Y => 0, W => SCREEN_W, H => SCREEN_H);
      if State = Game_Over then
         Set_Color (200, 50, 50);
      elsif P1.Wrap_Timer > 0 or P2.Wrap_Timer > 0 then
         Set_Color (80, 180, 255);  -- blue border = walls gone
      else
         Set_Color (70, 70, 70);
      end if;
      if SDL.Render.RenderDrawRect (Renderer, Border'Access) /= 0 then null; end if;

      -- P1 trail (cyan, dimmer if slowed)
      if P1.Slow_Timer > 0 then
         Set_Color (0, 100, 150);
      else
         Set_Color (0, 160, 230);
      end if;
      for I in 1 .. P1_Trail_Len loop
         Rect := (X => P1_Trail (I).X - P1_Half,
                  Y => P1_Trail (I).Y - P1_Half,
                  W => P1_Half * 2,
                  H => P1_Half * 2);
         if SDL.Render.RenderFillRect (Renderer, Rect'Access) /= 0 then null; end if;
      end loop;

      -- P2 trail (orange, dimmer if slowed)
      if P2.Slow_Timer > 0 then
         Set_Color (150, 75, 0);
      else
         Set_Color (230, 120, 0);
      end if;
      for I in 1 .. P2_Trail_Len loop
         Rect := (X => P2_Trail (I).X - P2_Half,
                  Y => P2_Trail (I).Y - P2_Half,
                  W => P2_Half * 2,
                  H => P2_Half * 2);
         if SDL.Render.RenderFillRect (Renderer, Rect'Access) /= 0 then null; end if;
      end loop;

      -- Player heads (brighter, or yellow-tinted when fast)
      if P1.Alive then
         if P1.Fast_Timer > 0 then Set_Color (255, 255, 100);
         else                       Set_Color (160, 230, 255); end if;
         Draw_Filled_Rect (Interfaces.C.int (Integer (P1.X)),
                           Interfaces.C.int (Integer (P1.Y)),
                           P1_Half + 1);
      end if;
      if P2.Alive then
         if P2.Fast_Timer > 0 then Set_Color (255, 255, 100);
         else                       Set_Color (255, 200, 80); end if;
         Draw_Filled_Rect (Interfaces.C.int (Integer (P2.X)),
                           Interfaces.C.int (Integer (P2.Y)),
                           P2_Half + 1);
      end if;

      -- Power-ups
      for I in 1 .. MAX_PU loop
         if Powerups (I).Active then
            declare
               PX : constant Interfaces.C.int := Interfaces.C.int (Powerups (I).X);
               PY : constant Interfaces.C.int := Interfaces.C.int (Powerups (I).Y);
            begin
               -- White border
               Set_Color (200, 200, 200);
               Draw_Filled_Rect (PX, PY, PU_HALF + 2);
               -- Colour fill
               case Powerups (I).Kind is
                  when Erase_All  => Set_Color (50,  220,  80);   -- bright gren
                  when Speed_Up   => Set_Color (150, 255,  50);   -- yellow-green
                  when Wrap_Walls => Set_Color (80,  180, 255);   -- blue
                  when Thick_Opp  => Set_Color (220,  50,  50);   -- bright red
                  when Slow_Opp   => Set_Color (220, 130,  30);   -- orange-red
               end case;
               Draw_Filled_Rect (PX, PY, PU_HALF);
            end;
         end if;
      end loop;

      SDL.Render.RenderPresent (Renderer);
   end Render_Frame;

   -- -------------------------------------------------------------------------
   -- Init
   -- -------------------------------------------------------------------------

   procedure Init_Game is
   begin
      Grid         := (others => (others => False));
      P1_Trail_Len := 0;
      P2_Trail_Len := 0;

      P1 := (X => 200.0, Y => 300.0, Angle => 0.0, Alive => True,
             Frame_Count => 0, In_Gap => False, Gap_Counter => 0,
             Fast_Timer => 0, Slow_Timer => 0, Thick_Timer => 0, Wrap_Timer => 0);

      P2 := (X => 600.0, Y => 300.0,
             Angle       => Float (Ada.Numerics.Pi) / 2.0,
             Alive       => True,
             Frame_Count => GAP_PERIOD / 2,
             In_Gap => False, Gap_Counter => 0,
             Fast_Timer => 0, Slow_Timer => 0, Thick_Timer => 0, Wrap_Timer => 0);

      -- Assign fixed kinds to the four slots, then scatter them randomly
      Powerups (1) := (Kind => Erase_All, Active => False, Respawn => 60,
                       X => 0, Y => 0);
      Powerups (2) := (Kind => Speed_Up,  Active => False, Respawn => 80,
                       X => 0, Y => 0);
      Powerups (3) := (Kind => Wrap_Walls, Active => False, Respawn => 90,
                       X => 0, Y => 0);
      Powerups (4) := (Kind => Thick_Opp, Active => False, Respawn => 100,
                       X => 0, Y => 0);
      Powerups (5) := (Kind => Slow_Opp,  Active => False, Respawn => 120,
                       X => 0, Y => 0);

      Left_Held  := False;
      Right_Held := False;
      State      := Playing;
   end Init_Game;

begin
   if SDL.Init (SDL.SDL_INIT_VIDEO) /= 0 then
      Ada.Text_IO.Put_Line ("SDL_Init failed");
      return;
   end if;

   Rand_X.Reset (Gen_X);
   Rand_Y.Reset (Gen_Y);

   Title := Interfaces.C.Strings.New_String ("Adacrash");
   Win := SDL.Video.CreateWindow
      (Title => Title,
       X     => 16#2FFF0000#,
       Y     => 16#2FFF0000#,
       W     => SCREEN_W,
       H     => SCREEN_H,
       Flags => SDL.Video.SDL_WINDOW_SHOWN);

   if Win = SDL.Video.Null_Window then
      Ada.Text_IO.Put_Line ("CreateWindow failed");
      SDL.Quit;
      return;
   end if;

   Renderer := SDL.Render.CreateRenderer
      (Win   => Win,
       Index => -1,
       Flags => SDL.Render.SDL_RENDERER_ACCELERATED or
                SDL.Render.SDL_RENDERER_PRESENTVSYNC);

   if Renderer = SDL.Render.Null_Renderer then
      Ada.Text_IO.Put_Line ("CreateRenderer failed");
      SDL.Video.DestroyWindow (Win);
      SDL.Quit;
      return;
   end if;

   Ada.Text_IO.Put_Line ("=== Adacrash ===");
   Ada.Text_IO.Put_Line ("Cyan = You  |  Orange = Computer");
   Ada.Text_IO.Put_Line ("LEFT / RIGHT arrows to steer");
   Ada.Text_IO.Put_Line ("Power-ups: green = good for you, red = hurts opponent");
   Ada.Text_IO.Put_Line ("  Bright green = Erase all trails");
   Ada.Text_IO.Put_Line ("  Yellow-green  = Speed boost (yourself)");
   Ada.Text_IO.Put_Line ("  Red           = Opponent trail gets thicker");
   Ada.Text_IO.Put_Line ("  Orange-red    = Opponent is slowed");
   Ada.Text_IO.Put_Line ("SPACE to restart  |  ESC to quit");

   Init_Game;

   while not Quit loop

      while SDL.Events.PollEvent (Ev'Access) = 1 loop
         if Ev.Common.Event_Type = SDL.Events.SDL_QUIT then
            Quit := True;

         elsif Ev.Common.Event_Type = SDL.Events.SDL_KEYDOWN then
            case Ev.Key.Keysym.Sym is
               when SDL.Keyboard.SDLK_ESCAPE => Quit       := True;
               when SDL.Keyboard.SDLK_LEFT   => Left_Held  := True;
               when SDL.Keyboard.SDLK_RIGHT  => Right_Held := True;
               when SDL.Keyboard.SDLK_SPACE  =>
                  if State = Game_Over then
                     Init_Game;
                  end if;
               when others => null;
            end case;

         elsif Ev.Common.Event_Type = SDL.Events.SDL_KEYUP then
            case Ev.Key.Keysym.Sym is
               when SDL.Keyboard.SDLK_LEFT  => Left_Held  := False;
               when SDL.Keyboard.SDLK_RIGHT => Right_Held := False;
               when others => null;
            end case;
         end if;
      end loop;

      if State = Playing then
         Update_Player (P1, False, Left_Held, Right_Held, P2.X, P2.Y, P1_Trail, P1_Trail_Len);
         Update_Player (P2, True,  False,     False,      P1.X, P1.Y, P2_Trail, P2_Trail_Len);
         Update_Powerups;
         Tick_Effect_Timers;

         if not P1.Alive or not P2.Alive then
            State := Game_Over;
            if not P1.Alive and not P2.Alive then
               Ada.Text_IO.Put_Line ("DRAW!");
            elsif not P1.Alive then
               P2_Wins := P2_Wins + 1;
               Ada.Text_IO.Put_Line
                  ("Computer wins!  You:" & P1_Wins'Img &
                   "  Computer:" & P2_Wins'Img);
            else
               P1_Wins := P1_Wins + 1;
               Ada.Text_IO.Put_Line
                  ("You win!  You:" & P1_Wins'Img &
                   "  Computer:" & P2_Wins'Img);
            end if;
            Ada.Text_IO.Put_Line ("Pres SPACE to play again");
         end if;
      end if;

      Render_Frame;

   end loop;

   SDL.Render.DestroyRenderer (Renderer);
   SDL.Video.DestroyWindow (Win);
   Interfaces.C.Strings.Free (Title);
   SDL.Quit;
   Ada.Text_IO.Put_Line ("Bye!");

end Adacrash;
