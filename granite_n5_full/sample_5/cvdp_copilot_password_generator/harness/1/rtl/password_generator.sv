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

  always @(posedge clk) begin
    if (reset == 1'b0) begin
      counter <= 0;
      for (i = 0; i < WIDTH; i++) begin
        char_array[i] <= 0;
      end
    end else begin
      counter <= counter + 1;
      for (i = 0; i < WIDTH; i++) begin
        case (char_type)
          2'b00: char_array[i] <= ((counter + char_array[(i+1)%WIDTH]) % 26) + 8'd97;
          2'b01: char_array[i] <= ((counter + i) % 26) + 8'd65;
          2'b10: char_array[i] <= ((counter + char_array[(i+WIDTH-1)%WIDTH]) % 14) + 8'd33;
          2'b11: char_array[i] <= ((counter + i) % 10) + 8'd48;
          default: ;
        endcase
      end
    end
  end

  assign password = {<<{char_array}};

endmodule