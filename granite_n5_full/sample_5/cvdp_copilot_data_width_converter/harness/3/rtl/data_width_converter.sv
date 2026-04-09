module data_width_converter (
  input logic clk,
  input logic reset,
  input logic [31:0] data_in,
  input logic data_valid,
  output logic [127:0] o_data_out,
  output logic o_data_out_valid
);

  // Internal state variables
  logic [3:0] counter;
  logic [127:0] buffer;
  logic buffer_ready;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      counter <= 0;
      buffer <= 0;
      buffer_ready <= 0;
    end else begin
      if (counter < 4 && data_valid) begin
        buffer <= {buffer[127:96], data_in};
        counter <= counter + 1;
        buffer_ready <= (counter == 4);
      end else begin
        buffer_ready <= 0;
      end
    end
  end

  assign o_data_out = buffer;
  assign o_data_out_valid = buffer_ready;

endmodule