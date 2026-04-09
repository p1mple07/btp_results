module morse_encoder (
    input wire [7:0] ascii_in,
    output reg [5:0] morse_out,
    output reg [3:0] morse_length
);

always @(*) begin
    case (ascii_in)
        8'h41: begin morse_out = 6'b0x01; morse_length = 2; end
        8'h42: begin morse_out = 6'b0x08; morse_length = 4; end
        8'h43: begin morse_out = 6'b0x0A; morse_length = 4; end
        8'h44: begin morse_out = 6'b0x04; morse_length = 3; end
        8'h45: begin morse_out = 6'b0x00; morse_length = 1; end
        8'h46: begin morse_out = 6'b0x00; morse_length = 4; end
        8'h47: begin morse_out = 6'b0x07; morse_length = 3; end
        8'h48: begin morse_out = 6'b0x00; morse_length = 4; end
        8'h49: begin morse_out = 6'b0x01; morse_length = 4; end
        8'h4A: begin morse_out = 6'b0x0D; morse_length = 4; end
        8'h4B: begin morse_out = 6'b0x10; morse_length = 3; end
        8'h4C: begin morse_out = 6'b0x01; morse_length = 2; end
        8'h4D: begin morse_out = 6'b0x06; morse_length = 2; end
        8'h4E: begin morse_out = 6'b0x09; morse_length = 3; end
        8'h4F: begin morse_out = 6'b0x02; morse_length = 3; end
        8'h50: begin morse_out = 6'b0x07; morse_length = 4; end
        8'h51: begin morse_out = 6'b0x0D; morse_length = 4; end
        8'h52: begin morse_out = 6'b0x02; morse_length = 3; end
        8'h53: begin morse_out = 6'b0x00; morse_length = 3; end
        8'h54: begin morse_out = 6'b0x01; morse_length = 3; end
        8'h55: begin morse_out = 6'b0x01; morse_length = 3; end
        8'h56: begin morse_out = 6'b0x01; morse_length = 4; end
        8'h57: begin morse_out = 6'b0x09; morse_length = 3; end
        8'h58: begin morse_out = 6'b0x09; morse_length = 4; end
        8'h59: begin morse_out = 6'b0x02; morse_length = 4; end
        8'h30: begin morse_out = 6'b0x1F; morse_length = 5; end
        8'h31: begin morse_out = 6'b0x0F; morse_length = 5; end
        8'h32: begin morse_out = 6'b0x07; morse_length = 5; end
        8'h33: begin morse_out = 6'b0x03; morse_length = 5; end
        8'h34: begin morse_out = 6'b0x01; morse_length = 5; end
        8'h35: begin morse_out = 6'b0x00; morse_length = 5; end
        8'h36: begin morse_out = 6'b0x10; morse_length = 5; end
        8'h37: begin morse_out = 6'b0x18; morse_length = 5; end
        8'h38: begin morse_out = 6'b0x1C; morse_length = 5; end
        8'h39: begin morse_out = 6'b0x1E; morse_length = 5; end
        default:
            morse_out = 6'b0;
            morse_length = 4'b0;
    endcase
end

endmodule
