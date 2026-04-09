module data_width_converter (
  input logic clk, // Data operations will be performed during positive edge of this clock. The clock operates at 50:50 dutycycle.
  input logic reset, // Asynchronous Active-high reset signal to initialize the system.
  input logic [31:0] data_in, // 32-bit data input to be concatenated into the output.
  input logic data_valid, // A signal indicating whether the current data_in is valid.
  output logic [127:0] o_data_out, // 128-bit concatenated data output, generated after four valid 32-bit inputs.
  output logic o_data_out_valid // A signal indicating that the output data is valid.
);

  localparam NUM_OUTPUT_BITS = 128;
  localparam OUTPUT_WIDTH = NUM_OUTPUT_BITS / 4;
  typedef logic [OUTPUT_WIDTH - 1:0] output_t;

  logic [OUTPUT_WIDTH - 1:0] shift_reg [3:0];
  logic valid_flags [3:0];
  logic [OUTPUT_WIDTH - 1:0] shift_out;
  logic data_out_valid;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      shift_reg <= {OUTPUT_WIDTH{1'b0}};
      valid_flags <= {4{1'b0}};
    end else begin
      for (int i = 0; i < 3; i++) begin
        shift_reg[i+1] <= shift_reg[i];
        valid_flags[i+1] <= valid_flags[i];
      end
      if (data_valid &&!valid_flags[0]) begin
        shift_reg[0] <= {shift_reg[0], data_in};
        valid_flags[0] <= 1'b1;
      end

      data_out_valid <= &valid_flags;

      if (&valid_flags == 4'b1111) begin
        shift_out <= shift_reg[3];
      end
    end
  end

  assign o_data_out = shift_out;
  assign o_data_out_valid = data_out_valid;

endmodule