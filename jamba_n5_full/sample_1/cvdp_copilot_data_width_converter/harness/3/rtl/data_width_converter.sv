module data_width_converter(
    input wire clk,
    input wire reset,
    input wire data_in_ready,  // data_valid
    input wire data_in,
    input wire [31:0] data_out_ready,  // o_data_out
    output reg o_data_out_valid
);

reg [3:0] count;
reg [31:0] o_data_out;
reg o_data_out_valid;

always @(posedge clk) begin
    if (reset) begin
        o_data_out <= 128'd0;
        o_data_out_valid <= 0;
        count <= 0;
    end else begin
        if (data_valid && data_in_ready) begin
            count++;
            if (count == 4) begin
                o_data_out <= { data_in[31:0], data_in[31:0], data_in[31:0], data_in[31:0] };
                o_data_out_valid <= 1;
            end else {
                o_data_out <= 128'd0;
                o_data_out_valid <= 0;
            }
        end else if (data_valid) begin
            count = 0;
        end
    end
end

endmodule
