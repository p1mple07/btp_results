module encoder_64b66b (
    input clk_in,
    input rst_in,
    input [63:0] encoder_data_in,
    input [7:0] encoder_control_in,
    output reg [65:0] encoder_data_out
);

initial begin
    encoder_data_out = 66'd0;
end

always @(posedge clk_in or posedge rst_in) begin
    if (rst_in)
        encoder_data_out <= 66'd0;
    else
        encoder_data_out = {2'b01, encoder_data_in};
end

endmodule
