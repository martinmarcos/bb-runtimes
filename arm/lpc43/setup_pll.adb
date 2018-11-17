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

pragma Ada_2012; -- To work around pre-commit check?
pragma Suppress (All_Checks);

--  This initialization procedure mainly initializes the PLLs and
--  all derived clocks.

--  with Ada.Unchecked_Conversion;

with Interfaces.LPC43;           use Interfaces.LPC43;
with Interfaces.LPC43.CREG;      use Interfaces.LPC43.CREG;
with Interfaces.LPC43.CGU;       use Interfaces.LPC43.CGU;
--  with Interfaces.LPC43.GPIO_PORT; use Interfaces.LPC43.GPIO_PORT;

with System.BB.Board_Parameters; use System.BB.Board_Parameters;
with System.LPC43;               use System.LPC43;

procedure Setup_Pll is

   BYPASS        : constant PLL1_CTRL_ENUM_1 := Normal;
   CLK_SEL       : constant PLL1_CTRL_ENUM_6 := Crystal_Oscillator;

   FBSEL         : constant PLL1_CTRL_ENUM_2 := Cco_Out;
   DIRECT        : constant PLL1_CTRL_ENUM_3 := Enabled;
   PSEL_Val      : constant Integer := 1;
   NSEL_Val      : constant Integer := 1;
   MSEL_Val      : constant Integer := 17;

   MIDFREQ_FBSEL    : constant PLL1_CTRL_ENUM_2 := Cco_Out;
   MIDFREQ_DIRECT   : constant PLL1_CTRL_ENUM_3 := Disabled;
   MIDFREQ_PSEL_Val : constant Integer := 1;
   MIDFREQ_NSEL_Val : constant Integer := 1;
   MIDFREQ_MSEL_Val : constant Integer := 17;

   procedure Setup_Flash_Acceleration;
   procedure Enable_Crystal;
   procedure Setup_Core_Clock;
   procedure Setup_Clock_Bases;

   ------------------------------
   -- Setup Flash Acceleration --
   ------------------------------

   procedure Setup_Flash_Acceleration is
      FLASHTIM_A : constant FLASHCFGA_ENUM :=
              (case Flash_Access_Time is
                   when 0 => FLASHCFGA_ENUM_1_Base_M4_Clk_Clock,
                   when 1 => FLASHCFGA_ENUM_2_Base_M4_Clk_Clocks,
                   when 2 => FLASHCFGA_ENUM_3_Base_M4_Clk_Clocks,
                   when 3 => FLASHCFGA_ENUM_4_Base_M4_Clk_Clocks,
                   when 4 => FLASHCFGA_ENUM_5_Base_M4_Clk_Clocks,
                   when 5 => FLASHCFGA_ENUM_6_Base_M4_Clk_Clocks,
                   when 6 => FLASHCFGA_ENUM_7_Base_M4_Clk_Clocks,
                   when 7 => FLASHCFGA_ENUM_8_Base_M4_Clk_Clocks,
                   when 8 => FLASHCFGA_ENUM_9_Base_M4_Clk_Clocks,
                   when others => FLASHCFGA_ENUM_10_Base_M4_Clk_Clock
              );
      FLASHTIM_B : constant FLASHCFGB_ENUM :=
              (case Flash_Access_Time is
                   when 0 => FLASHCFGB_ENUM_1_Base_M4_Clk_Clock,
                   when 1 => FLASHCFGB_ENUM_2_Base_M4_Clk_Clocks,
                   when 2 => FLASHCFGB_ENUM_3_Base_M4_Clk_Clocks,
                   when 3 => FLASHCFGB_ENUM_4_Base_M4_Clk_Clocks,
                   when 4 => FLASHCFGB_ENUM_5_Base_M4_Clk_Clocks,
                   when 5 => FLASHCFGB_ENUM_6_Base_M4_Clk_Clocks,
                   when 6 => FLASHCFGB_ENUM_7_Base_M4_Clk_Clocks,
                   when 7 => FLASHCFGB_ENUM_8_Base_M4_Clk_Clocks,
                   when 8 => FLASHCFGB_ENUM_9_Base_M4_Clk_Clocks,
                   when others => FLASHCFGB_ENUM_10_Base_M4_Clk_Clock
              );
   begin

      CREG_Periph.FLASHCFGA.FLASHTIM := FLASHTIM_A;
      CREG_Periph.FLASHCFGB.FLASHTIM := FLASHTIM_B;

   end Setup_Flash_Acceleration;

   XTAL_Enabled  : constant Boolean := (if CLK_SEL = Crystal_Oscillator then
                                            True else False);

   --------------------
   -- Enable_Crystal --
   --------------------

   procedure Enable_Crystal is
      delay_ticks : Integer := 1000;
      HF : constant XTAL_OSC_CTRL_ENUM_2 :=
                                    (if XTAL_Clock_Frequency > 20_000_000 then
                                       High
                                    else
                                       Low);
   begin

      CGU_Periph.XTAL_OSC_CTRL.ENABLE := Enable;

      CGU_Periph.XTAL_OSC_CTRL.BYPASS := Crystal;

      CGU_Periph.XTAL_OSC_CTRL.HF := HF;

      delay_loop :
      while delay_ticks > 0 loop
         delay_ticks := delay_ticks - 1;
      end loop delay_loop;

   end Enable_Crystal;

   ----------------------
   -- Setup_Core_Clock --
   ----------------------

   procedure Setup_Core_Clock is

      -------------------------------
      -- Compute Clock Frequencies --
      -------------------------------

      pragma Compile_Time_Error ((if Main_Clock_Frequency in SYSCLK_Range then
                                 False), "System clock out of range");

      pragma Compile_Time_Error ((if CLK_SEL = Crystal_Oscillator or
                                CLK_SEL = Irc_Default then False),
                              "PLL1 clock-source not supported");

      pragma Compile_Time_Error ((if XTAL_Enabled and
                            XTAL_Clock_Frequency in XTALCLK_Range then False),
                            "Crystal oscillator out of range");

      FCLKIN        : constant := (case CLK_SEL is
                               when Crystal_Oscillator => XTAL_Clock_Frequency,
                               when Irc_Default => IRCCLK,
                               when others => IRCCLK);

      pragma Compile_Time_Error ((if FCLKIN in XTALCLK_Range then False),
                            "PLL1 input frequency (FCLKIN) out of range");

      TwoStepRampUp : constant Boolean :=
          (if Main_Clock_Frequency > 110_000_000 then True else False);

      pragma Compile_Time_Error ((if MSEL_Val in PLL1M_Range then False),
                                 "PLL1 MSEL value out of range");

      pragma Compile_Time_Error ((if NSEL_Val in PLL1N_Range then False),
                                 "Invalid PLL1 NSEL value");

      pragma Compile_Time_Error ((if PSEL_Val in PLL1P_Range then False),
                                 "Invalid PLL1 PSEL value");

      FCCO : constant Integer :=
                   (if FBSEL = Pll_Out and DIRECT = Disabled then
                        2 * PSEL_Val * MSEL_Val * FCLKIN / NSEL_Val
                    else
                        MSEL_Val * FCLKIN / NSEL_Val);

      pragma Compile_Time_Error ((if FCCO in PLL1CCO_Range then False),
           "PLL1 current controlled oscillator frequency (FCCO) out of range");

      FCLKOU : constant Integer :=
                   (if FBSEL = Pll_Out or DIRECT = Enabled then
                        MSEL_Val * FCLKIN / NSEL_Val
                    else
                        MSEL_Val * FCLKIN / (2 * PSEL_Val * NSEL_Val));

      pragma Compile_Time_Error ((if FCLKOU in PLL1CLKOU_Range then False),
                            "PLL1 output frequency (FCLKOU) out of range");

      pragma Compile_Time_Error ((if FCLKOU = Main_Clock_Frequency then False),
                                 "PLL1 output frequency (FCLKOU) does not " &
                                  "match desired System Clock frequency");

      PSEL : constant PLL1_CTRL_ENUM_4 := (case PSEL_Val is
                                           when 1 => PLL1_CTRL_ENUM_1_1,
                                           when 2 => Peq2,
                                           when 4 => Peq4,
                                           when 8 => PLL1_CTRL_ENUM_8,
                                           when others => PLL1_CTRL_ENUM_1_1);

      NSEL : constant PLL1_CTRL_ENUM_5 := (case NSEL_Val is
                                           when 1 => PLL1_CTRL_ENUM_1_1,
                                           when 2 => Neq2,
                                           when 3 => Neq3,
                                           when 4 => PLL1_CTRL_ENUM_4_1,
                                           when others => PLL1_CTRL_ENUM_4_1);

      MSEL : constant PLL1_CTRL_MSEL_Field := Byte (MSEL_Val - 1);

      delay_ticks : Integer := 500;

   begin

      --  Switch System Clock source to PLL1 clock source
      CGU_Periph.BASE_M4_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_M4_CLK.CLK_SEL := (case CLK_SEL is
                                when Crystal_Oscillator => Crystal_Oscillator,
                                when Irc_Default => Irc_Default,
                                when others => Irc_Default);

      --  Power down PLL1
      CGU_Periph.PLL1_CTRL.PD := Pll1_Powered_Down;
      CGU_Periph.PLL1_CTRL.BYPASS := BYPASS;
      CGU_Periph.PLL1_CTRL.AUTOBLOCK := Disabled;
      CGU_Periph.PLL1_CTRL.CLK_SEL := CLK_SEL;

      --  If System Clock is greater than 110MHz then a two step frequency
      --  ramp up must be performed
      if TwoStepRampUp then
         pragma Warnings (Off, "condition is always False");
         if DIRECT = Disabled or not (PSEL_Val = 1) then
            pragma Warnings (On, "condition is always False");
            declare

               pragma Warnings (Off, "condition is always True");
               pragma Compile_Time_Error ((if MIDFREQ_MSEL_Val in PLL1M_Range
                       then False), "Mid-frequency MSEL value out of range");

               pragma Compile_Time_Error ((if MIDFREQ_NSEL_Val in PLL1N_Range
                            then False), "Invalid mid-frequency NSEL value");

               pragma Compile_Time_Error ((if MIDFREQ_PSEL_Val in PLL1P_Range
                            then False), "Invalid mid-frequency PSEL value");
               pragma Warnings (On, "condition is always True");

               MIDFREQ_FCCO : constant Integer :=
                          (if MIDFREQ_FBSEL = Pll_Out and
                             MIDFREQ_DIRECT = Disabled then
                             2 * MIDFREQ_PSEL_Val * MIDFREQ_MSEL_Val * FCLKIN
                                                           / MIDFREQ_NSEL_Val
                           else
                              MIDFREQ_MSEL_Val * FCLKIN / MIDFREQ_NSEL_Val);

               pragma Warnings (Off, "condition is always True");
               pragma Compile_Time_Error ((if MIDFREQ_FCCO in PLL1CCO_Range
                      then False), "Mid-frequency PLL1 FCCO out of range");
               pragma Warnings (On, "condition is always True");

               MIDFREQ_FCLKOU : constant Integer :=
                  (if MIDFREQ_FBSEL = Pll_Out or MIDFREQ_DIRECT = Enabled then
                        MIDFREQ_MSEL_Val * FCLKIN / MIDFREQ_NSEL_Val
                    else
                        MIDFREQ_MSEL_Val * FCLKIN /
                                   (2 * MIDFREQ_PSEL_Val * MIDFREQ_NSEL_Val));

               pragma Warnings (Off, "condition is always True");
               pragma Compile_Time_Error ((if MIDFREQ_FCLKOU in MIDFREQ_Range
                      then False), "Mid-frequency PLL1 FCLKOU out of range");
               pragma Warnings (On, "condition is always True");

               MIDFREQ_PSEL : constant PLL1_CTRL_ENUM_4 :=
                                      (case MIDFREQ_PSEL_Val is
                                           when 1 => PLL1_CTRL_ENUM_1_1,
                                           when 2 => Peq2,
                                           when 4 => Peq4,
                                           when 8 => PLL1_CTRL_ENUM_8,
                                           when others => PLL1_CTRL_ENUM_1_1);

               MIDFREQ_NSEL : constant PLL1_CTRL_ENUM_5 :=
                                      (case MIDFREQ_NSEL_Val is
                                           when 1 => PLL1_CTRL_ENUM_1_1,
                                           when 2 => Neq2,
                                           when 3 => Neq3,
                                           when 4 => PLL1_CTRL_ENUM_4_1,
                                           when others => PLL1_CTRL_ENUM_4_1);

               MIDFREQ_MSEL : constant PLL1_CTRL_MSEL_Field := Byte (MSEL_Val
                                                                          - 1);

            begin

               --  Configure mid-frequency parameters and start PLL1
               CGU_Periph.PLL1_CTRL.DIRECT := MIDFREQ_DIRECT;
               CGU_Periph.PLL1_CTRL.FBSEL := MIDFREQ_FBSEL;
               CGU_Periph.PLL1_CTRL.PSEL :=  MIDFREQ_PSEL;
               CGU_Periph.PLL1_CTRL.NSEL :=  MIDFREQ_NSEL;
               CGU_Periph.PLL1_CTRL.MSEL :=  MIDFREQ_MSEL;
               CGU_Periph.PLL1_CTRL.PD := Pll1_Enabled;

               --  Wait for PLL1 to lock to mid-frequency clock
               loop
                  exit when CGU_Periph.PLL1_STAT.LOCK = 1;
               end loop;

               --  Switch System Clock source to PLL1 output
               CGU_Periph.BASE_M4_CLK.AUTOBLOCK := Enabled;
               CGU_Periph.BASE_M4_CLK.CLK_SEL := Pll1;

               --  Wait for approx 50 uSec
               while delay_ticks > 0 loop
                  delay_ticks := delay_ticks - 1;
               end loop;
               delay_ticks := 500;

            end;
         else
            CGU_Periph.PLL1_CTRL.DIRECT := Disabled;
         end if;
      else
         CGU_Periph.PLL1_CTRL.DIRECT := DIRECT;
      end if;

      --  Configure parameters and start PLL1
      CGU_Periph.PLL1_CTRL.FBSEL := FBSEL;
      CGU_Periph.PLL1_CTRL.PSEL := PSEL;
      CGU_Periph.PLL1_CTRL.NSEL := NSEL;
      CGU_Periph.PLL1_CTRL.MSEL := MSEL;
      CGU_Periph.PLL1_CTRL.PD := Pll1_Enabled;

      --  Wait for PLL1 to lock
      loop
         exit when CGU_Periph.PLL1_STAT.LOCK = 1;
      end loop;

      --  Switch System Clock source to PLL1 output
      CGU_Periph.BASE_M4_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_M4_CLK.CLK_SEL := Pll1;

      --  Wait for approx 50 uSec
      while delay_ticks > 0 loop
         delay_ticks := delay_ticks - 1;
      end loop;

      --  If performing a two step frequency ramp up and DIRECT must be
      --  enabled to operate at full frequency then enable it
      pragma Warnings (Off, "condition is always True");
      if TwoStepRampUp and DIRECT = Enabled then
         pragma Warnings (On, "condition is always True");

         CGU_Periph.PLL1_CTRL.DIRECT := Enabled;

         --  Wait for approx 50 uSec
         delay_ticks := 500;
         while delay_ticks > 0 loop
            delay_ticks := delay_ticks - 1;
         end loop;

      end if;

   end Setup_Core_Clock;

   procedure Setup_Clock_Bases is
   begin

      CGU_Periph.BASE_SAFE_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_SAFE_CLK.CLK_SEL := Irc_Default;
      CGU_Periph.BASE_SAFE_CLK.PD := Power_Down;

      CGU_Periph.BASE_APB1_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_APB1_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_APB1_CLK.PD := Power_Down;

      CGU_Periph.BASE_APB3_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_APB3_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_APB3_CLK.PD := Power_Down;

      CGU_Periph.BASE_USB0_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_USB0_CLK.CLK_SEL := Pll0Usb;
      CGU_Periph.BASE_USB0_CLK.PD := Enabled;

      CGU_Periph.BASE_PERIPH_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_PERIPH_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_PERIPH_CLK.PD := Power_Down;

      CGU_Periph.BASE_SPI_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_SPI_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_SPI_CLK.PD := Power_Down;

      CGU_Periph.BASE_SDIO_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_SDIO_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_SDIO_CLK.PD := Power_Down;

      CGU_Periph.BASE_SSP0_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_SSP0_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_SSP0_CLK.PD := Power_Down;

      CGU_Periph.BASE_SSP1_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_SSP1_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_SSP1_CLK.PD := Power_Down;

      CGU_Periph.BASE_UART0_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_UART0_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_UART0_CLK.PD := Power_Down;

      CGU_Periph.BASE_UART1_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_UART1_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_UART1_CLK.PD := Power_Down;

      CGU_Periph.BASE_UART2_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_UART2_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_UART2_CLK.PD := Output_Stage_Enabled;

      CGU_Periph.BASE_UART3_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_UART3_CLK.CLK_SEL := Pll1;
      CGU_Periph.BASE_UART3_CLK.PD := Power_Down;

      CGU_Periph.BASE_OUT_CLK.AUTOBLOCK := Autoblocking_Enabled;
      CGU_Periph.BASE_OUT_CLK.PD := Power_Down;

      CGU_Periph.BASE_AUDIO_CLK.AUTOBLOCK := Autoblocking_Enabled;
      CGU_Periph.BASE_AUDIO_CLK.PD := Power_Down;

      CGU_Periph.BASE_CGU_OUT0_CLK.AUTOBLOCK := Autoblocking_Enabled;
      CGU_Periph.BASE_CGU_OUT0_CLK.PD := Power_Down;

      CGU_Periph.BASE_CGU_OUT1_CLK.AUTOBLOCK := Autoblocking_Enabled;
      CGU_Periph.BASE_CGU_OUT1_CLK.PD := Power_Down;

      CGU_Periph.BASE_PHY_TX_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_PHY_TX_CLK.CLK_SEL := Enet_Tx_Clk;
      CGU_Periph.BASE_PHY_TX_CLK.PD := Power_Down;

      CGU_Periph.BASE_PHY_RX_CLK.AUTOBLOCK := Enabled;
      CGU_Periph.BASE_PHY_RX_CLK.CLK_SEL := Enet_Tx_Clk;
      CGU_Periph.BASE_PHY_RX_CLK.PD := Power_Down;

   end Setup_Clock_Bases;
begin

   Setup_Flash_Acceleration;

   if XTAL_Enabled then
      Enable_Crystal;
   end if;

   Setup_Core_Clock;
   Setup_Clock_Bases;

   --  Reset and Enable 32Khz oscillator
   CREG_Periph.CREG0.RESET32KHZ := Clear_Reset;
   CREG_Periph.CREG0.PD32KHZ := Powered;
   CREG_Periph.CREG0.EN1KHZ := CREG0_ENUM_1_Khz_Output_Enabled;
   CREG_Periph.CREG0.EN32KHZ := CREG0_ENUM_32_Khz_Output_Enable;

end Setup_Pll;
