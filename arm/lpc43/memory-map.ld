/****************************************************************************
 *                                                                          *
 *                         GNAT COMPILER COMPONENTS                         *
 *                                                                          *
 *                                  A R M                                   *
 *                                                                          *
 *                            Linker Script File                            *
 *                                                                          *
 *      Copyright (C) 1999-2002 Universidad Politecnica de Madrid           *
 *             Copyright (C) 2003-2006 The European Space Agency            *
 *                   Copyright (C) 2003-2015 AdaCore                        *
 *                                                                          *
 * GNAT is free software;  you can  redistribute it  and/or modify it under *
 * terms of the  GNU General Public License as published  by the Free Soft- *
 * ware  Foundation;  either version 2,  or (at your option) any later ver- *
 * sion.  GNAT is distributed in the hope that it will be useful, but WITH- *
 * OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY *
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License *
 * for  more details.  You should have  received  a copy of the GNU General *
 * Public License  distributed with GNAT;  see file COPYING.  If not, write *
 * to  the  Free Software Foundation,  51  Franklin  Street,  Fifth  Floor, *
 * Boston, MA 02110-1301, USA.                                              *
 *                                                                          *
 * GNARL was developed by the GNARL team at Florida State University.       *
 * Extensive contributions were provided by Ada Core Technologies, Inc.     *
 * The  executive  was developed  by the  Real-Time  Systems  Group  at the *
 * Technical University of Madrid.                                          *
 *                                                                          *
 ****************************************************************************/

MEMORY
{
  flash_bank_a (rx)		: ORIGIN = 0x1A000000, LENGTH = 512K
  flash_bank_b (rx)		: ORIGIN = 0x1B000000, LENGTH = 512K
  local_sram_32k (rwx) 		: ORIGIN = 0x10000000, LENGTH = 32K
  local_sram_40k (rwx) 		: ORIGIN = 0x10080000, LENGTH = 40K
  ahb_sram_64k (rwx)		: ORIGIN = 0x20000000, LENGTH = 64K
  /*
  ahb_sram_32k (rwx) 		: ORIGIN = 0x20000000, LENGTH = 32K
  ahb_sram_16k (rwx) 		: ORIGIN = 0x20008000, LENGTH = 16K
  ahb_sram_etb_16k (rwx)	: ORIGIN = 0x2000C000, LENGTH = 16K
  */
}

REGION_ALIAS("flash_tx", flash_bank_a)
REGION_ALIAS("flash_ro", flash_bank_a)
REGION_ALIAS("sram_tx", ahb_sram_64k)
REGION_ALIAS("sram_ro", ahb_sram_64k)
REGION_ALIAS("sram_bs", ahb_sram_64k)
REGION_ALIAS("sram_da", ahb_sram_64k)


/****************************************************************************
*                                                                           *
* The LPC4337 microcontroller has a total flash memory of 1Mb split into    *
* two non-contiguous banks A and B of 512KB each. The GNU linker can't      *
* assign a single output section to two diferent memory regions. For the    *
* moment only bank A is used for code (.text) and read-only data (.rodata). *
*                                                                           *
* On the other hand the LPC4337 microcontroller has a total 136KB of sram   *
* momory split between 3 non-contiguous regions of memory. A local 32KB     *
* region, a local 40KB region whose top 8KB are retained during power-down  *
* mode and an ahb accesible 4x16KB region whose bottom 16KB are also used   *
* as the embedded trace buffer (ETB) for storing trace information. So if   *
* the ETB is configured, these bottom 16KB can't be used as normal sram.    *
* When loading the program into RAM (using common-RAM.ld linker script)     *
* code (.text) and read-only (.rodata) output sections need to be assigned  *
* to sram memory regions as well. Since ETB is not being used and the ahb   *
* 4x16KB region is the largest sram region, when running programs from RAM, *
* the ahb_sram_64k is used for loading code and read-only data. In case ETB *
* needs to be used the alternate definition of the ahb memory (commented    *
* out) can be used. When loading program into ROM both the uninitialized    *
* data (.bss) section and the data (.data) section are placed in the        *
* ahb_sram_64k region.                                                      *
*                                                                           *
*****************************************************************************/
