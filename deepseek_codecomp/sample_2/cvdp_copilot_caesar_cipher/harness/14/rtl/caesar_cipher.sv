module caesar_cipher #(
    parameter PHRASE_WIDTH = 32,   
    parameter PHRASE_LEN = PHRASE_WIDTH / 8  
)(
    input wire [PHRASE_WIDTH-1:0] input_phrase,
    input wire [(PHRASE_LEN * 5) - 1:0] key_phrase,
    output reg [PHRASE_WIDTH-1:0] output_phrase
);

    integer i;
    reg [7:0] current_char;
    reg [4:0] current_key;

    always @(*) begin
    for (i = 0; i < PHRASE_LEN; i = i + 1) begin
        current_char = input_phrase[(PHRASE_LEN - 1 - i) * 8 +: 8];
        current_key = key_phrase[(PHRASE_LEN - 1 - i) * 5 +: 5];

        if (current_char >= "A" && current_char <= "Z") begin
            output_phrase[(PHRASE_LEN - 1 - i) * 8 +: 8] = ((current_char - "A" + current_key) % 26) + "A";
        end
        else if (current_char >= "a" && current_char <= "z") begin
            output_phrase[(PHRASE_LEN - 1 - i) * 8 +: 8] = ((current_char - "a" + current_key) % 26) + "a";
        end
        else begin
            output_phrase[(PHRASE_LEN - 1 - i) * 8 +: 8] = current_char;
        end
    end
end

endmodule