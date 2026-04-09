module convolutional_encoder (
  input wire clk,
  input wire rst,
  input wire data_in,
  output logic encoded_bit1,
  output logic encoded_bit2
);

  // Define the shift register storage for the previous 2 bits
  logic [1:0] shift_reg;

  // Initialize the shift register with zeros
  assign shift_reg[0] = 1'b0;
  assign shift_reg[1] = 1'b0;

  // Perform the convolutional encoding operation
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset the shift register and the encoded output bits
      shift_reg <= 2'b00;
      encoded_bit1 <= 1'b0;
      encoded_bit2 <= 1'b0;
    end else begin
      // Update the shift register by shifting in the new input data
      shift_reg <= {shift_reg[0], shift_reg[1]};

      // Generate the encoded bits based on the current state of the shift register
      encoded_bit1 <= (data_in & shift_reg[1]) | (shift_reg[0] & shift_reg[1]);
      encoded_bit2 <= (data_in & shift_reg[0]) | (shift_reg[1] & shift_reg[0]);
    end
  end

endmodule