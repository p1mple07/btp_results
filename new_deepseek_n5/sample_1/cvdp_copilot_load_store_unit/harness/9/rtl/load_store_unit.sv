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
    input  logic     [31:0]      ex_if_extend_mode_i,
    output logic                 ex_if_ready_o,

    // Writeback stage interface
    output logic     [31:0]      wb_if_rdata_o,         // Requested data
    output logic                 wb_if_rvalid_o,

    // Data memory (DMEM) interface
    output logic                 dmem_req_o,
    input  logic                 dmem_gnt_i,
    output logic     [31:0]      dmem_req_addr_o,
    output logic                 dmem_req_we_o,
    output logic     [3:0]      dmem_req_be_o,
    output logic     [31:0]      dmem_req_wdata_o,
    input  logic     [31:0]      dmem_rsp_rdata_i,
    input  logic                 dmem_rvalid_i
);

  // FSM State Variables
  input  logic state;
  output logic next_state;
  output logic done;

  // FSM Control Signals
  input logic state_valid;
  input logic state alignment;

  logic ex_req_fire;
  logic dmem_req_q;
  logic dmem_req_addr_q;
  logic dmem_req_we_q;
  logic dmem_req_be_q;
  logic dmem_req_wdata_q;

  logic rdata_offset_q;
  logic rdata_w_ext;
  logic rdata_h_ext;
  logic rdata_b_ext;

  logic busy_q;
  logic dmem_req_q;
  logic dmem_gnt_i;

  // FSM State Transitions
  state = IDLE;
  always @* begin
    case (state)
      IDLE:
        if (rst_n) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (alignment == 0 && alignment == 2) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (alignment == 1) {
          state = MISALIGNED_RD;
          next_state = MISALIGNED_RD;
          done = 1'b0;
        }
      MISALIGNED_RD:
        if (rst_n) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (dmem_rvalid_i) {
          state = MISALIGNED_RD_GNT;
          next_state = MISALIGNED_RD_GNT;
          done = 1'b0;
        }
      MISALIGNED_RD_GNT:
        if (rst_n) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (dmem_rvalid_i) {
          state = MISALIGNED_RD_1;
          next_state = MISALIGNED_RD_1;
          done = 1'b0;
        }
      MISALIGNED_RD_1:
        if (rst_n) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (dmem_rvalid_i) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        }
      ALIGNED_RD:
        if (rst_n) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (dmem_rvalid_i) {
          state = ALIGNED_RD_GNT;
          next_state = ALIGNED_RD_GNT;
          done = 1'b0;
        }
      ALIGNED_RD_GNT:
        if (rst_n) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (dmem_rvalid_i) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        }
      ALIGNED_WR:
        if (rst_n) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (ex_if_we_i == 1) {
          state = ALIGNED_WR;
          next_state = IDLE;
          done = 1'b1;
        }
      MISALIGNED_WR:
        if (rst_n) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (ex_if_we_i == 1) {
          state = MISALIGNED_WR;
          next_state = MISALIGNED_WR_1;
          done = 1'b0;
        }
      MISALIGNED_WR_1:
        if (rst_n) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b0;
        } else if (ex_if_we_i == 1) {
          state = IDLE;
          next_state = IDLE;
          done = 1'b1;
        }
    endcase
  end

  // FSM Control Signals Assignment
  state_valid = 1'b0;
  state_alignment = 0;

  always @* begin
    case (state)
      IDLE:
        state_valid = 1'b0;
        state_alignment = 0;
      MISALIGNED_RD:
        state_valid = 1'b0;
        state_alignment = 1;
      MISALIGNED_RD_GNT:
        state_valid = 1'b0;
        state_alignment = 1;
      MISALIGNED_RD_1:
        state_valid = 1'b0;
        state_alignment = 1;
      ALIGNED_RD_GNT:
        state_valid = 1'b0;
        state_alignment = 0;
      ALIGNED_WR:
        state_valid = 1'b0;
        state_alignment = 0;
      MISALIGNED_WR:
        state_valid = 1'b0;
        state_alignment = 1;
      MISALIGNED_WR_1:
        state_valid = 1'b0;
        state_alignment = 1;
    endcase
  end

  // Data Handling
  always_comb begin
    case (rdata_offset_q)
      2'b00: rdata_w_ext = dmem_rsp_rdata_i[31:0];
      default: rdata_w_ext = '0;
    endcase
  end

  always_comb begin
    case (rdata_offset_q)
      2'b00: begin
        if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[15]}}, dmem_rsp_rdata_i[15:0]};
        else rdata_h_ext = {16'h0000, dmem_rsp_rdata_i[15:0]};
      end
      2'b01: begin
        if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[31]}}, dmem_rsp_rdata_i[31:16]};
        else rdata_h_ext = {16'h0000, dmem_rsp_rdata_i[31:16]};
      end
      2'b10: begin
        if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[23]}}, dmem_rsp_rdata_i[23:16]};
        else rdata_h_ext = {16'h0000, dmem_rsp_rdata_i[23:16]};
      end
      2'b11: begin
        if (data_sign_ext_q) rdata_h_ext = {{16{dmem_rsp_rdata_i[31:24]}}, dmem_rsp_rdata_i[31:24]};
        else rdata_h_ext = {16'h0000, dmem_rsp_rdata_i[31:24]};
      end
    endcase
  end

  always_comb begin
    case (data_type_q)
      2'b00: data_rdata_ext = rdata_b_ext;
      2'b01: data_rdata_ext = rdata_h_ext;
      2'b10: data_rdata_ext = rdata_w_ext;
      default: data_rdata_ext = 32'b0;
    endcase
  end

  always_comb begin : dmem_req
    dmem_req_o = dmem_req_q;
    dmem_req_addr_o = dmem_req_addr_q;
    dmem_req_we_o = dmem_req_we_q;
    dmem_req_be_o = dmem_req_be_q;
    dmem_req_wdata_o = dmem_req_wdata_q;
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end else if (state == MISALIGNED_RD) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end else if (state == MISALIGNED_RD_1) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end else if (state == MISALIGNED_WR) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end else if (state == MISALIGNED_WR_1) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end else if (state == ALIGNED_RD) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end else if (state == ALIGNED_RD_GNT) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end else if (state == ALIGNED_WR) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end else if (state == MISALIGNED_WR_1) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end else if (state == IDLE) begin
      dmem_req_q <= 32'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0;
      dmem_req_be_q <= '0;
      dmem_req_wdata_q <= '0;
    end
  end

  always_comb begin : dmem_req
    dmem_req_o = dmem_req_q;
    dmem_req_addr_o = dmem_req_addr_q;
    dmem_req_we_o = dmem_req_we_q;
    dmem_req_be_o = dmem_req_be_q;
    dmem_req_wdata_o = dmem_req_wdata_q;
  end

  always_comb begin : dmem_req
    dmem_req_o = dmem_req_q;
    dmem_req_addr_o = dmem_req_addr_q;
    dmem_req_we_o = dmem_req_we_q;
    dmem_req_be_o = dmem_req_be_q;
    dmem_req_wdata_o = dmem_req_wdata_q;
  end

  always_comb begin : dmem_req
    dmem_req_o = dmem_req_q;
    dmem_req_addr_o = dmem_req_addr_q;
    dmem_req_we_o = dmem_req_we_q;
    dmem_req_be_o = dmem_req_be_q;
    dmem_req_wdata_o = dmem_req_wdata_q;
  end