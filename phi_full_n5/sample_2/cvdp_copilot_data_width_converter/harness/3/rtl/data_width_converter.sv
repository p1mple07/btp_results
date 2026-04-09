module data_width_converter(
    input clk,
    input reset,
    input [31:0] data_in,
    input data_valid,
    output reg [127:0] o_data_out,
    output reg o_data_out_valid
);

    // Internal signals
    reg [31:0] buffer[4:0];
    reg [1:0] buffer_count = 0;
    reg [1:0] output_valid = 0;

    // State machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_count <= 0;
            o_data_out <= 16'h00000000;
            o_data_out_valid <= 0;
        end else if (buffer_count == 4) begin
            buffer_count <= 0;
            o_data_out <= {buffer[3], buffer[2], buffer[1], buffer[0]};
            o_data_out_valid <= 1;
        end else if (data_valid && buffer_count < 4) begin
            buffer[buffer_count] <= data_in;
            buffer_count <= buffer_count + 1;
        end
    end

endmodule
