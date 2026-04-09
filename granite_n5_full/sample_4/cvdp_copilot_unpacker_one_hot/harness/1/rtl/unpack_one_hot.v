module unpack_one_hot (
    input wire sign,
    input wire size,
    input wire [2:0] one_hot_selector,
    input wire [255:0] source_reg,
    output reg [511:0] destination_reg
);

    always @* begin
        case (one_hot_selector)
            3'b001: begin
                for (int i=0; i<256; i++) begin
                    destination_reg[i*8 +: 8] = {sign? (source_reg[i] >> 7) : source_reg[i],
                                                 sign? ({7{source_reg[i][7]} & source_reg[i]}) : {8{1'b0}}};
                end
            end
            3'b010: begin
                for (int i=0; i<256; i++) begin
                    destination_reg[i*8 +: 8] = {sign? (source_reg[i] >> 6) : source_reg[i],
                                                 sign? ({6{source_reg[i][6]} & source_reg[i]}) : {8{1'b0}}};
                end
            end
            3'b100: begin
                if (size == 1) begin
                    for (int i=0; i<256; i++) begin
                        destination_reg[i*16 +: 16] = {{8{source_reg[i][7]}}, source_reg[i]};
                    end
                end else begin
                    for (int i=0; i<256; i++) begin
                        destination_reg[i*8 +: 8] = {sign? (source_reg[i] >> 4) : source_reg[i],
                                                    sign? ({4{source_reg[i][4]} & source_reg[i]}) : {8{1'b0}}};
                    end
                end
            end
            default: destination_reg <= source_reg;
        endcase
    end

endmodule