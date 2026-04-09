module password_generator #(
    parameter WIDTH = 4
) (
    input logic clk,
    input logic reset,
    output logic [(WIDTH*8)-1:0] password 
);

  localparam num_chars = 8;
  reg [7:0] counter;
  reg [7:0] char_array[WIDTH-1:0];
  logic [1:0] char_type;
  integer i;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      counter <= 0;
      for (i = 0; i < WIDTH; i++) char_array[i] <= 8'b0;
    end else begin
      counter <= counter + 1;
      case (char_type)
        2'b00: // lowercase
          char_array[i] = ((counter + char_array[(i+1)%WIDTH]) % 26) + 8'd97;
          password[i] = char_array[i][7:0];
        $else if (char_type == 2'b01): // uppercase
          char_array[i] = ((counter + i) % 26) + 8'd65;
          password[i] = char_array[i][7:0];
        $else if (char_type == 2'b10): // special
          char_array[i] = ((counter + char_array[(i+WIDTH-1)%WIDTH]) % 14) + 8'd33;
          password[i] = char_array[i][7:0];
        $else if (char_type == 2'b11): // numeric
          char_array[i] = ((counter + i) % 10) + 8'd48;
          password[i] = char_array[i][7:0];
      endcase
    end
  end

endmodule
