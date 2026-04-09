module data_width_converter (
    input  logic         clk,
    input  logic         reset,
    input  logic [31:0]  data_in,
    input  logic         data_valid,
    output logic [127:0] o_data_out,
    output logic         o_data_out_valid
);

    // Parameter for number of samples needed.
    parameter NUM_SAMPLES = 4;

    // 2-bit counter to count valid inputs (range 0 to 3)
    logic [1:0] count;

    // Buffer to store the four 32-bit samples.
    // We store samples in reverse order so that the first received sample becomes the MSB.
    logic [31:0] buffer [0:3];

    // Synchronous process triggered by clock and asynchronous reset.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset internal counter and clear buffer.
            count              <= 2'd0;
            o_data_out_valid   <= 1'b0;
            buffer[0]          <= 32'd0;
            buffer[1]          <= 32'd0;
            buffer[2]          <= 32'd0;
            buffer[3]          <= 32'd0;
        end
        else begin
            if (data_valid) begin
                // Store the incoming data into the buffer at the position determined by count.
                if (count == 2'd0)
                    buffer[3] <= data_in;
                else if (count == 2'd1)
                    buffer[2] <= data_in;
                else if (count == 2'd2)
                    buffer[1] <= data_in;
                else if (count == 2'd3)
                    buffer[0] <= data_in;

                // Increment the counter.
                count <= count + 1;

                // When four valid inputs have been received, output the concatenated data.
                if (count == NUM_SAMPLES - 1) begin
                    // Concatenate the samples in order: first sample (MSB) to fourth sample (LSB).
                    o_data_out    <= { buffer[3], buffer[2], buffer[1], buffer[0] };
                    o_data_out_valid <= 1'b1;
                    // Reset counter for the next group of four inputs.
                    count         <= 2'd0;
                end
                else begin
                    o_data_out_valid <= 1'b0;
                end
            end
            // If data_valid is not asserted, hold the state.
        end
    end

endmodule