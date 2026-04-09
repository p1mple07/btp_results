module barrel_shifter #(
    parameter data_width = 16,     
    parameter shift_bits_width = 4  
) (
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,               
    input left_right,              
    input [data_width-1:0] mask,   
    input enable,                  
    input enable_parity,           
    output reg [data_width-1:0] data_out,
    output reg error,
    output reg parity_out
);

    // Parity calculation signal
    reg [data_width-1:0] parity_calc_result;

    // Parity calculation logic
    always @(data_out) begin
        parity_calc_result = ^data_out;
        parity_out = parity_calc_result[data_width-1];
    end

    // Error detection logic
    reg error_detected;
    always @(*) begin
        if (shift_bits >= data_width) begin
            error_detected = 1;
            data_out = {data_width{1'b0}}; // Set data_out to all zeros
        end else begin
            error_detected = 0;
        end
    end

    // Control logic based on the mode
    always @(*) begin
        error = 0;
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
                if (enable) begin
                    if (mode == 3'b100) begin
                        if (left_right)
                            data_out = data_in + shift_bits;
                        else
                            data_out = data_in - shift_bits;
                    end
                end
                if (enable_parity) begin
                    parity_out = ^data_out[data_width-1];
                end
            end
            3'b101: begin
                if (data_in) begin
                    data_out = {data_width{1'b1}, data_in[data_width-1:]};
                end else begin
                    data_out = {data_width{1'b0}};
                end
            end
            3'b110: begin
                if (left_right)
                    data_out = (data_in + shift_bits) % data_width;
                else
                    data_out = (data_in - shift_bits) % data_width;
                if (enable) begin
                    if (mode == 3'b110) begin
                        if (left_right)
                            data_out = (data_in + shift_bits) % data_width;
                        else
                            data_out = (data_in - shift_bits) % data_width;
                    end
                end
                if (enable_parity) begin
                    parity_out = ^data_out[data_width-1];
                end
            end
            default: begin
                data_out = {data_width{1'b0}}; 
                error = 1; 
            end
        end
    end

endmodule
