module implements configuration registers and supports two modes:
//   - Arithmetic mode (Addition or Multiplication): Operands are read from an internal 1KB SRAM
//     using addresses specified by r_operand_1 and r_operand_2. The computed result is stored
//     in the computed_result register (accessible via APB at address 0x5).
//   - Data Writing mode: When r_Enable==3, the data in r_write_data is written to the SRAM
//     at the address specified by r_write_address.
// APB addresses 0x00 to 0x05 are reserved for configuration registers.
// Other addresses (0x06 to 0xFF) are mapped to the internal SRAM.
//
// APB Signals:
//   pclk         : APB clock (synchronous operations)
//   presetn      : Active-low asynchronous reset
//   paddr        : 10-bit address bus (APB)
//   pselx        : APB select signal (indicates CSR/memory selection)
//   penable      : APB enable signal (transaction progression)
//   pwrite       : Write enable (high for write, low for read)
//   pwdata       : 8-bit write data bus
//   pready       : Ready signal (always high after two cycles)
//   prdata       : 8-bit read data bus
//   pslverr      : Error signal (invalid address or unsupported operation)
//
// SRAM Interface:
//   sram_valid   : When high, the data in r_write_data is latched to the SRAM at address r_write_address.
//
// Note: This design implements a simple two-cycle state machine for APB transactions.
//       All APB read/write operations complete in two clock cycles with PREADY always driven high.
//       Arithmetic operations (addition/multiplication) are performed on data read from the internal SRAM.
//       The internal SRAM is modeled as a 1024-word (1KB) array of 8-bit words.
//
// Register Map (APB addresses):
//   0x00: r_operand_1   - Address for first operand (8-bit, used as SRAM address with upper bits = 0)
//   0x01: r_operand_2   - Address for second operand
//   0x02: r_Enable      - Operational mode:
//                           0: DSP disabled
//                           1: Addition mode
//                           2: Multiplication mode
//                           3: Data Writing mode
//   0x03: r_write_address - Address in SRAM where data will be written (only lower 8 bits used)
//   0x04: r_write_data    - Data to be written into SRAM
//   0x05: computed_result - Result of arithmetic operation (addition or multiplication)
//
// For addresses >= 6, the APB interface directly accesses the internal SRAM.
//------------------------------------------------------------

module apb_dsp_unit (
    input  wire         pclk,
    input  wire         presetn,
    input  wire [9:0]   paddr,
    input  wire         pselx,
    input  wire         penable,
    input  wire         pwrite,
    input  wire [7:0]   pwdata,
    output reg          pready,
    output reg [7:0]    prdata,
    output reg          pslverr,
    output reg          sram_valid
);

  //-------------------------------------------------------------------------
  // Internal State Machine for APB Transactions
  //-------------------------------------------------------------------------
  localparam IDLE  = 2'd0,
             ACCESS = 2'd1;
  reg [1:0] state;

  // Latch registers for APB transaction
  reg [9:0] addr_latch;
  reg [7:0] data_latch;
  reg [7:0] data_out;  // For read data

  //-------------------------------------------------------------------------
  // Configuration Registers
  //-------------------------------------------------------------------------
  reg [7:0] r_operand_1;      // APB address 0x00
  reg [7:0] r_operand_2;      // APB address 0x01
  reg [7:0] r_Enable;         // APB address 0x02
  reg [7:0] r_write_address;  // APB address 0x03
  reg [7:0] r_write_data;     // APB address 0x04
  reg [7:0] computed_result;  // APB address 0x05

  //-------------------------------------------------------------------------
  // Internal SRAM (1KB)
  //-------------------------------------------------------------------------
  reg [7:0] sram_mem [0:1023];

  //-------------------------------------------------------------------------
  // Main Sequential Process: APB Transaction and Functionality
  //-------------------------------------------------------------------------
  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      // Reset all registers and signals to default values
      r_operand_1      <= 8'd0;
      r_operand_2      <= 8'd0;
      r_Enable         <= 8'd0;
      r_write_address  <= 8'd0;
      r_write_data     <= 8'd0;
      computed_result  <= 8'd0;
      pslverr          <= 1'b0;
      pready           <= 1'b1;
      sram_valid       <= 1'b0;
      state            <= IDLE;
    end
    else begin
      // Default assignments
      pready  <= 1'b1;
      pslverr <= 1'b0;
      sram_valid <= 1'b0;

      //-----------------------------
      // APB Transaction State Machine
      //-----------------------------
      case (state)
        IDLE: begin
          if (pselx && penable) begin
            // Latch the current APB address and data
            addr_latch <= paddr;
            data_latch <= pwdata;
            state      <= ACCESS;
          end
        end

        ACCESS: begin
          // Check if the accessed address is a configuration register (0x00-0x05)
          if (addr_latch < 6) begin
            // Configuration register access
            if (pwrite) begin
              case (addr_latch)
                10'd0: r_operand_1      <= data_latch;
                10'd1: r_operand_2      <= data_latch;
                10'd2: r_Enable         <= data_latch;
                10'd3: r_write_address  <= data_latch;
                10'd4: r_write_data     <= data_latch;
                10'd5: computed_result  <= data_latch; // Allow override if needed
                default: pslverr         <= 1'b1;
              endcase
            end
            else begin
              case (addr_latch)
                10'd0: data_out <= r_operand_1;
                10'd1: data_out <= r_operand_2;
                10'd2: data_out <= r_Enable;
                10'd3: data_out <= r_write_address;
                10'd4: data_out <= r_write_data;
                10'd5: data_out <= computed_result;
                default: pslverr <= 1'b1;
              endcase
            end
          end
          else begin
            // Memory access: addresses 0x06 to 0xFF (i.e. 6 to 1023)
            if (pwrite) begin
              sram_mem[addr_latch] <= data_latch;
            end
            else begin
              data_out <= sram_mem[addr_latch];
            end
          end
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase

      //-------------------------------------------------------------------------
      // Indirect SRAM Write: Triggered when DSP is in Data Writing mode
      //-------------------------------------------------------------------------
      if (r_Enable == 8'd3) begin
        sram_valid <= 1'b1;
        // Use the lower 8 bits of r_write_address as the SRAM address.
        sram_mem[{2'b0, r_write_address}] <= r_write_data;
      end
      else begin
        sram_valid <= 1'b0;
      end

      //-------------------------------------------------------------------------
      // Arithmetic Operations: Addition or Multiplication
      //-------------------------------------------------------------------------
      if (r_Enable == 8'd1 || r_Enable == 8'd2) begin
        // Read operands from SRAM using addresses specified in r_operand_1 and r_operand_2.
        // Note: r_operand_1 and r_operand_2 are 8-bit values; the upper 2 bits are assumed 0.
        if (r_Enable == 8'd1) begin
          computed_result <= sram_mem[{2'b0, r_operand_1}] + sram_mem[{2'b0, r_operand_2}];
        end
        else begin
          computed_result <= sram_mem[{2'b0, r_operand_1}] * sram_mem[{2'b0, r_operand_2}];
        end
      end
    end
  end

  //-------------------------------------------------------------------------
  // Drive the prdata output based on the current state.
  // In the ACCESS state, prdata is driven by the latched read data.
  //-------------------------------------------------------------------------
  always @(*) begin
    prdata = (state == ACCESS) ? data_out : 8'd0;
  end

endmodule