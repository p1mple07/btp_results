module data_width_converter (
    input  logic         clk,
    input  logic         reset,
    input  logic [31:0]  data_in,
    input  logic         data_valid,
    output logic [127:0] o_data_out,
    output logic         o_data_out_valid
);

    // Internal counter to track number of valid inputs received (0 to 3)
    logic [1:0] counter;
    // Buffer to accumulate the four 32-bit inputs into a 128-bit word
    logic [127:0] data_buffer;

    // Sequential process: operates on the positive edge of clk with asynchronous reset
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter         <= 2'd0;
            data_buffer     <= 128'd0;
            o_data_out_valid<= 1'b0;
            o_data_out      <= 128'd0;
        end
        else begin
            if (data_valid) begin
                if (counter < 2'd3) begin
                    // Shift in the new 32-bit data sample into the lower 32 bits of data_buffer
                    data_buffer <= {data_buffer[95:0], data_in};
                    counter     <= counter + 1;
                end
                else begin
                    // Fourth valid input received: concatenate and generate output
                    data_buffer     <= {data_buffer[95:0], data_in};
                    o_data_out      <= data_buffer;
                    o_data_out_valid<= 1'b1;
                    // Reset internal state for next aggregation cycle
                    counter         <= 2'd0;
                    data_buffer     <= 128'd0;
                end
            end
            else begin
                // Ensure that output valid is de-asserted when no new valid input is received
                o_data_out_valid<= 1'b0;
            end
        end
    end

endmodule