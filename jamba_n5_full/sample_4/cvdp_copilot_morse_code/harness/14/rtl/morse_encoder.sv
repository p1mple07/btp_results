module morse_encoder (
    input wire [7:0] ascii_in,
    output reg [5:0] morse_out,
    output reg [3:0] morse_length
);

    always @(*) begin
        case (ascii_in)
            8'h41: begin
                morse_out = 6'b100;
                morse_length = 2;
            end
            8'h42: begin
                morse_out = 6'b1000;
                morse_length = 4;
            end
            8'h43: begin
                morse_out = 6'b1010;
                morse_length = 4;
            end
            8'h44: begin
                morse_out = 6'b100;
                morse_length = 3;
            end
            8'h45: begin
                morse_out = 6'b1;
                morse_length = 3;
            end
            8'h46: begin
                morse_out = 6'b0010;
                morse_length = 4;
            end
            8'h47: begin
                morse_out = 6'b110;
                morse_length = 3;
            end
            8'h48: begin
                morse_out = 6'b0000;
                morse_length = 4;
            end
            8'h49: begin
                morse_out = 6'b00;
                morse_length = 2;
            end
            8'h4A: begin
                morse_out = 6'b0111;
                morse_length = 4;
            end
            8'h4B: begin
                morse_out = 6'b101;
                morse_length = 3;
            end
            8'h4C: begin
                morse_out = 6'b01;
                morse_length = 2;
            end
            8'h4D: begin
                morse_out = 6'b11;
                morse_length = 2;
            end
            8'h4E: begin
                morse_out = 6'b10;
                morse_length = 2;
            end
            8'h4F: begin
                morse_out = 6'b111;
                morse_length = 3;
            end
            8'h50: begin
                morse_out = 6'b0110;
                morse_length = 4;
            end
            8'h51: begin
                morse_out = 6'b1101;
                morse_length = 4;
            end
            8'h52: begin
                morse_out = 6'b010;
                morse_length = 2;
            end
            8'h53: begin
                morse_out = 6'b000;
                morse_length = 3;
            end
            8'h54: begin
                morse_out = 6'b1;
                morse_length = 1;
            end
            8'h55: begin
                morse_out = 6'b001;
                morse_length = 3;
            end
            8'h56: begin
                morse_out = 6'b0001;
                morse_length = 4;
            end
            8'h57: begin
                morse_out = 6'b011;
                morse_length = 3;
            end
            8'h58: begin
                morse_out = 6'b1001;
                morse_length = 4;
            end
            8'h59: begin
                morse_out = 6'b1011;
                morse_length = 4;
            end
            8'h5A: begin
                morse_out = 6'b1100;
                morse_length = 4;
            end
            8'hFF: begin
                morse_out = 6'b0;
                morse_length = 0;
            end
        endcase
    end

endmodule
