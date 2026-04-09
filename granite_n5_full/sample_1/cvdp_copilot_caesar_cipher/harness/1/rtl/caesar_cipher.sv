module caesar_cipher(
    input [7:0] input_char, // 8-bit ASCII character
    input [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit output character
);

// Function to get the next character after shifting the input_char by key
function automatic reg [7:0] next_char;
    input [7:0] input_char;
    input [3:0] key;
    
    begin
        if (input_char >= 'A' && input_char <= 'Z')
            next_char = (input_char + key - 'A') % 26 + 'A';
        else if (input_char >= 'a' && input_char <= 'z')
            next_char = (input_char + key - 'a') % 26 + 'a';
        else
            next_char = input_char;
    end
endfunction

always @* begin
    if (input_char >= 'A' && input_char <= 'Z')
        output_char = {input_char[6:0], next_char(input_char[7])};
    else if (input_char >= 'a' && input_char <= 'z')
        output_char = {input_char[6:0], next_char(input_char[7])};
    else
        output_char = input_char;
end

endmodule