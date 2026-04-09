module data_width_converter(
    input clock,
    input reset,
    input data_in,
    input data_valid,
    output data_out,
    output o_data_out_valid
);
    // Internal variables
    reg [127:0] data_out;
    reg [3:0] counter;
    reg [127:0] buffer;
    reg valid;
    
    // Initialize buffer and counter
    always_comb begin
        buffer = 0;
        counter = 0;
        valid = 0;
    end
    
    // Process
    always clock positive edge begin
        if (reset) begin
            buffer = 0;
            counter = 0;
            valid = 0;
        end else begin
            if (data_valid) begin
                counter = counter + 1;
                if (counter == 4) begin
                    // Assemble the buffer into data_out
                    data_out = buffer;
                    // Set output valid
                    o_data_out_valid = 1;
                    // Reset buffer and counter
                    buffer = 0;
                    counter = 0;
                end else begin
                    // Shift data into buffer
                    buffer = (data_in << (128 - 32 * counter)) | buffer;
                end
            end
        end
    end
endmodule