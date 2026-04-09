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

  always_comb begin
    if (reset) begin
      counter = 0;
      char_array = {WIDTH{0}}; // Initialize all to 0
    end
  end

  always_edge begin
    if (clk) begin
      counter = counter + 1;
      for (i = 0; i < WIDTH; i = i + 1) begin
        case (char_type)
          00: 
            char_array[i] = ((counter + char_array[(i+1) % WIDTH]) % 26) + 8'd97;
            break;
          01: 
            char_array[i] = ((counter + i) % 26) + 8'd65;
            break;
          10: 
            char_array[i] = ((counter + char_array[(i+WIDTH-1) % WIDTH]) % 14) + 8'd33;
            break;
          11: 
            char_array[i] = ((counter + i) % 10) + 8'd48;
            break;
        end
      end
    end
  end

endmodule