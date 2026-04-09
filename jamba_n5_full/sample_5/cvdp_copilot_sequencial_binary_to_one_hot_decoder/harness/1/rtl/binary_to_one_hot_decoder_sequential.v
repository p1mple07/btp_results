module binary_to_one_hot_decoder_sequential (
    input i_clk,
    input i_rstb,
    input [BINARY_WIDTH-1:0] i_binary_in,
    output [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    reg [OUTPUT_WIDTH-1:0] one_hot;

    initial begin
        one_hot = 0;
    end

    always @(posedge i_clk or negedge i_rstb) begin
        if (i_rstb)
            one_hot <= 0;
        else begin
            one_hot <= 0;
            for (int j = 0; j < OUTPUT_WIDTH; j++)
                one_hot[j] = (j == i_binary_in) ? 1 : 0;
        end
    end

endmodule
