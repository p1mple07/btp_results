module unpack_one_hot(
    input signed [255:0] source_reg,
    input [1:0] one_hot_selector,
    input sign,
    input [1:0] size,
    output reg signed [511:0] destination_reg
);

    integer i;

    always @(source_reg or one_hot_selector or sign or size) begin
        destination_reg = {512'b0};

        case(one_hot_selector)
            3'b001: begin
                for (i = 0; i < 256; i = i + 1) begin
                    destination_reg[i*8 +: 8] = {source_reg[i], sign};
                end
            end
            3'b010: begin
                for (i = 0; i < 256; i += 2) begin
                    destination_reg[i*8 +: 8] = {source_reg[i], source_reg[i+1], sign};
                end
            end
            3'b100: begin
                case(size)
                    2'b1: begin
                        for (i = 0; i < 128; i += 8) begin
                            destination_reg[(i+512'b0)*16 +: 16] = {source_reg[i], source_reg[i+8], sign};
                        end
                    end
                    2'b0: begin
                        for (i = 0; i < 64; i += 4) begin
                            destination_reg[(i+512'b0)*8 +: 8] = {source_reg[i], source_reg[i+4], sign};
                        end
                    end
                endcase
            end
            default: begin
                destination_reg = source_reg;
            end
        end
    end
endmodule
