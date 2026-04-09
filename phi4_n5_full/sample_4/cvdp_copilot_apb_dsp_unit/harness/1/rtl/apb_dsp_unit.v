module apb_dsp_unit (
  input  wire         pclk,      // APB clock
  input  wire         presetn,   // Active-low asynchronous reset
  input  wire [9:0]   paddr,     // 10-bit address bus
  input  wire         pselx,     // APB select signal
  input  wire         penable,   // APB enable signal
  input  wire         pwrite,    // Write enable: 1 = write, 0 = read
  input  wire [7:0]   pwdata,    // 8-bit write data bus
  input  wire         sram_valid,// Trigger for SRAM write operation
  output reg          pready,    // APB ready signal (always high)
  output reg [7:0]    prdata,    // 8-bit read data bus
  output reg          pslverr    // Error signal for invalid address/access
);

  //-------------------------------------------------------------------------
  // Internal Configuration Registers
  //-------------------------------------------------------------------------
  // r_operand_1: Holds the memory address of the first operand (10 bits)
  reg [9:0] r_operand_1;
  // r_operand_2: Holds the memory address of the second operand (10 bits)
  reg [9:0] r_operand_2;
  // r_Enable: Mode register (2 bits)
  //   0: DSP disabled
  //   1: Addition mode
  //   2: Multiplication mode
  //   3: Data Writing mode
  reg [1:0] r_Enable;
  // r_write_address: Memory address for data write (10 bits)
  reg [9:0] r_write_address;
  // r_write_data: Data to be written (8 bits)
  reg [7:0] r_write_data;
  // result_reg: Holds the computed result (8 bits), accessible at address 0x5
  reg [7:0] result_reg;

  //-------------------------------------------------------------------------
  // Internal Memory Array (1KB SRAM)
  //-------------------------------------------------------------------------
  // A simple 8-bit wide memory array of 1024 words
  reg [7:0] mem [0:1023];

  //-------------------------------------------------------------------------
  // APB Transaction Handling
  //-------------------------------------------------------------------------
  // This always block handles APB read and write transactions.
  // Only addresses 0x0 to 0x5 (decimal 0 to 5) are valid.
  // paddr is interpreted as:
  //   0x0: r_operand_1
  //   0x1: r_operand_2
  //   0x2: r_Enable
  //   0x3: r_write_address
  //   0x4: r_write_data
  //   0x5: result_reg (read-only)
  // Any access with paddr >= 6 sets pslverr high.
  //-------------------------------------------------------------------------
  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      // Asynchronous reset: initialize all configuration registers and outputs
      r_operand_1         <= 10'd0;
      r_operand_2         <= 10'd0;
      r_Enable            <= 2'd0;
      r_write_address     <= 10'd0;
      r_write_data        <= 8'd0;
      result_reg          <= 8'd0;
      prdata              <= 8'd0;
      pslverr             <= 1'b0;
      pready              <= 1'b0;
    end else begin
      // Default assignments: ready signal always high and no error
      pready  <= 1'b1;
      pslverr <= 1'b0;
      // Only process APB transactions when pselx and penable are asserted.
      if (pselx && penable) begin
        if (pwrite) begin
          // Write operation: update configuration register based on paddr
          case (paddr)
            4'd0: r_operand_1         <= {2'b0, pwdata};  // Extend 8-bit to 10-bit
            4'd1: r_operand_2         <= {2'b0, pwdata};
            4'd2: r_Enable            <= pwdata[1:0];      // Only lower 2 bits used
            4'd3: r_write_address     <= {2'b0, pwdata};
            4'd4: r_write_data        <= pwdata;
            4'd5: ;                   // result_reg is read-only; ignore write
            default: pslverr          <= 1'b1;            // Invalid address
          endcase
        end else begin
          // Read operation: drive prdata based on paddr
          case (paddr)
            4'd0: prdata <= r_operand_1[7:0];
            4'd1: prdata <= r_operand_2[7:0];
            4'd2: prdata <= r_Enable;
            4'd3: prdata <= r_write_address[7:0];
            4'd4: prdata <= r_write_data;
            4'd5: prdata <= result_reg;
            default: pslverr <= 1'b1;                // Invalid address
          endcase
        end
      end
    end
  end

  //-------------------------------------------------------------------------
  // Arithmetic Operation Handling
  //-------------------------------------------------------------------------
  // When r_Enable is set to:
  //   1: Addition mode --> Compute: mem[r_operand_1] + mem[r_operand_2]
  //   2: Multiplication mode --> Compute: mem[r_operand_1] * mem[r_operand_2]
  // The computed result is stored in result_reg (address 0x5).
  //-------------------------------------------------------------------------
  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      result_reg <= 8'd0;
    end else begin
      if (r_Enable == 2'd1 || r_Enable == 2'd2) begin
        if (r_Enable == 2'd1) begin
          // Addition mode
          result_reg <= mem[r_operand_1] + mem[r_operand_2];
        end else begin
          // Multiplication mode
          result_reg <= mem[r_operand_1] * mem[r_operand_2];
        end
      end
      // In other modes (DSP disabled or Data Writing mode), result_reg remains unchanged.
    end
  end

  //-------------------------------------------------------------------------
  // SRAM Write Operation
  //-------------------------------------------------------------------------
  // When r_Enable is 3 (Data Writing mode) and sram_valid is asserted,
  // the value in r_write_data is written to the memory location specified by
  // r_write_address.
  //-------------------------------------------------------------------------
  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      // Optionally, initialize the memory array to 0 on reset.
      integer i;
      for (i = 0; i < 1024; i = i + 1) begin
        mem[i] <= 8'd0;
      end
    end else begin
      if (r_Enable == 2'd3 && sram_valid) begin
        mem[r_write_address] <= r_write_data;
      end
    end
  end

endmodule