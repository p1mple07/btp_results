/* 
   File: rtl/apb_dsp_unit.v
   Description: APB interface for a DSP unit with internal registers for operand addresses,
                operational mode, and data write configuration. In addition/multiplication mode,
                the unit reads two operands from an internal 1KB SRAM (addresses specified by
                r_operand_1 and r_operand_2), computes the result, and makes it available at
                address 0x5. In write mode, a write to r_write_data (address 0x4) causes the data 
                to be written to SRAM at the address specified by r_write_address (address 0x3).
                
   APB Interface Signals:
     • pclk         : APB clock (synchronous operations)
     • presetn      : Active-low asynchronous reset
     • paddr        : 10-bit address bus (APB)
     • pselx        : APB select signal
     • penable      : APB enable signal
     • pwrite       : Write enable (high for write, low for read)
     • pwdata       : 8-bit write data bus
     • pready       : Ready signal (always high when transaction complete)
     • prdata       : 8-bit read data bus
     • pslverr      : Error signal (high for invalid address/write)
     
   Internal Registers (addresses in configuration space 0x0 to 0x5):
     0x0: r_operand_1 (10-bit address for first operand in SRAM)
     0x1: r_operand_2 (10-bit address for second operand in SRAM)
     0x2: r_Enable    (Operational mode: 0 = DSP disabled, 1 = Addition, 2 = Multiplication, 3 = Write mode)
     0x3: r_write_address (10-bit address in SRAM for data write in write mode)
     0x4: r_write_data     (8-bit data to be written in write mode)
     0x5: r_result         (Computed result register; read-only via APB)
     
   SRAM Interface:
     • A 1KB (1024 x 8) internal memory array (sram_mem) is used to simulate external SRAM.
     • sram_valid: When asserted (for one clock cycle), the data in r_write_data is latched to SRAM at 
       the address specified by r_write_address (only in write mode, r_Enable = 3).
       
   APB Protocol:
     • Two-cycle handshake: In the first cycle (IDLE) the transaction (address, write/read, data) is latched.
       In the second cycle (ACCESS) the transaction is executed and the outputs (prdata, pslverr) are updated.
     • pready is always driven high.
     • pslverr is asserted if a write is attempted to the computed result (address 0x5) or if an invalid 
       address is accessed.
       
   Functional Behavior:
     • In Addition Mode (r_Enable == 1) or Multiplication Mode (r_Enable == 2), the unit continuously 
       reads two operands from SRAM (at addresses given by r_operand_1 and r_operand_2) and computes 
       the result (8-bit addition or multiplication) which is stored in r_result.
     • In Write Mode (r_Enable == 3), when a write occurs to r_write_data (address 0x4), sram_valid is 
       asserted for one cycle to write the data to SRAM at the address specified by r_write_address.
*/

module apb_d