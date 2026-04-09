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
    output logic                 ex_if_ready_o,

    // Writeback stage interface
    output logic     [31:0]      wb_if_rdata_o,         // Requested data
    output logic                 wb_if_rvalid_o,

    // Data memory (DMEM) interface
    output logic                 dmem_req_o,
    input  logic                 dmem_gnt_i,
    output logic     [31:0]      dmem_req_addr_o,
    output logic                 dmem_req_we_o,
    output logic     [31:0]      dmem_req_be_o,
    output logic     [31:0]      dmem_req_wdata_o,
    input  logic     [31:0]      dmem_rsp_rdata_i,
    input  logic                 dmem_rvalid_i
);

  // FSM states
  logic state                 fsm_state;

  // FSM transitions
  always_ff @(posedge rst_n) begin
    fsm_state <= IDLE;
  end

  // State transitions
  always_ff @(posedge clk) begin
    case (fsm_state)
      IDLE:
        // Handle aligned or misaligned requests
        if (aligned) {
          // Aligned transaction
          if (!rst_n) {
            // Initial setup
            dmem_req_q <= 1'b0;
            dmem_req_addr_q <= '0;
            dmem_req_we_q <= '0;
            dmem_req_be_q <= '0;
            dmem_req_wdata_q <= '0;
          } else if (ex_if_req_i && !dmem_rvalid_i) {
            // Start aligned transaction
            dmem_req_q <= 1'b1;
            dmem_req_addr_q <= data_addr_int;
            dmem_req_we_q <= ex_if_we_i;
            dmem_req_be_q <= dmem_be;
            dmem_req_wdata_q <= ex_if_wdata_i;
          } else if (dmem_req_q && dmem_gnt_i) {
            // Complete aligned transaction
            dmem_req_q <= 1'b0;
            dmem_req_addr_q <= '0;
            dmem_req_we_q <= '0;
            dmem_req_be_q <= '0;
            dmem_req_wdata_q <= '0;
          }
        else {
          // Handle misaligned requests
          if (ex_if_type_i == 2 || ex_if_type_i == 1) {
            // Split into two transactions
            fsm_state <= MISALIGNED_WR;
          } else {
            fsm_state <= ALIGNED_WR;
          }
        }
      MISALIGNED_WR:
        // Start first transaction for misaligned store
        dmem_req_q <= 1'b1;
        dmem_req_addr_q <= data_addr_int[1:0];
        dmem_req_we_q <= ex_if_we_i;
        dmem_req_be_q <= dmem_be;
        dmem_req_wdata_q <= ex_if_wdata_i;
        fsm_state <= MISALIGNED_WR_1;
      MISALIGNED_WR_1:
        // Complete second transaction for misaligned store
        dmem_req_q <= 1'b0;
        dmem_req_addr_q <= '0;
        dmem_req_we_q <= '0;
        dmem_req_be_q <= '0;
        dmem_req_wdata_q <= '0;
        fsm_state <= IDLE;
      ALIGNED_WR:
        // Single transaction for aligned store
        if (!rst_n) {
          // Initial setup
          dmem_req_q <= 1'b0;
          dmem_req_addr_q <= data_addr_int;
          dmem_req_we_q <= ex_if_we_i;
          dmem_req_be_q <= dmem_be;
          dmem_req_wdata_q <= ex_if_wdata_i;
        } else if (ex_if_req_i && !dmem_rvalid_i) {
          // Start transaction
          dmem_req_q <= 1'b1;
          dmem_req_addr_q <= data_addr_int;
          dmem_req_we_q <= ex_if_we_i;
          dmem_req_be_q <= dmem_be;
          dmem_req_wdata_q <= ex_if_wdata_i;
        } else if (dmem_req_q && dmem_gnt_i) {
          // Complete transaction
          dmem_req_q <= 1'b0;
          dmem_req_addr_q <= '0;
          dmem_req_we_q <= '0;
          dmem_req_be_q <= '0;
          dmem_req_wdata_q <= '0;
        }
        fsm_state <= IDLE;
      // Similar state transitions for misaligned reads and aligned reads
      // (omitted for brevity)
    endcase
  end

  // Bus transaction control
  always_comb begin
    assign dmem_req_q = fsm_state == MISALIGNED_WR || fsm_state == MISALIGNED_WR_1 ? 1'b1 : 1'b0;
    assign dmem_req_addr_q = fsm_state == MISALIGNED_WR || fsm_state == MISALIGNED_WR_1 ? data_addr_int : '0;
    assign dmem_req_we_q = fsm_state == MISALIGNED_WR || fsm_state == MISALIGNED_WR_1 ? ex_if_we_i : '0;
    assign dmem_req_be_q = fsm_state == MISALIGNED_WR || fsm_state == MISALIGNED_WR_1 ? dmem_be : '0;
    assign dmem_req_wdata_q = fsm_state == MISALIGNED_WR || fsm_state == MISALIGNED_WR_1 ? ex_if_wdata_i : '0;
  end

  // Bus response handling
  always_comb begin
    case (fsm_state)
      IDLE:
        assign dmem_req_o = dmem_req_q;
        assign dmem_req_addr_o = dmem_req_addr_q;
        assign dmem_req_we_o = dmem_req_we_q;
        assign dmem_req_be_o = dmem_req_be_q;
        assign dmem_req_wdata_o = dmem_req_wdata_q;
      MISALIGNED_WR:
        if (dmem_rvalid_i) {
          assign dmem_req_o = 1'b0;
          assign dmem_req_addr_o = '0;
          assign dmem_req_we_o = '0;
          assign dmem_req_be_o = '0;
          assign dmem_req_wdata_o = '0;
        }
      // Similar response handling for other states
      // (omitted for brevity)
    endcase
  end

  // Bus signal assertions
  always_comb begin
    if (fsm_state == IDLE) {
      if (!rst_n) {
        dmem_req_o <= '0;
        dmem_req_addr_o <= '0;
        dmem_req_we_o <= '0;
        dmem_req_be_o <= '0;
        dmem_req_wdata_o <= '0;
      }
    }
    // Similar assertions for other states
    // (omitted for brevity)
  end