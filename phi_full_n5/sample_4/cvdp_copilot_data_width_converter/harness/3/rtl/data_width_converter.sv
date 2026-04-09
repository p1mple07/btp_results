module data_width_converter(
    input clk,
    input reset,
    input [31:0] data_in,
    input data_valid,
    output reg [127:0] o_data_out,
    output reg o_data_out_valid
);

    // Internal signals
    reg [31:0] buffer[0:3];
    integer count = 0;

    // Reset condition
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer[0] = 32'h00000000;
            count = 0;
            o_data_out_valid = 0;
        end else begin
            if (!data_valid) begin
                count <= 0;
            end else begin
                buffer[count] <= data_in;
                count <= count + 1;
                if (count == 4) begin
                    o_data_out <= {buffer[3], buffer[2], buffer[1], buffer[0]};
                    o_data_out_valid = 1;
                    count <= 0; // Reset the count for the next set of inputs
                end
            end
        end
    end

endmodule
