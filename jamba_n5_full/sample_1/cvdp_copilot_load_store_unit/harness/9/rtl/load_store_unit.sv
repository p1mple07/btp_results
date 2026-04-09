// ... existing header …

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

  // Internal state machine
  localparam EX_STATE = 2;
  localparam WR_STATE   = 3;
  localparam RD_STATE   = 4;
  localparam RD_GRANT  = 5;

  reg [EX_STATE:0] state;
  reg [WR_STATE:0]  wr_grant;
  reg [RD_STATE:0]  rd_grant;

  assign state = ex_req_fire ? (misaligned_addr ? MISALIGNED_WR : IDLE) : IDLE;

always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
    ex_req_fire <= 1'b0;
    ex_if_ready_o <= 1'b0;
  end else if (state == IDLE) begin
    if (ex_req_fire && !busy_q && !misaligned_addr) begin
      state <= WR_STATE;
    end else if (state == IDLE && (ex_req_req_i && ex_if_req_i)) begin
      state <= MISALIGNED_WR;
    end
  end else if (state == WR_STATE) begin
    if (ex_if_we_i && ex_if_type_i == 2'b00) begin
      // word write
      if (ex_if_addr_offset_i[1:0] != 2'b00) begin
        state <= MISALIGNED_WR_1;
      end else begin
        state <= IDLE;
      end
    end else if (ex_if_type_i == 2'b01) begin
      // halfword write
      if (ex_if_addr_offset_i[1:0] != 2'b00) begin
        state <= MISALIGNED_WR;
      end else begin
        state <= IDLE;
      end
    end else if (state == MISALIGNED_WR && ex_if_we_q && ex_if_we_i) begin
      state <= MISALIGNED_WR_1;
    end else if (state == MISALIGNED_WR_1 && dmem_rvalid_i) begin
      state <= IDLE;
    end
  end else if (state == MISALIGNED_RD && dmem_rvalid_i) begin
    state <= RD_GNT;
  end else if (state == RD_GNT && dmem_rvalid_i) begin
    state <= MISALIGNED_RD_1;
  end else if (state == MISALIGNED_RD_1 && dmem_rvalid_i) begin
    state <= MISALIGNED_RD_GNT_1;
  end else if (state == MISALIGNED_RD_GNT_1 && dmem_rvalid_i) begin
    state <= IDLE;
  end else if (state == MISALIGNED_RD_GNT_1 && dmem_rvalid_i) begin
    state <= IDLE;
  end else if (state == MISALIGNED_RD_GNT_1 && dmem_rvalid_i) begin
    state <= IDLE;
  end

  // First bus transaction
  always_comb begin
    if (state == WR_STATE) begin
      if (ex_if_we_i && ex_if_type_i == 2'b00) begin
        dmem_req_wdata_q <= ex_if_wdata_i[31:0];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end else if (ex_if_we_i && ex_if_type_i == 2'b01) begin
        dmem_req_wdata_q <= ex_if_wdata_i[31:8];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end
      wb_if_rvalid_o <= 1'b0;
    end else if (state == MISALIGNED_WR_1) begin
      if (ex_if_we_q && ex_if_type_i == 2'b00) begin
        dmem_req_wdata_q <= ex_if_wdata_q[31:0];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end else if (ex_if_we_q && ex_if_type_i == 2'b01) begin
        dmem_req_wdata_q <= ex_if_wdata_q[31:8];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end
      wb_if_rvalid_o <= 1'b0;
    end else if (state == MISALIGNED_RD_1) begin
      if (ex_if_we_q && ex_if_type_i == 2'b00) begin
        dmem_req_wdata_q <= ex_if_wdata_q[31:0];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end else if (ex_if_we_q && ex_if_type_i == 2'b01) begin
        dmem_req_wdata_q <= ex_if_wdata_q[31:8];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end
      wb_if_rvalid_o <= 1'b0;
    end
  end

  // Second bus transaction
  always_comb begin
    if (state == MISALIGNED_WR_1) begin
      if (ex_if_we_q && ex_if_type_i == 2'b00) begin
        dmem_req_wdata_q <= ex_if_wdata_q[31:0];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end else if (ex_if_we_q && ex_if_type_i == 2'b01) begin
        dmem_req_wdata_q <= ex_if_wdata_q[31:8];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end
      wb_if_rvalid_o <= 1'b1;
    end else if (state == MISALIGNED_RD_1) begin
      if (ex_if_we_q && ex_if_type_i == 2'b00) begin
        dmem_req_wdata_q <= ex_if_wdata_q[31:0];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end else if (ex_if_we_q && ex_if_type_i == 2'b01) begin
        dmem_req_wdata_q <= ex_if_wdata_q[31:8];
        wb_if_rdata_o <= dmem_req_wdata_q;
      end
      wb_if_rvalid_o <= 1'b1;
    end
  end

  // Data memory responses
  always_ff @(posedge dmem_req_addr_q) begin
    wb_if_rdata_o = 32'b0;
    wb_if_rvalid_o = 1'b0;
  end

endmodule
