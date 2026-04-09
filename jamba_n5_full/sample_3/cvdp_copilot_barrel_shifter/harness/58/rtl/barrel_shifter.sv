module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,               
    input left_right,              
    input [data_width-1:0] mask,   
    output reg [data_width-1:0] data_out,
    output reg error                
);

always @(*) begin
    if (shift_bits >= data_width) begin
        error = 1;
        data_out = 0;
        return;
    end
end

always @(*) begin
    case (mode)
        3'b000: begin
            if (left_right)
                data_out = data_in << shift_bits;  
            else
                data_out = data_in >> shift_bits; 
        end
        3'b001: begin
            if (left_right) 
                data_out = data_in << shift_bits; 
            else
                data_out = $signed(data_in) >>> shift_bits; 
        end
        3'b010: begin
            if (left_right)
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); 
            else
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));  
        end
        3'b011: begin
            if (left_right)
                data_out = (data_in << shift_bits) & mask;  
            else
                data_out = (data_in >> shift_bits) & mask; 
        end
        3'b100: begin
            if (left_right)
                data_out = (data_in << shift_bits) ^ mask; 
            else
                data_out = (data_in >> shift_bits) ^ mask; 
        end
        3'b101: begin
            if (data_in != 0) begin
                data_out = (~data_in[31]) ? 1 : 0;
            end else
                data_out = 0;
            data_out = (data_in[data_width-1:0] > 0) ? 1 : 0;
        end
        3'b110: begin
            if (left_right)
                data_out = (data_in + shift_bits) % data_width;
            else
                data_out = (data_in - shift_bits) % data_width;
        end
        3'b111: begin
            data_out = {data_width{1'b0}};
            error = 1;
        end
    endcase
end

endmodule
