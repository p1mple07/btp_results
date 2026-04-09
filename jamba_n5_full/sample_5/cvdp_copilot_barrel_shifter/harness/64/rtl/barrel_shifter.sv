module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,              // 3'b111 for conditional mode
    input left_right,              
    input [data_width-1:0] mask,   
    input enable,                  
    input enable_parity,           
    output reg [data_width-1:0] data_out,
    output reg parity_out,        
    output reg error,
    output reg condition,           // new input for conditional bit manipulation
    output reg bit_op_type,         // 2'b11 for the three operations
    output reg toggle,
    output reg set,
    output reg clear
);

always @(*) begin
    if (!enable) begin
        data_out = data_out;
        error = 0;
        parity_out = 0;
    end else begin
        error = 0;
        case (mode)
            3'b000: begin
                if (shift_bits >= data_width) begin
                    error = 1;
                    data_out = {data_width{1'b0}};
                end else if (left_right) begin
                    data_out = data_in << shift_bits;
                end else begin
                    data_out = data_in >> shift_bits;
                end
            end
            3'b001: begin
                if (shift_bits >= data_width) begin
                    error = 1;
                    data_out = {data_width{1'b0}};
                end else if (left_right) begin
                    data_out = data_in << shift_bits;
                end else begin
                    data_out = data_in >> shift_bits;
                end
            end
            3'b010: begin 
                if (shift_bits >= data_width) begin
                    error = 1;
                    data_out = {data_width{1'b0}};
                end else if (left_right) begin
                    data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); 
                end else begin
                    data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));  
                end
            end
            3'b011: begin  
                if (shift_bits >= data_width) begin
                    error = 1;
                    data_out = {data_width{1'b0}};
                end else if (left_right) begin
                    data_out = (data_in << shift_bits) & mask;  
                end else begin
                    data_out = (data_in >> shift_bits) & mask;  
                end
            end
            3'b100: begin 
                if (left_right) begin
                    data_out = data_in + shift_bits;  
                end else begin
                    data_out = data_in - shift_bits;  
                end
            end
            3'b101: begin  
                data_out = 0;
                for (int i = data_width-1; i >= 0; i = i - 1) begin
                    if (data_in[i] == 1 && data_out == 0) begin
                        data_out = i;  
                    end
                end
            end
            3'b110: begin 
                if (left_right) begin
                    data_out = (data_in + shift_bits) % data_width; 
                end else begin
                    data_out = (data_in - shift_bits) % data_width; 
                end
            end
            default: begin
                data_out = {data_width{1'b0}};
                error = 1;
            end
        endcase
    end

    if (enable_parity) begin
        parity_out = ^data_out; 
    end else begin
        parity_out = 0;        
    end
end

endmodule
