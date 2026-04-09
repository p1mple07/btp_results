module gf_multiplier(
  // Clock and Reset
  input wire clk,
  input wire rst,

  // Input Ports
  input wire [3:0] A,
  input wire [3:0] B,

  // Output Ports
  output reg [3:0] result
);

  // Internal Registers
  reg [3:0] multiplicand;
  reg [3:0] intermediate_result;
  reg [3:0] temp_result;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      multiplicand <= 4'b0000;
      intermediate_result <= 4'b0000;
      result <= 4'b0000;
    end else begin
      // Perform polynomial reduction
      temp_result = intermediate_result ^ multiplicand;

      // Check if the MSB of the multiplicand is 1 after shifting
      if (multiplicand[3])
        temp_result = temp_result ^ 5'b10011;

      intermediate_result <= multiplicand;
      multiplicand <= temp_result;

      // Shift the multiplicand to the left by 1 bit
      multiplicand = {multiplicand[2], multiplicand[1], multiplicand[0]};

      if (B == 4'b0000) begin
        // Stop when all bits of B are processed
        result <= intermediate_result;
      end else begin
        // Process the next bit of B
        result <= intermediate_result ^ B[0];

        // Shift the intermediate result to the left by 1 bit
        intermediate_result = {intermediate_result[2], intermediate_result[1], intermediate_result[0]};

        // Perform polynomial reduction if the MSB of the intermediate result is 1
        if (intermediate_result[3])
          intermediate_result = intermediate_result ^ 5'b10011;
      end
    end
  end

endmodule