module decoder_8b10b (
    input  logic        clk_in,       // trigger on rising edge
    input  logic        reset_in,     // reset_in, assert HI
    input  logic [9:0]  decoder_in,   // 10-bit input
    output logic [7:0]  decoder_out,  // 8-bit decoded output
    output logic        control_out   // control char, assert HI for control words
);

    // Internal registers
    logic [9:0] s_in_10b_reg;  
    logic [7:0] s_decoder_out; 
    logic       s_control_out;     

    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            s_in_10b_reg   <= 10'b0000000000;
            s_decoder_out  <= 8'b00000000;
            s_control_out  <= 1'b0;
        end else begin
            s_in_10b_reg   <= decoder_in;
            // Default values
            s_decoder_out  <= 8'b00000000;
            s_control_out  <= 1'b0;
            
            // Decode the incoming 10-bit code using valid control symbols
            case (decoder_in)
                // K.28.0
                10'b0011110100: begin
                    s_decoder_out <= 8'b00011100; // 0x1C
                    s_control_out <= 1'b1;
                end
                10'b1100001011: begin
                    s_decoder_out <= 8'b00011100;
                    s_control_out <= 1'b1;
                end
                // K.28.1
                10'b0011111001: begin
                    s_decoder_out <= 8'b00111100; // 0x3C
                    s_control_out <= 1'b1;
                end
                10'b1100000110: begin
                    s_decoder_out <= 8'b00111100;
                    s_control_out <= 1'b1;
                end
                // K.28.2
                10'b0011110101: begin
                    s_decoder_out <= 8'b01011100; // 0x5C
                    s_control_out <= 1'b1;
                end
                10'b1100001010: begin
                    s_decoder_out <= 8'b01011100;
                    s_control_out <= 1'b1;
                end
                // K.28.3
                10'b0011110011: begin
                    s_decoder_out <= 8'b01111100; // 0x7C
                    s_control_out <= 1'b1;
                end
                10'b1100001100: begin
                    s_decoder_out <= 8'b01111100;
                    s_control_out <= 1'b1;
                end
                // K.28.4
                10'b0011110010: begin
                    s_decoder_out <= 8'b10011100; // 0x9C
                    s_control_out <= 1'b1;
                end
                10'b1100001101: begin
                    s_decoder_out <= 8'b10011100;
                    s_control_out <= 1'b1;
                end
                // K.28.5
                10'b0011111010: begin
                    s_decoder_out <= 8'b10111100; // 0xBC
                    s_control_out <= 1'b1;
                end
                10'b1100000101: begin
                    s_decoder_out <= 8'b10111100;
                    s_control_out <= 1'b1;
                end
                // K.28.6
                10'b0011110110: begin
                    s_decoder_out <= 8'b11011100; // 0xDC
                    s_control_out <= 1'b1;
                end
                10'b1100001001: begin
                    s_decoder_out <= 8'b11011100;
                    s_control_out <= 1'b1;
                end
                // K.28.7
                10'b0011111000: begin
                    s_decoder_out <= 8'b11111100; // 0xFC
                    s_control_out <= 1'b1;
                end
                10'b1100000111: begin
                    s_decoder_out <= 8'b11111100;
                    s_control_out <= 1'b1;
                end
                // K.23.7
                10'b1110101000: begin
                    s_decoder_out <= 8'b11110111; // 0xF7
                    s_control_out <= 1'b1;
                end
                10'b0001010111: begin
                    s_decoder_out <= 8'b11110111;
                    s_control_out <= 1'b1;
                end
                // K.27.7
                10'b1101101000: begin
                    s_decoder_out <= 8'b11111011; // 0xFB
                    s_control_out <= 1'b1;
                end
                10'b0010010111: begin
                    s_decoder_out <= 8'b11111011;
                    s_control_out <= 1'b1;
                end
                // K.29.7
                10'b1011101000: begin
                    s_decoder_out <= 8'b11111101; // 0xFD
                    s_control_out <= 1'b1;
                end
                10'b0100010111: begin
                    s_decoder_out <= 8'b11111101;
                    s_control_out <= 1'b1;
                end
                // K.30.7
                10'b0111101000: begin
                    s_decoder_out <= 8'b11111110; // 0xFE
                    s_control_out <= 1'b1;
                end
                10'b1000010111: begin
                    s_decoder_out <= 8'b11111110;
                    s_control_out <= 1'b1;
                end
                // Invalid control symbol: default case
                default: begin
                    s_decoder_out <= 8'b00000000;
                    s_control_out <= 1'b0;
                end
            endcase
        end
    end

    // Output assignments
    assign decoder_out = s_decoder_out;
    assign control_out = s_control_out;

endmodule