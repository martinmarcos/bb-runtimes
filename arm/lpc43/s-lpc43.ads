------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--          Copyright (C) 2012-2016, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- You should have received a copy of the GNU General Public License along  --
-- with this library; see the file COPYING3. If not, see:                   --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  This file provides register definitions for the STM32Fx (ARM Cortex M4/7)
--  microcontrollers from ST Microelectronics.

with Interfaces.LPC43.CGU;

package System.LPC43 is
   pragma No_Elaboration_Code_All;
   pragma Preelaborate (System.LPC43);

   --  Constants for CGU PLL1_CTRL register

   subtype PLL1M_Range is Integer range 1 .. 256;
   subtype PLL1N_Range is Integer range 1 .. 4;
   subtype PLL1P_Range is Integer range 1 .. 8
     with Static_Predicate => (case PLL1P_Range is
                                 when 1 | 2 | 4 | 8 => True,
                                 when others => False);

   subtype XTALCLK_Range   is Integer range   1_000_000 ..  25_000_000;
   subtype PLL1CLKIN_Range is Integer range   1_000_000 ..  50_000_000;
   subtype PLL1CCO_Range   is Integer range 156_000_000 .. 320_000_000;
   subtype PLL1CLKOU_Range is Integer range   9_750_000 .. 320_000_000;
   subtype SYSCLK_Range    is Integer range           1 .. 204_000_000;
   subtype MIDFREQ_Range   is Integer range  90_000_000 .. 110_000_000;

   --  These internal low and high speed clocks are fixed (do not modify)

   IRCCLK : constant := 12_000_000;
   I32KCLK : constant :=     32_000;

   CHIPID_LPC43Flashless       : constant := 16#5906002B#;
   --  LPC4370/50/30/20/10 and LPC43S70/S50/S30/S20 (flashless parts)
   CHIPID_LPC43Flashless2      : constant := 16#6906002B#;
   --  LPC4370/50/30/20/10 and LPC43S70/S50/S30/S20 (flashless parts)
   CHIPID_LPC43FlashRevHyphen  : constant := 16#4906002B#;
   --  LPC436x/5x/3x/2x/1x, LPC43S6x/S5x/S3x (Rev - parts with on-chip flash)
   CHIPID_LPC43FlashRevA       : constant := 16#7906002B#;
   --  LPC436x/5x/3x/2x/1x, LPC43S6x/S5x/S3x (Rev A parts with on-chip flash)

end System.LPC43;
