`timescale 1ns / 1ps

module poly_decimator(
    input  logic                 clk,
    input  logic                 arst_n,
    input  logic [DATA_WIDTH-1:0] sample_buffer [0:TAPS-1],
    input  logic                 valid_in,
    input  logic [$clog2(M)-1:0] phase,
    output logic [ACC_WIDTH-1:0] filter_out,
    output logic                 valid
);

  localparam M = 4;
  localparam TAPS = 8;
  localparam ACC_WIDTH = DATA_WIDTH + COEFF_WIDTH + $clog2(TAPS);
  localparam NUM_INPUTS = TAPS * M;

  // Internal state variables
  logic [DATA_WIDTH-1:0] sample_reg [0:TAPS-1];
  logic [$clog2(M)-1:0] phase_reg;
  logic                  valid_stage0;
  logic [DATA_WIDTH-1:0] coeff;
  logic [DATA_WIDTH-1:0] products;
  logic [DATA_WIDTH-1:0] sum_result;
  logic                 valid_adder;
  logic [DATA_WIDTH-1:0] filter_out_tmp;

  // Shift register for storing input samples
  shift_register #(
      .TAPS(TAPS),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_shift_reg (
      .clk(clk),
      .arst_n(arst_n),
      .load(valid_in),
      .new_sample(sample_buffer),
      .data_out(data_out_val),
      .data_out_val(valid_stage0)
  );

  // Initialization of shift register
  initial begin
    forever @(posedge clk or negedge arst_n) begin
      if (!arst_n) begin
        for (int i = 0; i < TAPS; i = i + 1)
          sample_reg[i] <= '0;
        phase_reg <= '0;
        valid_stage0 <= 1'b0;
      end
    end
  end

  // Coefficient RAM initialization
  coeff_ram #(
      .NUM_COEFFS(M*TAPS),
      .DATA_WIDTH(COEFF_WIDTH)
  ) u_coeff (
      .clk(clk),
      .addr(phase_reg*TAPS + $urandom_range(0, NUM_COEFFS-1)),
      .data_out(coeff[TAPS-1:0])
  );

  // Filter poly_filter instantiation
  poly_filter #(.M(M), .TAPS(TAPS), .COEFF_WIDTH(COEFF_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) u_poly_filter (
      .clk(clk),
      .arst_n(arst_n),
      .sample_buffer(sample_reg),
      .phase(phase_reg),
      .filter_out(filter_out_tmp),
      .valid(valid_adder)
  );

  // Adder tree to sum decimated samples
  adder_tree #(.NUM_INPUTS(NUM_INPUTS)) u_adder_tree (
      .clk(clk),
      .arst_n(arst_n),
      .valid_in(valid_stage0),
      .data_in(products),
      .sum_out(sum_result),
      .valid_out(valid_adder)
  );

  // Final output registration
  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      filter_out_tmp <= '0;
      valid = 1'b0;
    end
    else begin
      filter_out_tmp <= sum_result;
      valid = valid_adder;
    end
  end

  // Assign outputs
  assign filter_out = filter_out_tmp;
  assign valid = valid;

endmodule
