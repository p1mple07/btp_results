module caesar_cipher(
    input wire [7:0] input_char, // 8-bit ASCII character
    input wire [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit shifted output character
);

// Perform bounds checking to ensure input character falls within ASCII range
reg [7:0] char_mod; // 8-bit character after modulo operation
reg [3:0] mod_result; // 4-bit result of modulo operation
wire [7:0] upper_bound = "ZZZZZZZZ"; // 8-bit string representing the last ASCII character
wire [7:0] lower_bound = "qqqqqqqq"; // 8-bit string representing the first ASCII character

// Check if input character is within ASCII range
assign char_mod = input_char[7:0]; // Initialize char_mod with input character
assign mod_result = key & 15; // Extract least significant 4 bits of key
assign char_mod[7:4] = (input_char[7:4] > mod_result)? (input_char[7:4] - mod_result) : (upper_bound[7:4] - (mod_result - input_char[7:4])); // Perform modulo operation
assign char_mod[3:0] = (input_char[3:0] > mod_result)? (input_char[3:0] - mod_result) : (upper_bound[3:0] - (mod_result - input_char[3:0])); // Perform modulo operation
assign char_mod[7:4] = (char_mod[7:4] < lower_bound[7:4])? (lower_bound[7:4] + (lower_bound[7:4] - char_mod[7:4])) : char_mod[7:4]; // Handle wrapping around from Z to q
assign char_mod[3:0] = (char_mod[3:0] < lower_bound[3:0])? (lower_bound[3:0] + (lower_bound[3:0] - char_mod[3:0])) : char_mod[3:0]; // Handle wrapping around from z to q

// Assign output character based on whether input character is within ASCII range or not
assign output_char = (input_char[7:4] == input_char[3:0])? char_mod : input_char; // If input character is within ASCII range, perform shift; otherwise, assign original character

endmodule