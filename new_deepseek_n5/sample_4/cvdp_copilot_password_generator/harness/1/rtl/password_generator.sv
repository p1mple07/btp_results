module password_generator #(
    parameter WIDTH = 4  
) (
    input logic clk,
    input logic reset,
    output logic [(WIDTH*8)-1:0] password 
);

  logic [7:0] char_array[WIDTH-1:0];  
  logic [7:0] counter;  
  logic [1:0] char_type; 

  int i;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      counter = 0;
      password = 0;
      return;
    end
    // Counter increment with carry
    if (counter == 255) begin
      counter = 0;
      carry = 0;
    else
      carry = 1;
    end
    counter = counter + carry;
  end

  // Generate password characters
  always begin
    for (i = 0; i < WIDTH; i = i + 1) begin
      case (char_type)
        00: // Lowercase letters
          password[(i * 8):7] = ((counter + char_array[(i + 1) % WIDTH]) % 26) + 8'h97;
          break;
        01: // Uppercase letters
          password[(i * 8):7] = ((counter + i) % 26) + 8'h65;
          break;
        10: // Special characters
          password[(i * 8):7] = ((counter + char_array[(i + WIDTH - 1) % WIDTH]) % 14) + 8'h33;
          break;
        11: // Numeric digits
          password[(i * 8):7] = ((counter + i) % 10) + 8'h48;
          break;
        default: 
          password[(i * 8):7] = 0;
          break;
      endcase
    end
  end
  endmodule