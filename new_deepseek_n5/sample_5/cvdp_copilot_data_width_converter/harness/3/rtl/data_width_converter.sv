module data_width_converter(
    input clock,
    input reset,
    input data_in,
    input data_valid,
    output o_data_out,
    output o_data_out_valid
);

    // State variable to track the phase of the conversion process
    reg state = idle;

    // Internal buffer to store up to four 32-bit data chunks
    reg [32] data_buffer[4];

    // Internal counter to track the number of valid data chunks
    reg count = 0;

    // Process the data on positive edge of clock
    always clock positive edge begin
        if (reset) begin
            // Reset all internal states and outputs
            state = idle;
            o_data_out = 0;
            o_data_out_valid = 0;
            data_buffer[0:3] = 0;
            count = 0;
        else begin
            if (data_valid) begin
                // Store the valid data chunk
                data_buffer[count] = data_in;
                count = count + 1;
                
                // If we've collected four valid chunks, concatenate them
                if (count == 4) begin
                    // Concatenate the four 32-bit chunks into a 128-bit output
                    o_data_out = data_buffer[3] |
                        (data_buffer[2] << 32) |
                        (data_buffer[1] << 64) |
                        (data_buffer[0] << 96);
                    o_data_out_valid = 1;
                    // Reset the buffer and counter after output
                    data_buffer[0:3] = 0;
                    count = 0;
                end
            end
        end
    end

    // Indicate that no data is available until four valid chunks are received
    always begin
        if (!reset && !o_data_out_valid) begin
            o_data_out = 0;
        end
    end
endmodule