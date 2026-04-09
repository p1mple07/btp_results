module password_generator #(
    parameter WIDTH = 4  
) (
    input  logic         clk,
    input  logic         reset,
    output logic [(WIDTH*8)-1:0] password 
);

  // Internal storage for each character of the password
  logic [7:0] char_array[WIDTH-1:0];  
  // 8-bit counter used for pseudo-random generation
  logic [7:0] counter;  
  // 2-bit selector to choose the character category
  logic [1:0] char_type; 

  integer i;

  // Sequential block: update counter and character array on each clock cycle
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      counter         <= 8'd0;
      for(i = 0; i < WIDTH; i = i+1) begin
        char_array[i] <= 8'd0;
      end
      char_type       <= 2'b00;
    end else begin
      // Increment the counter each clock cycle
      counter <= counter + 8'd1;
      // Cycle through character categories using the lower 2 bits of the counter
      char_type <= counter[1:0];
      
      // Update each character based on the selected category
      for(i = 0; i < WIDTH; i = i+1) begin
        case(char_type)
          2'b00: begin
                    // Lowercase letters: a-z (ASCII 97–122)
                    // Use the next character in the array (cyclic) for variability
                    char_array[i] <= ((counter + char_array[(i+1)%WIDTH]) % 26) + 8'd97;
                  end
          2'b01: begin
                    // Uppercase letters: A-Z (ASCII 65–90)
                    // Use the index 'i' for variability
                    char_array[i] <= ((counter + i) % 26) + 8'd65;
                  end
          2'b10: begin
                    // Special characters: ! to / (ASCII 33–46)
                    // Use the previous character in the array (cyclic) for variability
                    char_array[i] <= ((counter + char_array[(i+WIDTH-1)%WIDTH]) % 14) + 8'd33;
                  end
          2'b11: begin
                    // Numeric digits: 0–9 (ASCII 48–57)
                    // Use the index 'i' for variability
                    char_array[i] <= ((counter + i) % 10) + 8'd48;
                  end
          default: char_array[i] <= 8'd0;
        endcase
      end
    end
  end

  // Combinational logic to pack the char_array into the output password signal
  integer j;
  always_comb begin
    for(j = 0; j < WIDTH; j = j+1) begin
      // Assign each 8-bit slice of 'password' from the corresponding element in char_array.
      // For WIDTH=4, this packs char_array[0] into bits [7:0],
      // char_array[1] into bits [15:8], and so on.
      password[(j+1)*8-1 -: 8] = char_array[j];
    end
  end

endmodule