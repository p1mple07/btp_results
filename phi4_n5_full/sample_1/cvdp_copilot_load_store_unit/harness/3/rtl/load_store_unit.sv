module load_store_unit (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 ex_if_req_i,           // LSU request
    input  logic                 ex_if_we_i,            // Write enable: 0 (load), 1 (store)
    input  logic     [ 1:0]      ex_if_type_i,          // Data type: 0x2 (word), 0x1 (halfword), 0x0 (byte)
    input  logic     [31:0]      ex_if_wdata_i,         // Data to write to memory
    input  logic     [31:0]      ex_if_addr_base_i,     // Base address
    input  logic     [31:0]      ex_if_addr_offset_i,   // Offset address
    input  logic                 ex_if_extend_mode_i,   // Extension mode: 0=zero-extend, 1=sign-extend
    output logic                 ex_if_ready_o,
    
    // Writeback stage interface
    output logic     [31:0]      wb_if_rdata_o,         // Requested data
    output logic                 wb_if_rvalid_o,        // Requested data valid

    // Data memory (DMEM) interface
    output logic                 dmem_req_o,
    input  logic                 dmem_gnt_i,
    output logic     [31:0]      dmem_req_addr_o,
    output logic                 dmem_req_we_o,
    output logic     [ 3:0]      dmem_req_be_o,
    output logic     [31:0]      dmem_req_wdata_o,
    input  logic     [31:0]      dmem_rsp_rdata_i,
    input  logic                 dmem_rvalid_i
    );

  // Internal signals
  logic ex_req_fire;
  logic dmem_req_we_q;
  logic [31:0] data_addr_int;
  logic misaligned_addr;
  logic [3:0] dmem_be, dmem_req_be_q;

  logic busy_q;  // Sticky busy bit: Set with EX req and cleared with DMEM response
  logic dmem_req_q ;

  logic [31:0] dmem_req_wdata_q;
  logic [31:0] dmem_req_addr_q;

  logic [31:0] wb_if_rdata_q;
  logic wb_if_rvalid_q;

  // Address calculation
  assign data_addr_int = ex_if_addr_base_i + ex_if_addr_offset_i;

  // EX request fire condition
  assign ex_req_fire = ex_if_req_i && !busy_q && !misaligned_addr;
  assign ex_if_ready_o = !busy_q;

  ///////////////////////////////// Byte Enable Generation ////////////////////////////////
  always_comb begin
    misaligned_addr = 1'b0;
    dmem_be = 4'b0000;
    case (ex_if_type_i)  // 0x2 (word), 0x1 (halfword), 0x0 (byte)
      2'b00: begin  // Writing a byte
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b0001;
            2'b01:   dmem_be = 4'b0010;
            2'b10:   dmem_be = 4'b0100;
            2'b11:   dmem_be = 4'b1000;
            default: dmem_be = 4'b0000;
          endcase
      end

      2'b01: begin  // Writing a half-word
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b0011;
            2'b10:   dmem_be = 4'b1100;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
          endcase
      end

      2'b10: begin  // Writing a word
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b1111;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
          endcase
      end
      default: begin
          dmem_be = 4'b0000;
          misaligned_addr = 1'b1;
      end 
    endcase
  end

  
  ///////////////////////////////// dmem_req ////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      dmem_req_q         <= 1'b0;
      dmem_req_addr_q    <= '0;
      dmem_req_we_q      <= '0 ;
      dmem_req_be_q      <= '0 ;
      dmem_req_wdata_q   <= '0 ;
    end else if (ex_req_fire) begin
      dmem_req_q         <= 1'b1;
      dmem_req_addr_q    <= data_addr_int;
      dmem_req_we_q      <= ex_if_we_i;
      dmem_req_be_q      <= dmem_be ;
      dmem_req_wdata_q   <= ex_if_wdata_i ;
    end else if (dmem_req_q && dmem_gnt_i) begin
      dmem_req_q         <= 1'b0;  // request granted
      dmem_req_addr_q    <= '0 ;
      dmem_req_we_q      <= '0 ;
      dmem_req_be_q      <= '0 ;
      dmem_req_wdata_q   <= '0 ;
    end
  end
  

  ///////////////////////////////// DMEM Request Interface ////////////////////////////////
  always_comb begin : dmem_req
    dmem_req_o        = dmem_req_q;
    dmem_req_addr_o   = dmem_req_addr_q;
    dmem_req_we_o     = dmem_req_we_q;
    dmem_req_be_o     = dmem_req_be_q;
    dmem_req_wdata_o  = dmem_req_wdata_q;
  end

  ///////////////////////////////// Read Response Handling ////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      wb_if_rdata_q   <= 32'b0;
      wb_if_rvalid_q  <= 1'b0;
    end else if (dmem_rvalid_i) begin
      // Apply extension only for load operations
      if (!ex_if_we_i) begin
        // For load operations, shift the valid data to the LSBs based on the address alignment
        // and then apply the specified extension mode.
        logic [31:0] shifted_data;
        logic [4:0]  shift_amount;
        if (ex_if_type_i == 2'b00) begin
          // Byte load: valid data is 8 bits. 
          // Shift right by (data_addr_int[1:0] * 8) to align to LSB.
          shift_amount = data_addr_int[1:0] * 8;
          shifted_data = dmem_rsp_rdata_i >> shift_amount;
          if (ex_if_extend_mode_i == 1'b0) begin
            // Zero-extend: pad upper bits with 0.
            wb_if_rdata_q <= {24'b0, shifted_data[7:0]};
          end else begin
            // Sign-extend: replicate the MSB of the shifted data.
            wb_if_rdata_q <= {{24{shifted_data[7]}}, shifted_data[7:0]};
          end
        end else if (ex_if_type_i == 2'b01) begin
          // Halfword load: valid data is 16 bits.
          // If the address is misaligned, shift right by 16 bits.
          shift_amount = (data_addr_int[0] ? 16 : 0);
          shifted_data = dmem_rsp_rdata_i >> shift_amount;
          if (ex_if_extend_mode_i == 1'b0) begin
            wb_if_rdata_q <= {16'b0, shifted_data[15:0]};
          end else begin
            wb_if_rdata_q <= {{16{shifted_data[15]}}, shifted_data[15:0]};
          end
        end else if (ex_if_type_i == 2'b10) begin
          // Word load: no shifting or extension.
          wb_if_rdata_q <= dmem_rsp_rdata_i;
        end else begin
          wb_if_rdata_q <= dmem_rsp_rdata_i;
        end
      end else begin
        // For store operations, simply pass the DMEM response.
        wb_if_rdata_q <= dmem_rsp_rdata_i;
      end
      wb_if_rvalid_q <= 1'b1;
    end else begin
      wb_if_rvalid_q <= 1'b0;
    end
  end

  assign wb_if_rdata_o =  wb_if_rdata_q;
  assign wb_if_rvalid_o = wb_if_rvalid_q;

  ///////////////////////////////// Busy Logic ////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      busy_q <= 1'b0;
    end else if (ex_req_fire) begin
      busy_q <= 1'b1;
    end else if (dmem_req_we_q && dmem_gnt_i) begin
      busy_q <= 1'b0;  // Write request granted
    end else if (!dmem_req_we_q && dmem_rvalid_i) begin
      busy_q <= 1'b0;  // Read request response received
    end
  end
  
endmodule