module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [1:0] mode,               
    input left_right,              
    input [data_width-1:0] mask,   
    output reg [data_width-1:0] data_out,
    output reg error                
);

always @(*) begin
    error = 0;  
    case (mode)
        2'b00: begin
            if (left_right)
                data_out = data_in << shift_bits;  
            else
                data_out = data_in >> shift_bits; 
        end
        2'b01: begin
            if (left_right) 
                data_out = data_in << shift_bits; 
            else
                data_out = $signed(data_in) >>> shift_bits; 
        end
        2'b10: begin
            if (left_right)
                data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); 
            else
                data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));  
        end
        2'b11: begin
            if (left_right)
                data_out = (data_in << shift_bits) & mask;  
            else
                data_out = (data_in >> shift_bits) & mask; 
        end
        default: begin
            data_out = {data_width{1'b0}}; 
            error = 1; 
        end
    endcase
end

endmodule