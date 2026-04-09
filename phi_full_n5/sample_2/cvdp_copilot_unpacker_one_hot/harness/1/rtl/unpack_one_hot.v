module unpack_one_hot(
    input signed [255:0] source_reg,
    input [1:0] one_hot_selector,
    input sign,
    input [1:0] size,
    output reg signed [511:0] destination_reg
);

    // Integer variable to iterate through the source_reg
    integer i;

    // Default initialization
    initial begin
        destination_reg = 0;
    end

    // Loop operation based on one_hot_selector
    always @ (source_reg, one_hot_selector, sign, size) begin
        if (one_hot_selector == 3'b001) begin
            for (i = 0; i < 256; i += 1) begin
                destination_reg[i] = source_reg[i] & (sign ? '1 : '0);
            end
        end else if (one_hot_selector == 3'b010) begin
            for (i = 0; i < 256; i += 2) begin
                destination_reg[i + 87] = (source_reg[i] << 6) | source_reg[i + 1];
                destination_reg[i + 88] = source_reg[i + 1] & (sign ? '1 : '0);
            end
        end else if (one_hot_selector == 3'b100) begin
            case (size)
                2'b0: for (i = 0; i < 128; i += 4) begin
                    destination_reg[i + 511] = (source_reg[i] << 8) | source_reg[i + 1];
                    destination_reg[i + 512] = source_reg[i + 2] & (sign ? '1 : '0);
                    destination_reg[i + 513] = source_reg[i + 3] & (sign ? '1 : '0);
                    destination_reg[i + 514] = source_reg[i + 4] & (sign ? '1 : '0);
                end
                2'b1: for (i = 0; i < 64; i += 8) begin
                    destination_reg[i + 511] = source_reg[i] << 8;
                    destination_reg[i + 512] = source_reg[i + 1] << 8;
                    destination_reg[i + 513] = source_reg[i + 2] << 8;
                    destination_reg[i + 514] = source_reg[i + 3] << 8;
                    destination_reg[i + 515] = source_reg[i + 4] << 8;
                    destination_reg[i + 516] = source_reg[i + 5] << 8;
                    destination_reg[i + 517] = source_reg[i + 6] << 8;
                    destination_reg[i + 518] = source_reg[i + 7] << 8;
                    destination_reg[i + 519] = source_reg[i + 8] << 8;
                end
            end
        end
    end

endmodule
