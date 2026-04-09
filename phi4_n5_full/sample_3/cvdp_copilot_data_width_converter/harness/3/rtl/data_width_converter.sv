module data_width_converter(
    input  logic         clk,
    input  logic         reset,
    input  logic [31:0]  data_in,
    input  logic         data_valid,
    output logic [127:0] o_data_out,
    output logic         o_data_out_valid
);

    // Internal counter to track number of valid inputs received (0 to 3)
    logic [1:0] count;

    // Buffer to store four 32-bit inputs
    logic [31:0] data_buffer [0:3];

    // Sequential process: operates on the positive edge of clk or asynchronous reset
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // On reset, clear the counter, buffer, and outputs
            count                   <= 2'd0;
            o_data_out              <= 128'd0;
            o_data_out_valid        <= 1'd0;
        end
        else begin
            if (data_valid) begin
                // Store the incoming data into the buffer at the current count index
                data_buffer[count] <= data_in;

                // If four valid inputs have been received, generate the output
                if (count == 2'd3) begin
                    // Concatenate the four 32-bit words into a 128-bit output
                    o_data_out <= { data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0] };
                    o_data_out_valid <= 1'b1;
                    // Reset counter for the next set of inputs
                    count <= 2'd0;
                end
                else begin
                    // Increment the counter for the next valid input
                    count <= count + 2'd1;
                    o_data_out_valid <= 1'b0;
                end
            end
            else begin
                // If the current input is not valid, flush the state (reset counter)
                count <= 2'd0;
                o_data_out_valid <= 1'b0;
            end
        end
    end

endmodule