module binary_to_one_hot_decoder_sequential #(
  parameter int BINARY_WIDTH = 5,    // Input binary width
  parameter int OUTPUT_WIDTH = 32   // Output one-hot width
)(
  input  wire [BINARY_WIDTH-1:0] i_binary_in,     // Input binary signal
  input  wire                      i_clk,           // Clock signal
  input  wire                      i_rstb,          // Asynchronous reset signal
  output reg  [OUTPUT_WIDTH-1:0] o_one_hot_out   // Output one-hot signal
);

reg [OUTPUT_WIDTH-1:0] state;

always @(posedge i_clk or posedge i_rstb) begin
  if (i_rstb == 1'b0) begin
    state <= {OUTPUT_WIDTH{1'b0}}; // Reset to all zeros
  end else begin
    state <= {state[OUTPUT_WIDTH-2:0], 1'b0}; // Shift left and insert new zero bit
    state[i_binary_in] <= 1'b1;              // Set the corresponding bit to 1 based on input binary value
  end
end

assign o_one_hot_out = state;

endmodule