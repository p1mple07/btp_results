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

  // Finite State Machine (FSM)
  reg [2:0] fsm_state_reg;
  assign fsm_state_reg = 3'b0;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      fsm_state_reg <= 3'b0;
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
      rdata_offset_q <= '0 ;
      busy_q <= 1'b0;
    end else if (ex_if_req_i) begin
      case (fsm_state_reg)
        3'b000: fsm_state_reg <= 3'b001; // IDLE to ALIGNED_WR
        3'b001: begin
          if (ex_if_type_i == 2'b00) begin // Word Access
            if (data_addr_int[1:0] == 2'b00) begin
              dmem_req_we_q <= ex_if_we_i;
              dmem_req_addr_q <= data_addr_int;
              dmem_req_be_q <= 4'b0000;
              dmem_req_wdata_q <= ex_if_wdata_i;
            end else begin
              dmem_req_we_q <= 0;
              dmem_req_addr_q <= '0;
              dmem_req_be_q <= 4'b0000;
              dmem_req_wdata_q <= '0;
            end
          end
        end
        3'b001: fsm_state_reg <= 3'b010; // IDLE to MISALIGNED_WR
        case ({ex_if_type_i, data_addr_int[1:0]})
          2'b110: fsm_state_reg <= 3'b101; // MISALIGNED_WR to MISALIGNED_WR_1
          default: fsm_state_reg <= 3'b000; // Other cases go back to IDLE
        endcase
      end
    end

    always_comb begin
      misaligned_addr = ex_if_extend_mode_i || (data_addr_int[1:0] != 2'b00 && data_addr_int[1:0] != 2'b11);
      case (fsm_state_reg)
        3'b001: dmem_req_be_q <= 4'b0000;
        3'b101: begin
          case (data_addr_int[1:0])
            2'b00: dmem_be = 4'b0001;
            2'b10: dmem_be = 4'b0100;
            2'b11: dmem_be = 4'b1000;
            default: dmem_be = 4'b0000;
          endcase
        end
        3'b101: dmem_req_be_q <= 4'b0000;
        3'b010: dmem_req_be_q <= 4'b0000;
      endcase
    end

    assign dmem_req_o        = dmem_req_q && !misaligned_addr;
    assign dmem_req_addr_o   = dmem_req_addr_q;
    assign dmem_req_we_o     = dmem_req_we_q;
    assign dmem_req_be_o     = dmem_req_be_q;
    assign dmem_req_wdata_o  = dmem_req_wdata_q;

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

    case (fsm_state_reg)
      3'b001:
        wb_if_rdata_q <= '0;
        wb_if_rvalid_q <= 1'b0;
      default:
        case (ex_if_we_i)
          0: begin
            if (misaligned_addr) begin
              wb_if_rdata_q <= dmem_rsp_rdata_i[31:24]; // First halfword
              wb_if_rvalid_q <= dmem_rvalid_i;
            end
            wb_if_rdata_q <= '0;
            wb_if_rvalid_q <= 1'b0;
          end
          1: begin
            if (misaligned_addr) begin
              wb_if_rdata_q <= dmem_rsp_rdata_i[24:31]; // Second halfword
              wb_if_rvalid_q <= dmem_rvalid_i;
            end
            wb_if_rdata_q <= '0;
            wb_if_rvalid_q <= 1'b0;
          end
        end

      3'b101:
        case (data_type_q)
          2'b00:        data_rdata_ext = rdata_b_ext ;
          2'b01:        data_rdata_ext = rdata_h_ext;
          2'b10:        data_rdata_ext = rdata_w_ext;
          3'b11: begin
            if (data_sign_ext_q) data_rdata_ext = {{24{dmem_rsp_rdata_i[7]}}, dmem_rsp_rdata_i[7:0]}; 
            else data_rdata_ext = {24'h00_0000, dmem_rsp_rdata_i[7:0]};
          end
        end
      end
    end

    assign wb_if_rdata_o =  wb_if_rdata_q;
    assign wb_if_rvalid_o = wb_if_rvalid_q;

    always_comb begin
      case (fsm_state_reg)
      3'b001: begin
        busy_q <= 1'b0;
      end
      3'b101: begin
        case (dmem_req_we_q && dmem_gnt_i)
          busy_q <= 1'b0;
        default:
          busy_q <= 1'b0;
        endcase
      end
    end
  end

endmodule
