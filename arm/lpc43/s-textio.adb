------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                       S Y S T E M . T E X T _ I O                        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1992-2016, Free Software Foundation, Inc.         --
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

--  Minimal version of Text_IO body for use on STM32F4xxx, using USART1

with Interfaces; use Interfaces;

with Interfaces.LPC43.SCU;   use Interfaces.LPC43.SCU;
with Interfaces.LPC43.CCU1;  use Interfaces.LPC43.CCU1;
with Interfaces.LPC43.CCU2;  use Interfaces.LPC43.CCU2;
with Interfaces.LPC43.USART; use Interfaces.LPC43.USART;

--  with System.BB.Parameters;

package body System.Text_IO is

   --  Baudrate : constant := 115_200;
   --  Bitrate to use

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      Initialized := True;

      SCU_Periph.SFSP7 (1).EPD := Disable_Pull_Down;
      SCU_Periph.SFSP7 (1).EPUN := Disable_Pull_Up;
      SCU_Periph.SFSP7 (1).MODE := Function_6;

      SCU_Periph.SFSP7 (2).EPD := Disable_Pull_Down;
      SCU_Periph.SFSP7 (2).EPUN := Disable_Pull_Up;
      SCU_Periph.SFSP7 (2).EZI := Enable_Input_Buffer;
      SCU_Periph.SFSP7 (2).ZIF := Disable_Input_Glitch;
      SCU_Periph.SFSP7 (2).MODE := Function_6;

      CCU1_Periph.CLK_M4_USART2_CFG.RUN := Enabled;
      CCU1_Periph.CLK_M4_USART2_CFG.AUTO := Enabled;
      CCU1_Periph.CLK_M4_USART2_CFG.WAKEUP := Enabled;

      CCU2_Periph.CLK_APB2_USART2_CFG.RUN := Enabled;
      CCU2_Periph.CLK_APB2_USART2_CFG.AUTO := Enabled;
      CCU2_Periph.CLK_APB2_USART2_CFG.WAKEUP := Enabled;

      USART2_Periph.FCR.FIFOEN := Enabled;
      USART2_Periph.FCR.TXFIFORES := Clear;
      USART2_Periph.FCR.RXFIFORES := Clear;

      USART2_Periph.TER.TXEN := 0;

      USART2_Periph.IER.RBRIE := Disable;
      USART2_Periph.IER.THREIE := Disable;
      USART2_Periph.IER.RXIE := Disable;
      USART2_Periph.IER.ABEOINTEN := Disable;
      USART2_Periph.IER.ABTOINTEN := Disable;

      USART2_Periph.LCR.WLS := LCR_ENUM_8_Bit_Character_Leng;
      USART2_Periph.LCR.SBS := LCR_ENUM_1_Stop_Bit;
      USART2_Periph.LCR.PE := Disable_Parity_Gener;
      USART2_Periph.LCR.PS := Odd_Parity;
      USART2_Periph.LCR.BC := Disabled;
      USART2_Periph.LCR.DLAB := Disabled;

      USART2_Periph.ACR.START := Stop;
      USART2_Periph.ACR.MODE := Mode_0;
      USART2_Periph.ACR.AUTORESTART := No_Restart;
      USART2_Periph.ACR.ABEOINTCLR := No_Effect;
      USART2_Periph.ACR.ABTOINTCLR := No_Effect;

      USART2_Periph.RS485CTRL.NMMEN := Disabled;
      USART2_Periph.RS485CTRL.RXDIS := Enabled;
      USART2_Periph.RS485CTRL.AADEN := Disabled;
      USART2_Periph.RS485CTRL.DCTRL := Disabled;
      USART2_Periph.RS485CTRL.OINV := Low;

      USART2_Periph.RS485DLY.DLY := 0;

      USART2_Periph.RS485ADRMATCH.ADRMATCH := 0;

      USART2_Periph.LCR.DLAB := Enabled;
      USART2_Periph.DLL.DLLSB := 83;
      USART2_Periph.DLM.DLMSB := 0;
      USART2_Periph.LCR.DLAB := Disabled;

      USART2_Periph.FDR.MULVAL := 15;
      USART2_Periph.FDR.DIVADDVAL := 5;

      USART2_Periph.TER.TXEN := 1;

   end Initialize;

   -----------------
   -- Is_Tx_Ready --
   -----------------

   function Is_Tx_Ready return Boolean is
     (USART2_Periph.LSR.THRE = Empty);

   -----------------
   -- Is_Rx_Ready --
   -----------------

   function Is_Rx_Ready return Boolean is
     (USART2_Periph.LSR.RDR = Data);

   ---------
   -- Get --
   ---------

   function Get return Character is (Character'Val (USART2_Periph.RBR.RBR));

   ---------
   -- Put --
   ---------

   procedure Put (C : Character) is
   begin
      USART2_Periph.THR.THR := Character'Pos (C);
   end Put;

   ----------------------------
   -- Use_Cr_Lf_For_New_Line --
   ----------------------------

   function Use_Cr_Lf_For_New_Line return Boolean is (True);
end System.Text_IO;
