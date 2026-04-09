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

  // Counter Logic for pseudo-random generation
  always_ff @(posedge clk) begin
    if (reset) begin
      counter <= 8'd0;
      for (i = 0; i < WIDTH; i = i + 1) begin
        char_array[i] <= 8'd0;
      end
    end else begin
      counter <= counter + 1;
    end
  end

  // Generate password characters
  always_comb begin
    char_type = counter[7:6];
    if (char_type == 2'b00) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        char_array[i] <= (counter + i + 1) % 26;
        char_array[i] = char_array[i] + 8'd97;
      end
    end else if (char_type == 2'b01) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        char_array[i] <= (counter + i) % 26;
        char_array[i] = char_array[i] + 8'd65;
      end
    end else if (char_type == 2'b10) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        char_array[i] <= (counter + (WIDTH-1-i)) % 14;
        char_array[i] = char_array[i] + 8'd33;
      end
    end else if (char_type == 2'b11) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        char_array[i] <= (counter + i) % 10;
        char_array[i] = char_array[i] + 8'd48;
      end
    end
  end

  // Combine Password
  assign password = {char_array[WIDTH-1], char_array[WIDTH-2], char_array[WIDTH-3], char_array[WIDTH-4]};

endmodule
