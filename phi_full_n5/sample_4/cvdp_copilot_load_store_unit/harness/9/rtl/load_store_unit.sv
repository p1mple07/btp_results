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
    input  logic                 ex_if_extend_mode_i,
    output logic                 ex_if_ready_o    ,

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

  logic busy_q;  
  logic dmem_req_q ;

  logic [31:0] dmem_req_wdata_q;
  logic [31:0] dmem_req_addr_q;

  logic [31:0] wb_if_rdata_q;
  logic wb_if_rvalid_q;

  logic [1:0] rdata_offset_q ;
  logic [1:0] rdata_w_ext , rdata_h_ext, rdata_b_ext, data_rdata_ext ;
  logic data_type_q ;
  logic data_sign_ext_q ;

  assign data_addr_int = ex_if_addr_base_i + ex_if_addr_offset_i;

  assign ex_req_fire = ex_if_req_i && !busy_q && !misaligned_addr;
  assign ex_if_ready_o = !busy_q;

  always_comb begin
    misaligned_addr = 1'b0;
    dmem_be = 4'b0000;
    case (ex_if_type_i)  
      2'b00: begin  
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b0001;
            2'b01:   dmem_be = 4'b0010;
            2'b10:   dmem_be = 4'b0100;
            2'b11:   dmem_be = 4'b1000;
            default: dmem_be = 4'b0000;
          endcase
      end

      2'b01: begin  
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b0011;
            2'b10:   dmem_be = 4'b1100;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
          endcase
      end

      2'b10: begin  
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

  // Finite State Machine (FSM)
  reg [2:0] fsm_state_q;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      fsm_state_q <= 3'b000; // IDLE
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
      rdata_offset_q <= '0 ;
      busy_q <= 1'b0;
    end else if (ex_req_fire) begin
      case (fsm_state_q)
        3'b000: dmem_req_q <= 1'b1;
        3'b001: dmem_req_addr_q <= data_addr_int;
        3'b001: dmem_req_we_q <= ex_if_we_i;
        3'b010: dmem_req_be_q <= dmem_be ;
        3'b010: dmem_req_wdata_q <= ex_if_wdata_i ; 
        dmem_rvalid_o <= 1'b0;
        fsm_state_q <= 3'b010; // MISALIGNED_WR
      endcase
    end

    case (fsm_state_q)
      3'b010: begin
        if (dmem_gnt_i) begin
          fsm_state_q <= 3'b011; // MISALIGNED_WR_1
          dmem_req_q <= 1'b0;
        end else begin
          fsm_state_q <= 3'b000; // IDLE
        end
      end

      3'b011: begin
        if (dmem_rvalid_i) begin
          fsm_state_q <= 3'b000; // MISALIGNED_RD_1
          wb_if_rdata_q <= data_rdata_ext;
          wb_if_rvalid_q <= 1'b1;
        end else begin
          fsm_state_q <= 3'b000; // IDLE
        end
      end

      3'b000: begin
        // ALIGNED_WR
        // No changes needed for aligned write
      end

      3'b001: begin
        // ALIGNED_RD
        // No changes needed for aligned read
      end

      3'b011: begin
        // MISALIGNED_RD_GNT
        // Wait for first data response
        dmem_rvalid_o <= dmem_rvalid_i;
        fsm_state_q <= 3'b011; // MISALIGNED_RD_GNT_1
      end
    endcase
  end

  always_comb begin
    case (rdata_offset_q)
      2'b00: rdata_w_ext = dmem_rsp_rdata_i[31:0];
      default: rdata_w_ext = '0 ;
    endcase

  always_comb begin
    case (rdata_offset_q)
      2'b00: begin
        if (data_sign_ext_q) rdata_h_ext ={{16{dmem_rsp_rdata_i[15]}}, dmem_rsp_rdata_i[15:0]};
        else rdata_h_ext =  {16'h0000, dmem_rsp_rdata_i[15:0]};
      end

      2'b10: begin
        if (data_sign_ext_q) rdata_h_ext ={{16{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:16]};
        else rdata_h_ext = {16'h0000, dmem_rsp_rdata_i[31:16]};
      end

      default: begin
        rdata_h_ext = '0 ;  
      end
    endcase  
  end

  always_comb begin : dmem_req
    dmem_req_o        = dmem_req_q;
    dmem_req_addr_o   = dmem_req_addr_q;
    dmem_req_we_o     = dmem_req_we_q;
    dmem_req_be_o     = dmem_req_be_q;
    dmem_req_wdata_o  = dmem_req_wdata_q;
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      wb_if_rdata_q   <= 32'b0;
      wb_if_rvalid_q  <= 1'b0;
    end else if (dmem_rvalid_i) begin
      wb_if_rdata_q   <= data_rdata_ext;
      wb_if_rvalid_q  <= 1'b1;
    end else begin
      wb_if_rvalid_q  <= 1'b0;
    end
  end

  assign wb_if_rdata_o =  wb_if_rdata_q;
  assign wb_if_rvalid_o = wb_if_rvalid_q;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      busy_q <= 1'b0;
    end else if (ex_req_fire) begin
      case (fsm_state_q)
        3'b011: busy_q <= 1'b1;
        3'b000: busy_q <= 1'b0;
      endcase
    end
  end

endmodule
