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

  initial begin
    char_array[0:WIDTH-1] = 0;
  end

  always @(posedge clk) begin
    if (reset) begin
      counter <= 0;
      password <= "0" * WIDTH;
    end else begin
      counter = counter + 1;
      for (i = 0; i < WIDTH; i = i + 1) begin
        char_type = $urandom_range(0, 3);
        case (char_type)
          0: begin
            password[i] = ((counter + char_array[(i+1)%WIDTH]) % 26) + 8'd97;
          end
          1: begin
            password[i] = ((counter + i) % 26) + 8'd65;
          end
          2: begin
            password[i] = ((counter + char_array[(i+WIDTH-1)%WIDTH]) % 14) + 8'd33;
          end
          3: begin
            password[i] = ((counter + i) % 10) + 8'd48;
          end
        endcase
      end
    end
  end

endmodule
