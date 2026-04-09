module data_width_converter(
    input clock,
    input reset,
    input data_in,
    input data_valid,
    output data_out,
    output o_data_out_valid
);

    // Internal state variables
    reg data_count = 0;
    reg data_valid_flag = 0;
    reg [127:0] o_data_out = 0;

    // Process
    always_comb begin
        // Reset all states if reset is asserted
        if (reset) begin
            data_count = 0;
            data_valid_flag = 0;
            o_data_out = 0;
            o_data_out_valid = 0;
            return;
        end

        // Only process valid data
        if (data_valid) begin
            data_count = data_count + 1;
            
            // If four valid samples have been received
            if (data_count == 4) begin
                // Concatenate the four 32-bit samples into a 128-bit output
                o_data_out = ((data_in[31:0] << 96) | 
                            (data_in[31:0] << 64) | 
                            (data_in[31:0] << 32) | 
                            data_in[31:0]);
                o_data_out_valid = 1;
                data_count = 0;
            end
        end
    end

    // Process
    always positive_edge clock begin
        // Reset all states if reset is asserted
        if (reset) begin
            data_count = 0;
            data_valid_flag = 0;
            o_data_out = 0;
            o_data_out_valid = 0;
            return;
        end

        // Only process valid data
        if (data_valid) begin
            data_count = data_count + 1;
            
            // If four valid samples have been received
            if (data_count == 4) begin
                // Concatenate the four 32-bit samples into a 128-bit output
                o_data_out = ((data_in[31:0] << 96) | 
                            (data_in[31:0] << 64) | 
                            (data_in[31:0] << 32) | 
                            data_in[31:0]);
                o_data_out_valid = 1;
                data_count = 0;
            end
        end
    end
endmodule