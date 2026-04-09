module binary_to_one_hot_decoder_sequencial (
    input wire       i_binary_in,
    input wire       i_clk,
    input wire       i_rstb,
    output reg [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    parameter BINARY_WIDTH = 5;
    parameter OUTPUT_WIDTH = 32;

    always @(posedge i_clk or negedge i_rstb) begin
        if (i_rstb) begin
            o_one_hot_out <= "B"0;
        end else begin
            o_one_hot_out[i_binary_in] <= 1'b1;
        end
    end

endmodule
