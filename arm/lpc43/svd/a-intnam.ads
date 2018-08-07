--
--  Copyright (C) 2017, AdaCore
--

--  This spec has been automatically generated from LPC43xx_43Sxx.svd

--  This is a version for the Register cmsis file for LPC43xx parts MCU
package Ada.Interrupts.Names is

   --  All identifiers in this unit are implementation defined

   pragma Implementation_Defined;

   ----------------
   -- Interrupts --
   ----------------

   --  System tick
   Sys_Tick_Interrupt     : constant Interrupt_ID := -1;
   DAC_Interrupt          : constant Interrupt_ID := 0;
   M0APP_Interrupt        : constant Interrupt_ID := 1;
   DMA_Interrupt          : constant Interrupt_ID := 2;
   Reserved_Interrupt_1   : constant Interrupt_ID := 3;
   FLASH_Interrupt        : constant Interrupt_ID := 4;
   ETHERNET_Interrupt     : constant Interrupt_ID := 5;
   SDIO_Interrupt         : constant Interrupt_ID := 6;
   LCD_Interrupt          : constant Interrupt_ID := 7;
   USB0_Interrupt         : constant Interrupt_ID := 8;
   USB1_Interrupt         : constant Interrupt_ID := 9;
   SCT_Interrupt          : constant Interrupt_ID := 10;
   RITIMER_Interrupt      : constant Interrupt_ID := 11;
   TIMER0_Interrupt       : constant Interrupt_ID := 12;
   TIMER1_Interrupt       : constant Interrupt_ID := 13;
   TIMER2_Interrupt       : constant Interrupt_ID := 14;
   TIMER3_Interrupt       : constant Interrupt_ID := 15;
   MCPWM_Interrupt        : constant Interrupt_ID := 16;
   ADC0_Interrupt         : constant Interrupt_ID := 17;
   I2C0_Interrupt         : constant Interrupt_ID := 18;
   I2C1_Interrupt         : constant Interrupt_ID := 19;
   SPI_INT_Interrupt      : constant Interrupt_ID := 20;
   ADC1_Interrupt         : constant Interrupt_ID := 21;
   SSP0_Interrupt         : constant Interrupt_ID := 22;
   SSP1_Interrupt         : constant Interrupt_ID := 23;
   USART0_Interrupt       : constant Interrupt_ID := 24;
   UART1_Interrupt        : constant Interrupt_ID := 25;
   USART2_Interrupt       : constant Interrupt_ID := 26;
   USART3_Interrupt       : constant Interrupt_ID := 27;
   I2S0_Interrupt         : constant Interrupt_ID := 28;
   I2S1_Interrupt         : constant Interrupt_ID := 29;
   SPIFI_Interrupt        : constant Interrupt_ID := 30;
   SGPIO_IINT_Interrupt   : constant Interrupt_ID := 31;
   PIN_INT0_Interrupt     : constant Interrupt_ID := 32;
   PIN_INT1_Interrupt     : constant Interrupt_ID := 33;
   PIN_INT2_Interrupt     : constant Interrupt_ID := 34;
   PIN_INT3_Interrupt     : constant Interrupt_ID := 35;
   PIN_INT4_Interrupt     : constant Interrupt_ID := 36;
   PIN_INT5_Interrupt     : constant Interrupt_ID := 37;
   PIN_INT6_Interrupt     : constant Interrupt_ID := 38;
   PIN_INT7_Interrupt     : constant Interrupt_ID := 39;
   GINT0_Interrupt        : constant Interrupt_ID := 40;
   GINT1_Interrupt        : constant Interrupt_ID := 41;
   EVENTROUTER_Interrupt  : constant Interrupt_ID := 42;
   C_CAN1_Interrupt       : constant Interrupt_ID := 43;
   Reserved_Interrupt_2   : constant Interrupt_ID := 44;
   ADCHS_Interrupt        : constant Interrupt_ID := 45;
   ATIMER_Interrupt       : constant Interrupt_ID := 46;
   RTC_Interrupt          : constant Interrupt_ID := 47;
   Reserved_Interrupt_3   : constant Interrupt_ID := 48;
   WWDT_Interrupt         : constant Interrupt_ID := 49;
   M0SUB_Interrupt        : constant Interrupt_ID := 50;
   C_CAN0_Interrupt       : constant Interrupt_ID := 51;
   QEI_Interrupt          : constant Interrupt_ID := 52;

end Ada.Interrupts.Names;
