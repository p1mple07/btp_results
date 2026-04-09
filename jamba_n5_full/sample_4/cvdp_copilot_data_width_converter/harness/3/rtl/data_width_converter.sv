module data_width_converter(
    input wire clk,
    input wire reset,
    input wire [31:0] data_in,
    input wire data_valid,
    output reg o_data_out,
    output reg o_data_out_valid
);

reg [63:0] out_data;
reg [3:0] count;
reg valid;

initial begin
    count = 0;
    o_data_out = 128'd0;
    o_data_out_valid = 1'b0;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        count <= 0;
        o_data_out <= 128'd0;
        o_data_out_valid <= 1'b0;
    end else begin
        if (data_valid) begin
            count <= count + 1;
            if (count == 4) begin
                // Store the last four inputs into output
                out_data = {out_data[63:32], data_in};
                o_data_out_valid = 1'b1;
            end
        end else
            out_data <= 128'd0;
        o_data_out_valid = o_data_out;
    end
end

assign o_data_out = out_data;

endmodule
