module load_store_unit (
    input  logic                 clk,
    input  logic                 rst_n,

    // EX stage interface
    input  logic                 ex_if_req_i,           // LSU request
    input  logic                 ex_if_we_i,            // Write enable: 0 (load), 1 (store)
    input  logic     [ 1:0]      ex_if_type_i,          // Data type: 0x2 (word), 0x1 (halfword), 0x0 (byte)
    input  logic     [31:0]      ex_if_wdata_i,         // Data to write to memory
    input  logic     [31:0]      ex_if_addr_base_i,     // Base address
    input  logic     [31:0]      ex_if_addr_offset_i,   // Offset address
    output logic                 ex_if_ready_o,
    
    // Writeback stage interface
    output logic     [31:0]      wb_if_rdata_o,         // Requested data
    input  logic                 dmem_gnt_i,
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

  logic [31:0] dmem_req_wdata_q;
  logic [31:0] dmem_req_addr_q;

  logic [31:0] wb_if_rdata_q;
  logic wb_if_rvalid_q;

  logic ex_if_extend_mode_i;  // Added new input for extension mode

  logic [31:0] extended_data; // Added temporary register for extension

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

      2'b01: begin  // Writing a halfword
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
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
    end else if (ex_req_fire) begin
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= ex_if_we_i;
      dmem_req_be_q <= dmem_be ;
      dmem_req_wdata_q <= ex_if_wdata_i ;
    end else if (dmem_req_q && dmem_gnt_i) begin
      dmem_req_q <= 1'b0;  // request granted
      dmem_req_addr_q <= '0 ;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
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
      wb_if_rdata_q   <= dmem_rsp_rdata_i;
      wb_if_rvalid_q  <= 1'b1;
    end else begin
      wb_if_rvalid_q  <= 1'b0;
    end
  end

  assign wb_if_rdata_o =  wb_if_rdata_q;
  assign wb_if_rvalid_o = wb_if_rvalid_q;

 ////////////////// New Extension Logic Added ///////////////////
  always_ff @(posedge clk, negedge rst_n) begin : extend_logic
    if (ex_if_type_i == 0x1 || ex_if_type_i == 0x0) && ex_if_extend_mode_i == 1 begin
      // Sign extend halfword or byte
      case (ex_if_type_i)
        0x1: begin  // Halfword
          extended_data = (ex_if_wdata_i >> 17) ? (ex_if_wdata_i | 0x7fffff) : ex_if_wdata_i;
          dmem_req_wdata_q = extended_data;
        end
        0x0: begin  // Byte
          extended_data = (ex_if_wdata_i >> 7) ? (ex_if_wdata_i | 0xff) : ex_if_wdata_i;
          dmem_req_wdata_q = extended_data;
        end
      end
    end
  end
  // End of New Extension Logic

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