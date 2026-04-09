module encoder64b66b (
    input clk_in,
    input rst_in,
    input [63:0] encoder_data_in,
    input [7:0] encoder_control_in,
    output reg [65:0] encoder_data_out
);

initial begin
    encoder_data_out = 66'b0;
end

always @(posedge clk_in or posedge rst_in) begin
    if (rst_in)
        encoder_data_out <= 66'b0;
    else
        if (encoder_control_in == 8'b00000000) begin
            encoder_data_out = 66'b "01" + encoder_data_in;
        end else begin
            encoder_data_out = 66'b "10" + encoder_data_in;
        end
end

endmodule
