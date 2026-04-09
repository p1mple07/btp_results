module binary_to_one_hot_decoder_sequential #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
) (
    input [BINARY_WIDTH-1:0] i_binary_in,
    input i_clk,
    input i_rstb,
    output reg [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    // Sequential logic to handle the reset and update of o_one_hot_out
    always @(posedge i_clk or posedge i_rstb) begin
        if (i_rstb) begin
            o_one_hot_out <= 0; // Asynchronous reset to all zeros
        end else begin
            o_one_hot_out <= {(1 << BINARY_WIDTH) - 1, i_binary_in};
        end
    end

endmodule
