module unpack_one_hot(
    input signed [255:0] source_reg,
    input [1:0] one_hot_selector,
    input sign,
    input [1:0] size,
    output reg signed [511:0] destination_reg
);

    integer i;

    always @(source_reg or one_hot_selector or sign or size) begin
        destination_reg = 0; // Default initialization

        case (one_hot_selector)
            3'b001:
                for (i = 0; i < 256; i += 1) begin
                    destination_reg[i*8 +: 8] = {source_reg[i], sign};
                end
                // No size control needed for 1-bit granularity
                break;
            3'b010:
                for (i = 0; i < 256; i += 2) begin
                    destination_reg[i*8 +: 8] = {source_reg[i], source_reg[i+1], sign};
                end
                // No size control needed for 2-bit granularity
                break;
            3'b100:
                case (size)
                    1'b1:
                        for (i = 0; i < 256; i += 8) begin
                            destination_reg[i*16 +: 16] = {source_reg[i], source_reg[i+8], sign};
                        end
                        // No size control needed for 8-bit segments with size 1
                        break;
                    1'b0:
                        for (i = 0; i < 256; i += 4) begin
                            destination_reg[i*8 +: 8] = {source_reg[i], source_reg[i+4], sign};
                        end
                        // No size control needed for 4-bit segments with size 0
                        break;
                end
                // Default case, no unpacking
                default:
                    destination_reg = source_reg;
        endcase
    end

endmodule
