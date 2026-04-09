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

  // Generate byte/halfword/word extensions
  always_comb begin
    misaligned_addr = 1'b0;
    dmem_be = 4'b0000;

    if (ex_if_type_i == 2'b00) begin
      case (ex_if_extend_mode_i)
        2'b00: dmem_be = 4'b0001;  // zero-extend for byte
        2'b01: dmem_be = 4'b0010;  // sign-extend for byte
        2'b10: dmem_be = 4'b0100;  // zero-extend for halfword
        2'b11: dmem_be = 4'b1000;  // sign-extend for halfword
      endcase
    end
    else if (ex_if_type_i == 2'b01) begin
      case (ex_if_extend_mode_i)
        2'b00: dmem_be = 4'b0011;  // zero-extend for halfword
        2'b10: dmem_be = 4'b1100;  // sign-extend for halfword
      endcase
    end
    else if (ex_if_type_i == 2'b10) begin
      case (ex_if_extend_mode_i)
        2'b00: dmem_be = 4'b1111;  // zero-extend for word
        2'b01: dmem_be = 4'b0000;  // sign-extend for word
      endcase
    end
  end

  ////////////////////////////////////////////////////////////////////////
  // New input signal: ex_if_extend_mode_i (1‑bit)
  input  logic ex_if_extend_mode_i;

  ////////////////////////////////////////////////////////////////////////
  always_comb begin : dmem_req
    dmem_req_o        = dmem_req_q;
    dmem_req_addr_o   = dmem_req_addr_q;
    dmem_req_we_o     = dmem_req_we_q;
    dmem_req_be_o     = dmem_req_be_q;
    dmem_req_wdata_o  = dmem_req_wdata_q;
  end

  // ////////////////////////////////////////////////////////////////////////
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

  ////////////////////////////////////////////////////////////////////////
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
