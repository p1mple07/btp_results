
module caesar_cipher #(
    parameter PHRASE_WIDTH = 32,  // e.g., enough for 4 chars (4×8=32)
    parameter PHRASE_LEN   = PHRASE_WIDTH / 8
)(
    input  wire [PHRASE_WIDTH-1:0]       input_phrase,
    input  wire [(PHRASE_LEN * 5) - 1:0] key_phrase,
    input  wire                          decrypt,
    output reg  [PHRASE_WIDTH-1:0]       output_phrase
);

    integer i;
    reg [7:0] current_char;
    reg [4:0] current_key;

    always @(*) begin
        // Initialize output to zero
        output_phrase = {PHRASE_WIDTH{1'b0}};

        // Ensure wrap-around for uppercase encryption
        if (decrypt) begin
            for (i = 0; i < PHRASE_LEN; i = i + 1) begin
                current_char = input_phrase[i * 8 +: 8];
                current_key  = key_phrase[i * 5 +: 5];

                // Correct wrap-around for uppercase
                case (current_char)
                    'A': if (current_key > 25) current_char = 'Z';
                         else current_char = current_char + current_key;
                    'B': if (current_key > 25) current_char = 'Z';
                         else current_char = current_char + current_key;
                    'C': if (current_key > 25) current_char = 'Z';
                         else current_char = current_char + current_key;
                    // ... Continue for all uppercase letters
                    _default: current_char = current_char;
                endcase

                output_phrase[i * 8 +: 8] = current_char;
            end
        end
    end

endmodule
