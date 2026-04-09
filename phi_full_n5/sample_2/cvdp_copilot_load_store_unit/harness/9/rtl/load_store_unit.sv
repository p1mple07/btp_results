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
  logic [31:0] rdata_w_ext , rdata_h_ext, rdata_b_ext, data_rdata_ext ;
  logic [1:0] data_type_q ;
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

  always_comb begin
    case (rdata_offset_q)
      2'b00: rdata_w_ext = dmem_rsp_rdata_i[31:0];
      default: rdata_w_ext = '0 ;
    endcase
  end

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

  always_comb begin
    case (data_type_q)
      2'b00:        data_rdata_ext = rdata_b_ext ;
      2'b01:        data_rdata_ext = rdata_h_ext;
      2'b10:        data_rdata_ext = rdata_w_ext;
      default:      data_rdata_ext = 32'b0;
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
      busy_q <= 1'b1;
    end else if (dmem_req_we_q && dmem_gnt_i) begin
      busy_q <= 1'b0;  
    end else if (!dmem_req_we_q && dmem_rvalid_i) begin
      busy_q <= 1'b0;  
    end
  end

  // FSM states
  reg [1:0] fsm_state_q;

  // FSM state logic
  always_comb begin
    case (fsm_state_q)
      // IDLE: Waiting for request
      IDLE: begin
        if (ex_if_req_i)
          fsm_state_q <= MISALIGNED_WR if (data_addr_int[1:0] != 2'b00) or data_addr_int[1:0] == 2'b11
          ALIGNED_RD if (data_addr_int[1:0] == 2'b00)
          ALIGNED_WR if (ex_if_we_i && ex_if_type_i == 2'b00)
          ALIGNED_RD if (ex_if_we_i && ex_if_type_i == 2'b01)
          default: fsm_state_q <= IDLE;
        end
      endcase

      MISALIGNED_WR: begin
        if (ex_if_we_i && ex_if_type_i == 2'b10) begin
          fsm_state_q <= MISALIGNED_WR_1;
        end else
          fsm_state_q <= IDLE;
      endcase

      MISALIGNED_WR_1: begin
        if (dmem_gnt_i) begin
          fsm_state_q <= IDLE;
        end else
          fsm_state_q <= MISALIGNED_WR_1;
      endcase

      MISALIGNED_RD: begin
        if (ex_if_req_i) begin
          fsm_state_q <= MISALIGNED_RD_GNT;
        end else
          fsm_state_q <= IDLE;
      endcase

      MISALIGNED_RD_GNT: begin
        if (dmem_rvalid_i) begin
          fsm_state_q <= MISALIGNED_RD_1;
        end else
          fsm_state_q <= MISALIGNED_RD_GNT;
      endcase

      MISALIGNED_RD_1: begin
        if (dmem_rvalid_i) begin
          fsm_state_q <= IDLE;
        end else
          fsm_state_q <= MISALIGNED_RD_GNT_1;
      endcase

      MISALIGNED_RD_GNT_1: begin
        fsm_state_q <= IDLE;
      endcase

      ALIGNED_WR: begin
        if (ex_if_we_i && ex_if_type_i == 2'b00) begin
          fsm_state_q <= ALIGNED_WR;
        end else
          fsm_state_q <= IDLE;
      endcase

      ALIGNED_RD: begin
        if (ex_if_req_i) begin
          fsm_state_q <= ALIGNED_RD_GNT;
        end else
          fsm_state_q <= IDLE;
      endcase

      ALIGNED_RD_GNT: begin
        if (dmem_rvalid_i) begin
          fsm_state_q <= ALIGNED_RD;
        end else
          fsm_state_q <= IDLE;
      endcase
    endcase
  end

  // FSM logic for misaligned transactions
  always_comb begin
    case (fsm_state_q)
      IDLE: begin
        if (ex_if_req_i && data_addr_int[1:0] != 2'b00)
          dmem_req_be_o = 4'b0001;
        else if (ex_if_req_i && data_addr_int[1:0] == 2'b11)
          dmem_req_be_o = 4'b1000;
        else
          dmem_req_be_o = 4'b0000;
      endcase

      MISALIGNED_WR: begin
        dmem_req_be_o = 4'b0001;
        dmem_req_addr_q = data_addr_int;
        dmem_req_wdata_q = ex_if_wdata_i;
      endcase

      MISALIGNED_WR_1: begin
        dmem_req_be_o = 4'b0001;
        dmem_req_addr_q = data_addr_int;
        dmem_req_wdata_q = ex_if_wdata_i;
      endcase

      MISALIGNED_RD_GNT: begin
        dmem_req_be_o = 4'b0000;
        dmem_req_addr_q = data_addr_int;
        dmem_req_wdata_q = '0;
        rdata_offset_q = data_addr_int[1:0];
      endcase

      MISALIGNED_RD_1: begin
        dmem_req_be_o = 4'b0000;
        dmem_req_addr_q = data_addr_int;
        dmem_req_wdata_q = '0;
        rdata_offset_q = data_addr_int[1:0];
      endcase

      ALIGNED_WR: begin
        dmem_req_be_o = 4'b0000;
        dmem_req_addr_q = '0;
        dmem_req_wdata_q = '0;
      endcase

      ALIGNED_RD_GNT: begin
        dmem_req_be_o = 4'b0000;
        dmem_req_addr_q = '0;
        dmem_req_wdata_q = '0;
        rdata_offset_q = '0;
      endcase

      ALIGNED_RD: begin
        dmem_req_be_o = 4'b0000;
        dmem_req_addr_q = '0;
        dmem_req_wdata_q = '0;
        rdata_offset_q = '0;
      endcase
    endcase
  end

endmodule
