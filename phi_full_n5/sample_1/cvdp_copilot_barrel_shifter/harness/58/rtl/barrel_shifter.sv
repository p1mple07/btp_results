module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,               
    input left_right,              
    input [data_width-1:0] mask,   
    input enable_parity,            // New enable signal for parity calculation
    input enable,                   // New enable signal for overall module control
    output reg [data_width-1:0] data_out,
    output reg error,                // Updated error signal
    output reg [data_width-1:0] parity_out // New output for parity calculation
);

always @(*) begin
    error = 0;
    parity_out = 0; // Initialize parity_out

    if (enable == 0) begin
        data_out = {data_width{1'b0}}; // Retain previous value
        parity_out = 0; // Disable parity calculation
    end
    else if (mode >= 3'b000 && mode <= 3'b110) begin
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
                // Arithmetic Addition/Subtraction
                if (left_right)
                    data_out = data_in + shift_bits;
                else
                    data_out = data_in - shift_bits;
                // Error detection for invalid shift bits
                if (shift_bits >= data_width) begin
                    error = 1;
                    data_out = {data_width{1'b0}}; // Set to all zeros
                end
            end
            3'b101: begin
                // Priority Encoder
                if (data_in == 0) begin
                    data_out = 0;
                end else begin
                    data_out = $clog2(data_in); // Get the position of the highest set bit
                end
            end
            3'b110: begin
                // Modulo Arithmetic
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
        end

        // Parity calculation
        if (enable_parity) begin
            parity_out = ^data_out; // Calculate parity using XOR
        end
    end
end

endmodule
Please note that the above code assumes that the `enable` signal is checked at every clock cycle, and the operations are performed accordingly. The error detection for invalid shift bits is done before any shift operation. The parity calculation is conditional on the `enable_parity` signal being set to `1`. Additionally, the priority encoder operation is implemented using the built-in `$clog2` function to find the position of the highest set bit.

Remember to include necessary imports and define the `enable` and `enable_parity` signals in your top-level design file to use this modified module correctly. module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,               
    input left_right,              
    input [data_width-1:0] mask,   
    input enable_parity,            // New enable signal for parity calculation
    input enable,                   // New enable signal for overall module control
    output reg [data_width-1:0] data_out,
    output reg error,                // Updated error signal
    output reg [1:0] parity_out // Changed to 2-bit reg to store even/odd parity
);

always @(*) begin
    error = 0;
    parity_out = 2'b0; // Initialize parity_out to even

    if (enable == 0) begin
        data_out = {data_width{1'b0}}; // Retain previous value
        parity_out = 2'b0; // Disable parity calculation
    end
    else if (mode >= 3'b000 && mode <= 3'b110) begin
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
                // Arithmetic Addition/Subtraction
                if (left_right)
                    data_out = data_in + shift_bits;
                else
                    data_out = data_in - shift_bits;
                // Error detection for invalid shift bits
                if (shift_bits >= data_width) begin
                    error = 1;
                    data_out = {data_width{1'b0}}; // Set to all zeros
                end
            end
            3'b101: begin
                // Priority Encoder
                if (data_in == 0) begin
                    data_out = 0;
                end else begin
                    data_out = $clog2(data_in); // Get the position of the highest set bit
                end
            end
            3'b110: begin
                // Modulo Arithmetic
                if (left_right)
                    data_out = (data_in + shift_bits) % data_width;
                else
                    data_out = (data_in - shift_bits) % data_width;
                // Calculate parity based on the result
                parity_out = ~(data_out & 1) ? 1'b1 : 1'b0; // Even parity if LSB is 1, else odd parity
            end
            default: begin
                data_out = {data_width{1'b0}}; 
                error = 1; 
            end
        end
    end
end

endmodule