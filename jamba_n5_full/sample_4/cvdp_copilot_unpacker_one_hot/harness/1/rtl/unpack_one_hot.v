module unpack_one_hot (
    input        wire [255:0] source_reg,
    input        bit          sign,
    input        bit [2:0]  size,
    input        bit[2:0]  one_hot_selector,
    output reg    [511:0]  destination_reg
);

    // Internal signals
    reg [9:0] temp;
    reg [511:0] dest;

    always @(*) begin
        case (one_hot_selector)
            3'b001: begin
                // 1-bit segments: each 1-bit to 8-bit
                for (int i = 0; i < 256; i++) begin
                    temp = source_reg[i];
                    // convert to 8-bit and assign to destination_reg
                    dest[8*i + 7 : 8*i] = temp;
                end
            end
            3'b010: begin
                // 2-bit segments: each 2-bit to 8-bit
                for (int i = 0; i < 256; i++) begin
                    temp = source_reg[i+1];
                    dest[8*i + 7 : 8*i] = temp;
                end
            end
            3'b100: begin
                if (size == 1) begin
                    // size 1: 8-bit segment to 16-bit
                    for (int i = 0; i < 256; i += 8) begin
                        temp = source_reg[i+7:i];
                        dest[8*i : 8*i + 15] = temp;
                    end
                } else begin
                    // size 0: 4-bit segment to 8-bit
                    for (int i = 0; i < 256; i += 4) begin
                        temp = source_reg[i+3:i];
                        dest[8*i : 8*i + 7] = temp;
                    end
                end
            end
            default: begin
                // Default case: direct assignment
                for (int i = 0; i < 256; i++) begin
                    dest[i] = source_reg[i];
                end
            end
        endcase
    end

    destination_reg = dest;

endmodule
