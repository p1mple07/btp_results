module password_generator #(
    parameter WIDTH = 4  
) (
    input  logic         clk,
    input  logic         reset,
    output logic [(WIDTH*8)-1:0] password
);

  // Internal storage for each character
  logic [7:0] char_array[WIDTH-1:0];
  logic [7:0] counter;
  logic [1:0] char_type; 

  int i;

  // Sequential block: asynchronous reset, counter increment, char_type cycling,
  // and generation of each password character based on the selected category.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      counter      <= 8'd0;
      char_type    <= 2'b00;
      for (i = 0; i < WIDTH; i = i + 1)
        char_array[i] <= 8'd0;
    end
    else begin
      // Increment the counter on each clock cycle
      counter <= counter + 1;

      // Cycle through character categories: 00 -> 01 -> 10 -> 11 -> back to 00
      char_type <= (char_type == 2'b11) ? 2'b00 : char_type + 1;

      // Generate each character based on the selected category.
      // Note: The formulas use the old values of char_array (due to concurrent update)
      // to break the cyclic dependency.
      for (i = 0; i < WIDTH; i = i + 1) begin
        case (char_type)
          2'b00: begin
            // Lowercase letters: a-z (ASCII 97-122)
            char_array[i] <= ((counter + char_array[(i+1)%WIDTH]) % 26) + 8'd97;
          end
          2'b01: begin
            // Uppercase letters: A-Z (ASCII 65-90)
            char_array[i] <= ((counter + i) % 26) + 8'd65;
          end
          2'b10: begin
            // Special characters: ! to / (ASCII 33-46)
            char_array[i] <= ((counter + char_array[(i+WIDTH-1)%WIDTH]) % 14) + 8'd33;
          end
          2'b11: begin
            // Numeric digits: 0-9 (ASCII 48-57)
            char_array[i] <= ((counter + i) % 10) + 8'd48;
          end
        endcase
      end
    end
  end

  // Pack the char_array into the output password signal.
  // The concatenation order places char_array[0] as the MSB, followed by char_array[1], etc.
  assign password = {char_array};

endmodule