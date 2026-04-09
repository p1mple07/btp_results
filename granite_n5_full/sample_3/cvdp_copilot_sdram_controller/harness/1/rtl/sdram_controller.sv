module sdram_controller (clk,reset,addr,data_in,data_out,read,write,sdram_clk,sdram_cke,sdram_cs,sdram_ras,sdram_cas,sdram_we,sdram_addr,sdram_ba,sdram_dq,dq_out);

parameter CL = 10; // Initialization Sequence Length
parameter REFRESH_INTERVAL = 512; // Refresh Interval in Clk Cycles

logic [23:0] address_reg; // Register to store address
logic [15:0] data_out_reg; // Register to store output data
logic [15:0] data_in_reg; // Register to store input data
logic [1:0] state_reg; // Register to store current state
logic [1:0] state_next; // Next state after processing current command

always_ff @(posedge clk) begin
  case (state_reg)
    1'b0: begin
      address_reg <= addr;
      state_reg <= 2'b01; // Move to IDLE state after initialization
    end
    1'b1: begin
      if (address_reg == {24{1'b0}}) begin
        state_reg <= 2'b10; // Move to READY state after initialization
      end else begin
        state_reg <= 2'b01; // Move to IDLE state after initialization
      end
    end
    1'b10: begin
      data_out_reg <= data_out_reg;
      data_in_reg <= data_in_reg;
      state_reg <= state_next;
    end
    default: state_reg <= 2'b00; // Default state
  endcase
end

always_comb begin
  unique case (state_reg)
    2'b00: begin // Idle state
      state_next = 2'b01; // Move to READY state after initialization
    end
    2'b01: begin // Initialization state
      if ((address_reg >= {24{1'b0}}) && (address_reg < {24{1'b1}})) begin
        state_next = 2'b11; // Move to READY state after initialization
      end else begin
        state_next = 2'b00; // Stay in idle state
      end
    end
    2'b10: begin // Ready state
      if (read == 1'b1) begin
        state_next = 2'b10; // Stay in ready state
      end else if (write == 1'b1) begin
        state_next = 2'b11; // Move to READY state after initialization
      end else begin
        state_next = 2'b01; // Move to IDLE state after initialization
      end
    end
    2'b11: begin // READY state
      if (read == 1'b1) begin
        state_next = 2'b10; // Stay in ready state
      end else if (write == 1'b1) begin
        state_next = 2'b11; // Move to READY state after initialization
      end else begin
        state_next = 2'b01; // Move to IDLE state after initialization
      end
    end
    default: state_next = 2'b00; // Default state
  endcase
end

assign dq_out = data_out_reg; // Output data from the SDRAM
assign sdram_clk = clk; // Connect clock signal to the SDRAM
assign sdram_cke = 1'b1; // Set the CKE signal to 1 to activate the SDRAM row
assign sdram_cs = ~reset & ~sdram_ras & ~sdram_cas & ~sdram_we; // Set the CS signal to the complement of the reset and the activation signals
assign sdram_ras = 1'b0; // Set the RAS signal to 0
assign sdram_cas = 1'b0; // Set the CAS signal to 0
assign sdram_we = 1'b0; // Set the WE signal to 0
assign sdram_addr = address_reg; // Assign the address to the SDRAM
assign sdram_ba = 2'b00; // Set the BA signal to 00

endmodule