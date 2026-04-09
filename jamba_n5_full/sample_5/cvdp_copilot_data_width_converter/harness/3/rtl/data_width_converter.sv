module data_width_converter (
    input wire clk,
    input wire reset,
    input wire [31:0] data_in,
    input wire data_valid,
    output reg o_data_out,
    output reg o_data_out_valid
);

    localparam num_inputs_needed = 4;
    reg [num_inputs_needed-1:0] count;
    reg [31:0] concat_data;
    reg o_data_out_valid;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_data_out_valid <= 0;
            count <= 0;
            concat_data <= 0;
        end else begin
            if (data_valid) begin
                count <= count + 1;
                if (count == num_inputs_needed) begin
                    o_data_out_valid <= 1;
                    concat_data <= concat(concat_data, data_in);
                end
            end
        end
    end

    assign o_data_out = concat_data;
    assign o_data_out_valid = o_data_out_valid;

endmodule
