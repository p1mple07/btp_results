module binary_to_one_hot_decoder_sequencial #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
) (
    input  logic i_clk,
    input  logic i_rstb,
    input  logic [BINARY_WIDTH-1:0] i_binary_in,
    output reg [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    reg [OUTPUT_WIDTH-1:0] state;

    initial begin
        state <= { {1'b0} [OUTPUT_WIDTH-1:] };
    end

    always @(posedge i_clk or negedge i_rstb) begin
        if (i_rstb) begin
            state <= { {1'b0} [OUTPUT_WIDTH-1:] };
        end else begin
            state <= state ^ 1 << i_binary_in;
        end
    end

    assign o_one_hot_out = state;

endmodule
