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

  // Misalignment flag
  reg [1:0] misaligned_state = 2'b00;
  assign misaligned_addr = (ex_if_type_i == 2'b00 || ex_if_type_i == 2'b01) && data_addr_int[1:0] != 2'b00;

  always_comb begin
    misaligned_addr = (misaligned_state == 2'b01) && misaligned_addr;
    misaligned_addr = (misaligned_state == 2'b01) && (data_addr_int[1:0] != 2'b00);
  end

  logic [3:0] dmem_be, dmem_req_be_q;
  logic [3:0] dmem_req_addr_q, dmem_req_addr_q;

  // Aligned vs misaligned
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
      rdata_offset_q <= '0;
      misaligned_state <= 2'b00;
    end else if (ex_req_fire) begin
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= ex_if_we_i;
      dmem_req_be_q <= ex_if_type_i[3:2];
      dmem_req_wdata_q <= ex_if_wdata_i;

      rdata_offset_q <= data_addr_int[1:0];
      data_sign_ext_q <= ex_if_extend_mode_i;
      data_type_q <= ex_if_type_i;
    end else if (dmem_req_q && dmem_gnt_i) begin
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0 ;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
    end
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
        if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[15]}}, dmem_rsp_rdata_i[31:16]};
        else rdata_h_ext = {16'h0000, dmem_rsp_rdata_i[31:16]}; 
      end

      2'b10: begin
        if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:16]};
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

endmodule
