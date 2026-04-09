module data_width_converter(
    input  logic         clk,
    input  logic         reset,
    input  logic [31:0]  data_in,
    input  logic         data_valid,
    output logic [127:0] o_data_out,
    output logic         o_data_out_valid
);

    // Internal buffer to store four 32-bit data samples
    logic [31:0] data_buffer [0:3];
    // Counter to track the number of valid samples received (0 to 4)
    logic [2:0]  sample_count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sample_count         <= 3'd0;
            data_buffer[0]       <= 32'd0;
            data_buffer[1]       <= 32'd0;
            data_buffer[2]       <= 32'd0;
            data_buffer[3]       <= 32'd0;
            o_data_out_valid     <= 1'b0;
        end else begin
            if (data_valid) begin
                // Store the incoming data sample into the buffer at the current index
                data_buffer[sample_count] <= data_in;
                // Increment the sample counter
                sample_count <= sample_count + 1;

                // When four valid samples have been received, generate the output
                if (sample_count == 3'd4) begin
                    // Concatenate the four samples in order (first sample is MSB)
                    o_data_out <= { data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0] };
                    o_data_out_valid <= 1'b1;
                    // Reset the counter and buffer for the next set of inputs
                    sample_count <= 3'd0;
                end else begin
                    o_data_out_valid <= 1'b0;
                end
            end else begin
                o_data_out_valid <= 1'b0;
            end
        end
    end

endmodule