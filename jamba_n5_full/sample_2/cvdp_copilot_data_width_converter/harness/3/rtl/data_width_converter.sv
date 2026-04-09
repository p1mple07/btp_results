module data_width_converter (
    input  logic clk,
    input  logic reset,
    input  logic data_in,
    input  logic data_valid,
    output logic o_data_out,
    output logic o_data_out_valid
);

    // Internal state: counter for valid inputs
    integer counter;
    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            o_data_out <= 128'd0;
            o_data_out_valid <= 1'b0;
        end else begin
            if (data_valid) begin
                counter <= counter + 1;
            end else begin
                counter <= 0; // reset counter on invalid input
            end
        end

        if (counter >= 4) begin
            // Concatenate the four 32-bit inputs
            // Each is 32 bits, we need to pack them into 128 bits.
            // Let's create a 128-bit variable.
            assign o_data_out = {
                data_in[31:0],
                data_in[31:0],
                data_in[31:0],
                data_in[31:0]
            };
            assign o_data_out_valid = 1'b1;
        end
    end

endmodule
