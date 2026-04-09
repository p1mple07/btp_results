module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,             
    input left_right,              
    input [data_width-1:0] mask,   
    input enable,                  
    input enable_parity,           
    // New inputs for conditional bit manipulation mode
    input [data_width-1:0] condition,
    input [1:0] bit_op_type,
    output reg [data_width-1:0] data_out,
    output reg parity_out,        
    output reg [1:0] error               
);

always @(*) begin
    if (!enable) begin
        // When not enabled, retain previous data_out and indicate no error.
        data_out = data_out;
        error = 2'b00;      // No Error
        parity_out = 0;
    end else begin
        case (mode)
            3'b000: begin  
                if (shift_bits >= data_width) begin
                    error = 2'b10;  // Out-of-Range Shift
                    data_out = {data_width{1'b0}};
                end else begin
                    if (left_right) begin
                        data_out = data_in << shift_bits;
                    end else begin
                        data_out = data_in >> shift_bits;
                    end
                    error = 2'b00;  // No Error
                end
            end
            3'b001: begin  
                if (shift_bits >= data_width) begin
                    error = 2'b10;  // Out-of-Range Shift
                    data_out = {data_width{1'b0}};
                end else begin
                    if (left_right) begin
                        data_out = data_in << shift_bits;
                    end else begin
                        data_out = $signed(data_in) >>> shift_bits;
                    end
                    error = 2'b00;  // No Error
                end
            end
            3'b010: begin 
                if (shift_bits >= data_width) begin
                    error = 2'b10;  // Out-of-Range Shift
                    data_out = {data_width{1'b0}};
                end else begin
                    if (left_right) begin
                        data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits)); 
                    end else begin
                        data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));  
                    end
                    error = 2'b00;  // No Error
                end
            end
            3'b011: begin  
                if (shift_bits >= data_width) begin
                    error = 2'b10;  // Out-of-Range Shift
                    data_out = {data_width{1'b0}};
                end else begin
                    if (left_right) begin
                        data_out = (data_in << shift_bits) & mask;  
                    end else begin
                        data_out = (data_in >> shift_bits) & mask;  
                    end
                    error = 2'b00;  // No Error
                end
            end
            3'b100: begin 
                // Addition/Subtraction mode (does not use shift_bits)
                if (left_right) begin
                    data_out = data_in + shift_bits;  
                end else begin
                    data_out = data_in - shift_bits;  
                end
                error = 2'b00;  // No Error
            end
            3'b101: begin  
                // Bit search mode: find first set bit from MSB
                data_out = 0;
                for (int i = data_width-1; i >= 0; i = i - 1) begin
                    if (data_in[i] == 1 && data_out == 0) begin
                        data_out = i;  
                    end
                end
                error = 2'b00;  // No Error
            end
            3'b110: begin 
                // Modular arithmetic mode
                if (left_right) begin
                    data_out = (data_in + shift_bits) % data_width; 
                end else begin
                    data_out = (data_in - shift_bits) % data_width; 
                end
                error = 2'b00;  // No Error
            end
            3'b111: begin 
                // Conditional Bit Manipulation Mode
                if (bit_op_type == 2'b11) begin
                    // Invalid operation type
                    error = 2'b01;  // Invalid Operation
                    data_out = {data_width{1'b0}};
                end else begin
                    case (bit_op_type)
                        2'b00: begin
                            // Toggle: XOR with condition
                            data_out = data_in ^ condition;
                        end
                        2'b01: begin
                            // Set: OR with condition
                            data_out = data_in | condition;
                        end
                        2'b10: begin
                            // Clear: AND with inverted condition
                            data_out = data_in & ~condition;
                        end
                        default: begin
                            // Should not occur, but for safety
                            error = 2'b01;
                            data_out = {data_width{1'b0}};
                        end
                    endcase
                    error = 2'b00;  // No Error
                end
            end
            default: begin
                // Invalid mode encountered
                error = 2'b01;  // Invalid Mode
                data_out = {data_width{1'b0}};
            end
        endcase
    end

    // Parity calculation if enabled
    if (enable_parity) begin
        parity_out = ^data_out; 
    end else begin
        parity_out = 0;        
    end
end

endmodule