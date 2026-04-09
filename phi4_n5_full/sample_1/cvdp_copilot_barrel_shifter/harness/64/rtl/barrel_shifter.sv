module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input  [data_width-1:0] data_in,
    input  [shift_bits_width-1:0] shift_bits,
    input  [2:0] mode,             
    input  left_right,              
    input  [data_width-1:0] mask,   
    input  enable,                  
    input  enable_parity,           
    // New inputs for Conditional Bit Manipulation Mode
    input  [data_width-1:0] condition,
    input  [1:0] bit_op_type,
    output reg [data_width-1:0] data_out,
    output reg parity_out,        
    output reg [1:0] error               
);

always @(*) begin
    if (!enable) begin
        data_out = data_out;
        error    = 2'b00;
        parity_out = 0;
    end else begin
        case (mode)
            3'b000: begin  
                if (shift_bits >= data_width) begin
                    error    = 2'b10;  // Out-of-Range Shift
                    data_out = {data_width{1'b0}};
                end else begin
                    if (left_right)
                        data_out = data_in << shift_bits;
                    else
                        data_out = data_in >> shift_bits;
                    error = 2'b00;
                end
            end
            3'b001: begin  
                if (shift_bits >= data_width) begin
                    error    = 2'b10;  // Out-of-Range Shift
                    data_out = {data_width{1'b0}};
                end else begin
                    if (left_right)
                        data_out = data_in << shift_bits;
                    else
                        data_out = $signed(data_in) >>> shift_bits;
                    error = 2'b00;
                end
            end
            3'b010: begin 
                if (shift_bits >= data_width) begin
                    error    = 2'b10;  // Out-of-Range Shift
                    data_out = {data_width{1'b0}};
                end else begin
                    if (left_right)
                        data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
                    else
                        data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
                    error = 2'b00;
                end
            end
            3'b011: begin  
                if (shift_bits >= data_width) begin
                    error    = 2'b10;  // Out-of-Range Shift
                    data_out = {data_width{1'b0}};
                end else begin
                    if (left_right)
                        data_out = (data_in << shift_bits) & mask;
                    else
                        data_out = (data_in >> shift_bits) & mask;
                    error = 2'b00;
                end
            end
            3'b100: begin 
                // Arithmetic mode (no shift check applied)
                if (left_right)
                    data_out = data_in + shift_bits;
                else
                    data_out = data_in - shift_bits;
                error = 2'b00;
            end
            3'b101: begin  
                if (shift_bits >= data_width) begin
                    error    = 2'b10;  // Out-of-Range Shift
                    data_out = {data_width{1'b0}};
                end else begin
                    data_out = 0;
                    for (int i = data_width-1; i >= 0; i = i - 1) begin
                        if (data_in[i] == 1 && data_out == 0)
                            data_out = i;
                    end
                    error = 2'b00;
                end
            end
            3'b110: begin 
                if (left_right)
                    data_out = (data_in + shift_bits) % data_width;
                else
                    data_out = (data_in - shift_bits) % data_width;
                error = 2'b00;
            end
            3'b111: begin  
                // Conditional Bit Manipulation Mode
                if (bit_op_type == 2'b11) begin
                    error    = 2'b01;  // Invalid Operation Type
                    data_out = {data_width{1'b0}};
                end else begin
                    case (bit_op_type)
                        2'b00: data_out = data_in ^ condition;   // Toggle
                        2'b01: data_out = data_in | condition;   // Set
                        2'b10: data_out = data_in & ~condition;  // Clear
                        default: begin
                            error    = 2'b01;  // Invalid Operation Type
                            data_out = {data_width{1'b0}};
                        end
                    endcase
                    // For valid bit_op_type, set error to No Error.
                    if ((bit_op_type == 2'b00) || (bit_op_type == 2'b01) || (bit_op_type == 2'b10))
                        error = 2'b00;
                end
            end
            default: begin
                data_out = {data_width{1'b0}};
                error    = 2'b01;  // Invalid Mode
            end
        endcase
    end

    if (enable_parity)
        parity_out = ^data_out;
    else
        parity_out = 0;
end

endmodule