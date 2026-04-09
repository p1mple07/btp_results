module qam16_demapper_interpolated #(
    parameter int unsigned N = 4, // Number of original input symbols
    parameter int unsigned OUT_WIDTH = 4, // Bit width of each output symbol
    parameter int unsigned IN_WIDTH = 3 // Bit width of I/Q components
)(
    input logic [(N + N/2)*IN_WIDTH - 1:0] I, // Packed input vector containing real (I) components of QAM16 symbols
    input logic [(N + N/2)*IN_WIDTH - 1:0] Q, // Packed input vector containing imaginary (Q) components of QAM16 symbols
    output logic [N*OUT_WIDTH - 1:0] bits, // Packed output vector representing the original bit stream decoded from the input I/Q values
    output logic error_flag // Global flag indicating whether any errors were detected in the interpolated values
);

localparam int unsigned ERROR_THRESHOLD = 2; // Absolute difference threshold for error detection

// Calculate expected interpolated values
logic [(IN_WIDTH + 1)-1:0] expected_I;
logic [(IN_WIDTH + 1)-1:0] expected_Q;
assign expected_I = (I[(N+N/2)*IN_WIDTH-1:N*IN_WIDTH] + I[(N+N/2)*IN_WIDTH-3:N*IN_WIDTH-2]) / 2;
assign expected_Q = (Q[(N+N/2)*IN_WIDTH-1:N*IN_WIDTH] + Q[(N+N/2)*IN_WIDTH-3:N*IN_WIDTH-2]) / 2;

// Calculate absolute difference between interpolated values and expected values
logic [(IN_WIDTH + 1)-1:0] diff_I;
logic [(IN_WIDTH + 1)-1:0] diff_Q;
assign diff_I = $signed(expected_I) - $signed(I[(N+N/2)*IN_WIDTH-1:N*IN_WIDTH]);
assign diff_Q = $signed(expected_Q) - $signed(Q[(N+N/2)*IN_WIDTH-1:N*IN_WIDTH]);

// Determine error flag based on absolute difference threshold
assign error_flag = (|(diff_I)) | (|(diff_Q));

// Map I/Q components to bits
logic [(IN_WIDTH + 1)-1:0] bits_I;
logic [(IN_WIDTH + 1)-1:0] bits_Q;
always_comb begin
  case ({I[N*IN_WIDTH-1:0], I[N*IN_WIDTH-3:0]})
    '-3': bits_I = 'b00;
    '-1': bits_I = 'b01;
    '1 ': bits_I = 'b10;
    '3 ': bits_I = 'b11;
    default: bits_I = 'b00;
  endcase

  case ({Q[N*IN_WIDTH-1:0], Q[N*IN_WIDTH-3:0]})
    '-3': bits_Q = 'b00;
    '-1': bits_Q = 'b01;
    '1 ': bits_Q = 'b10;
    '3 ': bits_Q = 'b11;
    default: bits_Q = 'b00;
  endcase

  // Pack I/Q components and error flag into single output vector
  bits = {bits_I, bits_Q, error_flag};
end

endmodule