module caesar_cipher (input_char, key, output_char);
    parameter BITWIDTH = 8;
    parameter BITWIDTH_KEY = 4;

    logic [BITWIDTH-1:0] input_char, key;
    logic [BITWIDTH-1:0] output_char;

    // Helper function to determine if a character is uppercase
    function bool is_uppercase(logic [7:0] char);
        return (char >= 'A') && (char <= 'Z');
    endfunction

    // Helper function to determine if a character is lowercase
    function bool is_lowercase(logic [7:0] char);
        return (char >= 'a') && (char <= 'z');
    endfunction

    // Helper function to convert an ASCII character to its numeric value
    function logic [7:0] char_to_num(logic [7:0] char);
        return (char - '0');
    endfunction

    // Helper function to convert a numeric value to its ASCII character
    function logic [7:0] num_to_char(logic [7:0] num);
        return (num + '0');
    endfunction

    // Helper function to perform modulo operation
    function logic [7:0] modulo_26(logic [7:0] val);
        return (val % 26);
    endfunction

    // Helper function to perform character shifting
    function logic [7:0] shift_char(logic [7:0] char, logic [7:0] key);
        logic [7:0] shifted_val;
        if (is_uppercase(char)) {
            shifted_val = char_to_num(char) + key;
            shifted_val = modulo_26(shifted_val);
            output_char = num_to_char(shifted_val);
        } else if (is_lowercase(char)) {
            shifted_val = char_to_num(char) + key;
            shifted_val = modulo_26(shifted_val);
            output_char = num_to_char(shifted_val);
        } else {
            output_char = char;
        }
        return output_char;
    endfunction

    // Combinational logic for the caesar_cipher module
    assign output_char = shift_char(input_char, key);

endmodule
 module caesar_cipher (input_char, key, output_char);
    parameter BITWIDTH = 8;
    parameter BITWIDTH_KEY = 4;

    logic [BITWIDTH-1:0] input_char, key;
    logic [BITWIDTH-1:0] output_char;

    // Helper functions
    function bool is_uppercase(logic [7:0] char);
        return (char >= 'A') && (char <= 'Z');
    endfunction

    function bool is_lowercase(logic [7:0] char);
        return (char >= 'a') && (char <= 'z');
    endfunction

    function logic [7:0] char_to_num(logic [7:0] char);
        return (char - '0');
    endfunction

    function logic [7:0] num_to_char(logic [7:0] num);
        return (num + '0');
    endfunction

    function logic [7:0] modulo_26(logic [7:0] val);
        return (val % 26);
    endfunction

    function logic [7:0] shift_char(logic [7:0] char, logic [7:0] key);
        logic [7:0] shifted_val;
        if (is_uppercase(char)) {
            shifted_val = char_to_num(char) + key;
            shifted_val = modulo_26(shifted_val);
            output_char = num_to_char(shifted_val);
        } else if (is_lowercase(char)) {
            shifted_val = char_to_num(char) + key;
            shifted_val = modulo_26(shifted_val);
            output_char = num_to_char(shifted_val);
        } else {
            output_char = char;
        }
        return output_char;
    endfunction

    // Combinational logic for the caesar_cipher module
    assign output_char = shift_char(input_char, key);

endmodule

// Save this content to the file: rtl/caesar_cipher.sv module caesar_cipher (input_char, key, output_char);
    parameter BITWIDTH = 8;
    parameter BITWIDTH_KEY = 4;

    logic [BITWIDTH-1:0] input_char, key;
    logic [BITWIDTH-1:0] output_char;

    // Helper functions
    function bool is_uppercase(logic [7:0] char);
        return (char >= 'A') && (char <= 'Z');
    endfunction

    function bool is_lowercase(logic [7:0] char);
        return (char >= 'a') && (char <= 'z');
    endfunction

    function logic [7:0] char_to_num(logic [7:0] char);
        return (char - '0');
    endfunction

    function logic [7:0] num_to_char(logic [7:0] num);
        return (num + '0');
    endfunction

    function logic [7:0] modulo_26(logic [7:0] val);
        return (val % 26);
    endfunction

    function logic [7:0] shift_char(logic [7:0] char, logic [3:0] key);
        logic [7:0] shifted_val;
        if (is_uppercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else if (is_lowercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else {
            shifted_val = char;
        }
        return shifted_val;
    endfunction

    // Combinational logic for the caesar_cipher module
    assign output_char = shift_char(input_char, key);

endmodule

// Save this content to the file: rtl/caesar_cipher.sv
 module caesar_cipher (input_char, key, output_char);
    parameter BITWIDTH = 8;
    parameter BITWIDTH_KEY = 4;

    logic [BITWIDTH-1:0] input_char, key;
    logic [BITWIDTH-1:0] output_char;

    // Helper functions
    function bool is_uppercase(logic [7:0] char);
        return (char >= 'A') && (char <= 'Z');
    endfunction

    function bool is_lowercase(logic [7:0] char);
        return (char >= 'a') && (char <= 'z');
    endfunction

    function logic [7:0] char_to_num(logic [7:0] char);
        return (char - '0');
    endfunction

    function logic [7:0] num_to_char(logic [7:0] num);
        return (num + '0');
    endfunction

    function logic [7:0] modulo_26(logic [7:0] val);
        return (val % 26);
    endfunction

    function logic [7:0] shift_char(logic [7:0] char, logic [3:0] key);
        logic [7:0] shifted_val;
        if (is_uppercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else if (is_lowercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else {
            shifted_val = char;
        }
        return shifted_val;
    endfunction

    // Combinational logic for the caesar_cipher module
    assign output_char = shift_char(input_char, key);

endmodule

// Save this content to the file: rtl/caesar_cipher.sv
 module caesar_cipher (input_char, key, output_char);
    parameter BITWIDTH = 8;
    parameter BITWIDTH_KEY = 4;

    logic [BITWIDTH-1:0] input_char, key;
    logic [BITWIDTH-1:0] output_char;

    // Helper functions
    function bool is_uppercase(logic [7:0] char);
        return (char >= 'A') && (char <= 'Z');
    endfunction

    function bool is_lowercase(logic [7:0] char);
        return (char >= 'a') && (char <= 'z');
    endfunction

    function logic [7:0] char_to_num(logic [7:0] char);
        return (char - '0');
    endfunction

    function logic [7:0] num_to_char(logic [7:0] num);
        return (num + '0');
    endfunction

    function logic [7:0] modulo_26(logic [7:0] val);
        return (val % 26);
    endfunction

    function logic [7:0] shift_char(logic [7:0] char, logic [3:0] key);
        logic [7:0] shifted_val;
        if (is_uppercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else if (is_lowercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else {
            shifted_val = char;
        }
        return shifted_val;
    endfunction

    // Combinational logic for the caesar_cipher module
    assign output_char = shift_char(input_char, key);

endmodule

// Save this content to the file: rtl/caesar_cipher.sv
 module caesar_cipher (input_char, key, output_char);
    parameter BITWIDTH = 8;
    parameter BITWIDTH_KEY = 4;

    logic [BITWIDTH-1:0] input_char, key;
    logic [BITWIDTH-1:0] output_char;

    // Helper functions
    function bool is_uppercase(logic [7:0] char);
        return (char >= 'A') && (char <= 'Z');
    endfunction

    function bool is_lowercase(logic [7:0] char);
        return (char >= 'a') && (char <= 'z');
    endfunction

    function logic [7:0] char_to_num(logic [7:0] char);
        return (char - '0');
    endfunction

    function logic [7:0] num_to_char(logic [7:0] num);
        return (num + '0');
    endfunction

    function logic [7:0] modulo_26(logic [7:0] val);
        return (val % 26);
    endfunction

    function logic [7:0] shift_char(logic [7:0] char, logic [3:0] key);
        logic [7:0] shifted_val;
        if (is_uppercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else if (is_lowercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else {
            shifted_val = char;
        }
        return shifted_val;
    endfunction

    // Combinational logic for the caesar_cipher module
    assign output_char = shift_char(input_char, key);

endmodule

// Save this content to the file: rtl/caesar_cipher.sv
 module caesar_cipher (input_char, key, output_char);
    parameter BITWIDTH = 8;
    parameter BITWIDTH_KEY = 4;

    logic [BITWIDTH-1:0] input_char, key;
    logic [BITWIDTH-1:0] output_char;

    // Helper functions
    function bool is_uppercase(logic [7:0] char);
        return (char >= 'A') && (char <= 'Z');
    endfunction

    function bool is_lowercase(logic [7:0] char);
        return (char >= 'a') && (char <= 'z');
    endfunction

    function logic [7:0] char_to_num(logic [7:0] char);
        return (char - '0');
    endfunction

    function logic [7:0] num_to_char(logic [7:0] num);
        return (num + '0');
    endfunction

    function logic [7:0] modulo_26(logic [7:0] val);
        return (val % 26);
    endfunction

    function logic [7:0] shift_char(logic [7:0] char, logic [3:0] key);
        logic [7:0] shifted_val;
        if (is_uppercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else if (is_lowercase(char)) {
            shifted_val = (char_to_num(char) + key) % 26;
            shifted_val = num_to_char(shifted_val);
        } else {
            shifted_val = char;
        }
        return shifted_val;
    endfunction

    // Combinational logic for the caesar_cipher module
    assign output_char = shift_char(input_char, key);

endmodule