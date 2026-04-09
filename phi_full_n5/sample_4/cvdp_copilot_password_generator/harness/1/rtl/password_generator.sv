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
      char_type <= 2'b00;
    end else begin
      counter <= counter + 1;
      char_type <= (counter MOD 4) + 2'b00;
    end
  end

  // Generate password characters
  always_comb begin
    for (i = 0; i < WIDTH; i = i + 1) begin
      case (char_type)
        2'b00: char_array[i] = ((counter + char_array[(i+1)%WIDTH]) % 26) + 8'd97;
        2'b01: char_array[i] = ((counter + i) % 26) + 8'd65;
        2'b10: char_array[i] = ((counter + char_array[(i+WIDTH-1)%WIDTH]) % 14) + 8'd33;
        2'b11: char_array[i] = ((counter + i) % 10) + 8'd48;
      endcase
    end
  end

  // Pack the char_array into the password signal
  assign password = {(WIDTH-1:0){char_array}};

endmodule
