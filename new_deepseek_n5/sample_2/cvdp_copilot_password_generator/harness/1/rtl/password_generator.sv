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

  integer i;

  always@(posedge clk or posedge reset) begin
    if (reset) begin
      counter = 0;
      char_array = {WIDTH{0}}; // Initialize all zeros
    end else
      counter = (counter + 1) % 256;
      
      for (i = 0; i < WIDTH; i = i + 1) begin
        case (char_type)
          0b00: char_array[i] = ((counter + char_array[(i+1)%WIDTH]) % 26) + 8'h97;
          0b01: char_array[i] = ((counter + i) % 26) + 8'h65;
          0b10: char_array[i] = ((counter + char_array[(i+WIDTH-1)%WIDTH]) % 14) + 8'h33;
          0b11: char_array[i] = ((counter + i) % 10) + 8'h48;
        endcase
      end
  end

  // Pack char_array into password
  integer j;
  for (j = 0; j < WIDTH; j = j + 1) begin
    password[(j*8)+7] = char_array[j] & 8'h0F;
    password[(j*8)+6] = (char_array[j] >> 4) & 8'h0F;
    password[(j*8)+5] = (char_array[j] >> 8) & 8'h0F;
    password[(j*8)+4] = (char_array[j] >> 12) & 8'h0F;
    password[(j*8)+3] = (char_array[j] >> 16) & 8'h0F;
    password[(j*8)+2] = (char_array[j] >> 20) & 8'h0F;
    password[(j*8)+1] = (char_array[j] >> 24) & 8'h0F;
    password[(j*8)+0] = char_array[j] & 8'h0F;
  end
endmodule