module one_hot_gen #(
    parameter NS_A = 8,
    parameter NS_B = 4
) (
    input  logic                 clk,
    input  logic                 rst_async_n,
    input  logic [1:0]           i_config,
    input  logic                 i_start,
    output logic                 o_ready,
    output logic [NS_A+NS_B-1:0] o_address_one_hot
);

  // Updated enum type width to 2 bits
  typedef enum logic [1:0] {IDLE = 2'b00, REGION_A = 2'b01, REGION_B = 2'b10} state_t;

  // ----------------------------------------
  // - Wires/Registers creation
  // ----------------------------------------
  state_t state_ff, state_nx;
  logic [NS_A-1:0] region_A_ff, region_A_nx;
  logic [NS_B-1:0] region_B_ff, region_B_nx;
  logic A_to_B, B_to_A;  // Removed unused signals only_A and only_B

  // Input register for configuration (same width as i_config)
  logic [1:0] config_ff;

  // ----------------------------------------
  // - Wire connections
  // ----------------------------------------
  // Region change flags
  assign A_to_B = (config_ff[1] & ~config_ff[0]);
  assign B_to_A = (config_ff[1] &  config_ff[0]);

  // Output assignment (Region A concatenated with Region B)
  assign o_address_one_hot = {region_A_ff, region_B_ff};

  // ----------------------------------------
  // - Registers
  // ----------------------------------------
  always_ff @(posedge clk or negedge rst_async_n) begin : input_register
      if (~rst_async_n) begin
          config_ff <= 0;
      end else begin
          if (i_start && state_ff == IDLE) begin
              config_ff <= i_config;
          end
      end
  end

  always_ff @(posedge clk or negedge rst_async_n) begin : state_and_reg_update
      if (~rst_async_n) begin
          o_ready   <= 1;
          state_ff  <= IDLE;
          region_A_ff <= {NS_A{1'b0}};
          region_B_ff <= {NS_B{1'b0}};
      end else begin
          o_ready   <= (state_nx == IDLE);
          state_ff  <= state_nx;
          region_A_ff <= region_A_nx;
          region_B_ff <= region_B_nx;
      end
  end

  // ----------------------------------------
  // - One-hot address generation
  // ----------------------------------------
  always_comb begin : drive_regions
      // Default assignments ensure all bits are driven
      region_A_nx = {NS_A{1'b0}};
      region_B_nx = {NS_B{1'b0}};

      case (state_ff)
          IDLE: begin
              if (i_start) begin
                  // Corrected index: use [NS_A-1] and [NS_B-1] for MSB
                  region_A_nx[NS_A-1] = ~i_config[0];
                  region_B_nx[NS_B-1] = i_config[0];
              end
              // Lower bits remain 0 by default
          end
          REGION_A: begin
              // Shift Region A one position to the right
              region_A_nx = region_A_ff >> 1;
              if (region_A_ff[0]) begin
                  region_B_nx[NS_B-1] = A_to_B;
              end
          end
          REGION_B: begin
              if (region_B_ff[0]) begin
                  region_A_nx[NS_A-1] = B_to_A;
              end
              // Shift Region B one position to the right
              region_B_nx = region_B_ff >> 1;
          end
          default: begin
              region_A_nx = {NS_A{1'b0}};
              region_B_nx = {NS_B{1'b0}};
          end
      endcase
  end

  // ----------------------------------------
  // - FSM update
  // ----------------------------------------
  always_comb begin : update_state
      case (state_ff)
          IDLE: begin
              if (i_start) begin
                  if (i_config[0])
                      state_nx = REGION_B;
                  else
                      state_nx = REGION_A;
              end else begin
                  state_nx = IDLE;
              end
          end
          REGION_A: begin
              if (region_A_ff[0]) begin
                  state_nx = (A_to_B) ? REGION_B : IDLE;
              end else begin
                  state_nx = REGION_A;
              end
          end
          REGION_B: begin
              if (region_B_ff[0]) begin
                  state_nx = (B_to_A) ? REGION_A : IDLE;
              end else begin
                  state_nx = REGION_B;
              end
          end
          default: begin
              state_nx = IDLE;
          end
      endcase
  end

endmodule