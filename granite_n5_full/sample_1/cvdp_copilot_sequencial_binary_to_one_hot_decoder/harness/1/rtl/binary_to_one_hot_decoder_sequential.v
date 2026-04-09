module binary_to_one_hot_decoder_sequencial #(
  parameter int BINARY_WIDTH = 5, // Specifies the bit width of the binary input
  parameter int OUTPUT_WIDTH = 32 // Defines the width of the output
) (
  input logic [BINARY_WIDTH-1:0] i_binary_in, // Binary input signal
  input logic i_clk, // Clock signal (active on the rising edge)
  input logic i_rstb, // Asynchronous reset signal (active low)
  output logic [OUTPUT_WIDTH-1:0] o_one_hot_out // One-hot encoded output signal
);

  always_ff @(posedge i_clk or posedge i_rstb) begin
    if (!i_rstb) begin
      o_one_hot_out <= 0; // Reset to all zeros
    end else if (i_binary_in < 2**BINARY_WIDTH) begin
      o_one_hot_out <= {OUTPUT_WIDTH{1'b0}}; // All zeros except for the bit corresponding to i_binary_in
      o_one_hot_out[i_binary_in] <= 1; // Set the bit corresponding to i_binary_in to 1
    end else begin
      $display("Error: i_binary_in is out of range"); // Display an error message if i_binary_in is out of range
    end
  end

endmodule