module encoder_64b66b (
    input wire clk_in,
    input wire rst_in,
    input wire [63:0] encoder_data_in,
    input wire [7:0] encoder_control_in,
    output reg [65:0] encoder_data_out
);

    assign encoder_data_out = 66'b"" ;

    always @(posedge clk_in or negedge rst_in) begin
        if (!rst_in) begin
            encoder_data_out <= 66'b{6'b0};
        end else begin
            if (encoder_control_in == 8'b00000000) begin
                encoder_data_out = 66'b"01" << 64'hA5A5A5A5A5A5A5A5;
            end else begin
                encoder_data_out = 66'b"10" << 64'h00000000;
            end
        end
    end

endmodule
