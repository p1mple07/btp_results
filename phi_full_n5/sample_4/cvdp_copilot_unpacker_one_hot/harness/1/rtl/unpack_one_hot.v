module unpack_one_hot(
    input signed [255:0] source_reg,
    input [1:0] one_hot_selector,
    input signed [1:0] sign,
    input [1:0] size,
    output reg signed [511:0] destination_reg
);

integer i;

always @(source_reg, one_hot_selector, sign, size) begin
    destination_reg = {511{1'b0}}; // Initialize destination register to zeros

    if (one_hot_selector == 3'b001) begin
        for (i = 0; i < 256; i += 1) begin
            destination_reg[(i*8)+7:i*8] = {source_reg[i], sign};
        end
    end else if (one_hot_selector == 3'b010) begin
        for (i = 0; i < 256; i += 2) begin
            destination_reg[(i*8)+7:i*8] = {source_reg[i], source_reg[i+1], sign};
        end
    end else if (one_hot_selector == 3'b100) begin
        if (size == 1) begin
            for (i = 0; i < 32; i += 8) begin
                destination_reg[(i*16)+15:i*16] = {source_reg[i], source_reg[i+8], sign};
            end
        end else if (size == 0) begin
            for (i = 0; i < 64; i += 4) begin
                destination_reg[(i*8)+7:i*8] = {source_reg[i], source_reg[i+4], sign};
            end
        end else begin
            destination_reg = source_reg; // Default case, directly assign source_reg to destination_reg
        end
    end
end

endmodule
