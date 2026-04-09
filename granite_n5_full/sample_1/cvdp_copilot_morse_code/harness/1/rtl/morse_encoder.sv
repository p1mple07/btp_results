module morse_encoder(
    input logic [7:0] ascii_in,
    output logic [9:0] morse_out,
    output logic [3:0] morse_length
);

// Define Morse code lookup table
logic [7:0][9:0] morse_code;

initial begin
    // Populate Morse code lookup table
    morse_code['A'] = "101";
    morse_code['B'] = "1000";
    morse_code['C'] = "1010";
    morse_code['D'] = "100";
    morse_code['E'] = "10";
    morse_code['F'] = "1000";
    morse_code['G'] = "110";
    morse_code['H'] = "1000";
    morse_code['I'] = "10";
    morse_code['J'] = "1011";
    morse_code['K'] = "101";
    morse_code['L'] = "1000";
    morse_code['M'] = "110";
    morse_code['N'] = "10";
    morse_code['O'] = "111";
    morse_code['P'] = "1011";
    morse_code['Q'] = "1101";
    morse_code['R'] = "100";
    morse_code['S'] = "1000";
    morse_code['T'] = "10";
    morse_code['U'] = "1001";
    morse_code['V'] = "10001";
    morse_code['W'] = "1011";
    morse_code['X'] = "1001";
    morse_code['Y'] = "1011";
    morse_code['Z'] = "1100";
    morse_code['0'] = "11111";
    morse_code['1'] = "01111";
    morse_code['2'] = "00111";
    morse_code['3'] = "00011";
    morse_code['4'] = "00001";
    morse_code['5'] = "00000";
    morse_code['6'] = "10000";
    morse_code['7'] = "11000";
    morse_code['8'] = "11100";
    morse_code['9'] = "11110";
end

// Morse encoding logic
always @(*) begin
    // Convert ASCII input to Morse Code
    if (ascii_in[7:0]) begin
        morse_out <= morse_code[ascii_in];
        morse_length <= $bits(morse_code[ascii_in]);
    end else begin
        morse_out <= {24{1'b0}};
        morse_length <= 24;
    end
end