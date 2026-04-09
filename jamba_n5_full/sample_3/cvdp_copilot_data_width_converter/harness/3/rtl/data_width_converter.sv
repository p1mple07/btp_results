module data_width_converter (
    input wire clk,
    input wire reset,
    input wire [31:0] data_in,
    input wire data_valid,
    output reg o_data_out,
    output reg [127:0] o_data_out_valid
);

reg [3:0] count;
reg [3:0] next_count;

always @(posedge clk) begin
    if (reset) begin
        count <= 4'd0;
        o_data_out <= 128'd0;
        o_data_out_valid <= 1'b0;
    end else begin
        next_count <= count + 1;
        if (data_valid && next_count == 4) begin
            o_data_out <= data_in;
            o_data_out_valid <= 1'b1;
            count <= 4'd0;
        end
    end
end

endmodule
