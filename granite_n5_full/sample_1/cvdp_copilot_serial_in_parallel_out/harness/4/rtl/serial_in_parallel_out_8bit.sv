module serial_in_parallel_out_8bit (
  input wire clk, // Clock input
  input wire serial_in, // Serial input bit
  output reg [7:0] parallel_out // Parallel output register
);

  always @(posedge clk) begin
    parallel_out <= {parallel_out[6:0], serial_in};
  end

endmodule