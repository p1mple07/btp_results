module morse_encoder (
    input wire [7:0] ascii_in,
    output reg [5:0] morse_out,
    output reg [3:0] morse_length
);

    always @(*) begin
        case (ascii_in)
            8'h41: begin
                morse_out = 6'b100;   morse_length = 2'b10;
            end
            8'h42: begin
                morse_out = 6'b1000;  morse_length = 2'b10;
            end
            8'h43: begin
                morse_out = 6'b1010;  morse_length = 2'b10;
            end
            8'h44: begin
                morse_out = 6'b100;   morse_length = 2'b10;
            end
            8'h45: begin
                morse_out = 6'b1;     morse_length = 3'b10;
            end
            8'h46: begin
                morse_out = 6'b0010;  morse_length = 2'b10;
            end
            8'h47: begin
                morse_out = 6'b110;   morse_length = 2'b10;
            end
            8'h48: begin
                morse_out = 6'b0000;  morse_length = 2'b10;
            end
            8'h49: begin
                morse_out = 6'b00;    morse_length = 2'b10;
            end
            8'h30: begin
                morse_out = 6'b11111; morse_length = 5'b100;
            end
            8'h31: begin
                morse_out = 6'b01111; morse_length = 5'b100;
            end
            8'h32: begin
                morse_out = 6'b00111; morse_length = 5'b100;
            end
            8'h33: begin
                morse_out = 6'b00011; morse_length = 5'b100;
            end
            8'h34: begin
                morse_out = 6'b00001; morse_length = 5'b100;
            end
            8'h35: begin
                morse_out = 6'b00000; morse_length = 5'b100;
            end
            8'h36: begin
                morse_out = 6'b10000; morse_length = 5'b100;
            end
            8'h37: begin
                morse_out = 6'b11000; morse_length = 5'b100;
            end
            8'h38: begin
                morse_out = 6'b11100; morse_length = 5'b100;
            end
            8'h39: begin
                morse_out = 6'b11110; morse_length = 5'b100;
            end
            default:
                morse_out = 6'b0;   morse_length = 4'b0;
        endcase
    end

endmodule
