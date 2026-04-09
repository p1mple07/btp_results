module poly_decimator #(
  parameter M = 4,
  parameter TAPS = 8,
  parameter COEFF_WIDTH = 16,
  parameter DATA_WIDTH = 16
) (
  input logic                        clk,
  input logic                        arst_n,
  input logic [DATA_WIDTH-1:0]     sample_buffer [0:M*TAPS-1], // From shift_register
  input logic                        valid_in,
  input logic [$clog2(M)-1:0]      phase,
  output logic [COEFF_WIDTH+DATA_WIDTH+ $clog2(TAPS)+16-1:0] filter_out,
  output logic                                valid
);

// Stage 0: Input Registration
logic [DATA_WIDTH-1:0] sample_reg [0:TAPS-1];
always_ff @(posedge clk or negedge arst_n) begin
  if (!arst_n) begin
    for (i = 0; i < TAPS; i = i + 1)
      sample_reg[i] <= '0;
    phase_reg <= '0;
    valid_stage0 <= 1'b0;
  end
  else begin
    if (valid_in) begin
      for (i = 0; i < TAPS; i = i + 1)
        sample_reg[i] <= sample_buffer[i];
      phase_reg <= phase;
      valid_stage0 <= 1'b1;
    end
    else begin
      valid_stage0 <= 1'b0;
    end
  end
end

// ... rest of the integration code ...