rtl/one_hot_gen.sv
------------------------------------------------
module one_hot_gen #(
    parameter integer NS_A = 8,
    parameter integer NS_B = 4
) (
    input  logic                 clk,
    input  logic                 rst_async_n,
    input  logic [1:0]           i_config,
    input  logic                 i_start,
    input  logic                 o_ready,
    output logic [NS_A+NS_B-1:0] o_address_one_hot
);

  // FSM state declaration
  typedef enum logic [2:0] {IDLE = 2'b00, REGION_A = 2'b01, REGION_B = 2'b10} state_t;

  // Wires/Registers
  state_t state_ff, state_nx;
  logic [NS_A-1:0] region_A_ff, region_A_nx;
  logic [NS_B-1:0] region_B_ff, region_B_nx;
  logic A_to_B, B_to_A;
  logic [1:0] config_ff;

  // Wire connections
  assign A_to_B = (config_ff[1] & ~config_ff[0]);
  assign B_to_A = (config_ff[1] &  config_ff[0]);

  // Output assignment (concatenation of region A and region B one‐hot vectors)
  assign o_address_one_hot = {region_A_ff, region_B_ff};

  // ----------------------------------------------------------------
  // Input register: capture configuration only when starting
  // ----------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_async_n) begin : input_register
    if (~rst_async_n) begin
      config_ff <= 2'd0;
    end else begin
      if (i_start && state_ff == IDLE)
        config_ff <= i_config;
    end
  end

  // ----------------------------------------------------------------
  // Registers update: synchronous reset and state/region update
  // ----------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_async_n) begin : reset_regs
    if (~rst_async_n) begin
      o_ready      <= 1'b1;
      state_ff     <= IDLE;
      region_A_ff  <= {NS_A{1'b0}};
      region_B_ff  <= {NS_B{1'b0}};
    end else begin
      o_ready      <= (state_nx == IDLE);
      state_ff     <= state_nx;
      region_A_ff  <= region_A_nx;
      region_B_ff  <= region_B_nx;
    end
  end

  // ----------------------------------------------------------------
  // One-hot address generation
  // ----------------------------------------------------------------
  always_comb begin : drive_regions
    // Default: clear both one-hot vectors
    region_A_nx = {NS_A{1'b0}};
    region_B_nx = {NS_B{1'b0}};

    case (state_ff)
      IDLE: begin
        if (i_start) begin
          // For Region A: use i_config[0] (0 or 1) as the one‐hot index.
          region_A_nx[i_config[0]] = 1'b1;
          // For Region B: if i_config[0] is 1 then use the full i_config as index.
          if (i_config[0])
            region_B_nx[i_config] = 1'b1;
        end
      end

      REGION_A: begin
        // Shift Region A one‐hot vector right by one bit.
        region_A_nx = region_A_ff >> 1;
        // When the LSB of region_A_ff becomes 1, load Region B’s vector
        if (region_A_ff[0])
          region_B_nx = (A_to_B) ? ({NS_B{1'b0}, 1'b1