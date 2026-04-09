module unpack_one_hot(
    input wire sign,
    input wire size,
    input wire [2:0] one_hot_selector,
    input wire [255:0] source_reg,
    output reg [511:0] destination_reg
);

always @(*) begin
    case(one_hot_selector)
        3'b001: begin
            integer i;
            for(i=0; i<256; i+=8) begin
                destination_reg[8*i+7:8*i] = sign? {source_reg[i+7], source_reg[i+6], source_reg[i+5], source_reg[i+4], source_reg[i+3], source_reg[i+2], source_reg[i+1], source_reg[i]} : {source_reg[i], source_reg[i+1], source_reg[i+2], source_reg[i+3], source_reg[i+4], source_reg[i+5], source_reg[i+6], source_reg[i+7]};
            end
        end
        3'b010: begin
            integer i;
            for(i=0; i<256; i+=4) begin
                destination_reg[4*i+3:4*i] = sign? {source_reg[i+3], source_reg[i+2], source_reg[i+1], source_reg[i]} : {source_reg[i], source_reg[i+1], source_reg[i+2], source_reg[i+3]};
            end
        end
        3'b100: begin
            if(size == 1) begin
                integer i;
                for(i=0; i<256; i+=2) begin
                    destination_reg[2*i+1:2*i] = sign? {{8{source_reg[i+1]}}, source_reg[i]} : {source_reg[i], {8{source_reg[i+1]}}};
                end
            end else begin
                integer i;
                for(i=0; i<256; i+=4) begin
                    destination_reg[4*i+3:4*i] = sign? {source_reg[i+3], source_reg[i+2], source_reg[i+1], source_reg[i]} : {source_reg[i], source_reg[i+1], source_reg[i+2], source_reg[i+3]};
                end
            end
        end
        default: begin
            for(int i=0; i<256; i++) begin
                destination_reg[i+7:i] = source_reg[i];
            end
        end
    endcase
end

endmodule