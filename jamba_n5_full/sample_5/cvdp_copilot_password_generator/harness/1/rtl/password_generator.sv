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

  always_ff @(posedge clk or reset) begin
    if (reset) begin
      counter <= 0;
      for (i = 0; i < WIDTH; i++)
        char_array[i] = 8'h00;
    end else begin
      counter = counter + 1;
      i = (i + 1) mod WIDTH;

      char_type = rand() % 4;

      case (char_type)
        // lowercase
        ((counter + char_array[(i+1)%WIDTH]) % 26) + 97'h
        // uppercase
        ((counter + i) % 26) + 65'h
        // special
        ((counter + char_array[(i+WIDTH-1)%WIDTH]) % 14) + 33'h
        // numeric
        ((counter + i) % 10) + 48'h
      endcase

      password[i] = reg2logic(password[i]);
    end
  end

endmodule
