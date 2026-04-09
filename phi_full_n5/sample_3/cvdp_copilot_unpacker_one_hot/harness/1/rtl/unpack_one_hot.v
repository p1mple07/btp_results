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
            3'b001: begin
                for (i = 0; i < 256; i += 1) begin
                    if (sign) begin
                        destination_reg[i*8 +: 8] = {8'bsign_extend(source_reg[i])};
                    end else begin
                        destination_reg[i*8 +: 8] = {8'bzero_extend(source_reg[i])};
                    end
                end
            end
            3'b010: begin
                for (i = 0; i < 256; i += 2) begin
                    if (sign) begin
                        destination_reg[i*8 +: 8] = {8'bsign_extend(source_reg[i +: 2])};
                    end else begin
                        destination_reg[i*8 +: 8] = {8'bzero_extend(source_reg[i +: 2])};
                    end
                end
            end
            3'b100: begin
                case (size)
                    1'b1: begin
                        for (i = 0; i < 256; i += 8) begin
                            if (sign) begin
                                destination_reg[i*16 +: 16] = {16'bsign_extend(source_reg[i +: 8])};
                            end else begin
                                destination_reg[i*16 +: 16] = {16'bzero_extend(source_reg[i +: 8])};
                            end
                        end
                    end
                    1'b0: begin
                        for (i = 0; i < 256; i += 4) begin
                            if (sign) begin
                                destination_reg[i*8 +: 8] = {8'bsign_extend(source_reg[i +: 4])};
                            end else begin
                                destination_reg[i*8 +: 8] = {8'bzero_extend(source_reg[i +: 4])};
                            end
                        end
                    end
                end
            end
        default: destination_reg = source_reg;
        end
    end

endmodule
