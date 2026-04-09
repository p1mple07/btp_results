module binary_to_one_hot_decoder_sequential (
    input i_binary_in,
    input i_clk,
    input i_rstb,
    output reg [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    localparam BINARY_WIDTH = 5;
    localparam OUTPUT_WIDTH = 32;

    assign o_one_hot_out = {
        .size(OUTPUT_WIDTH),
        [OUTPUT_WIDTH-1:0] {1'b0}
    };

    always @(posedge i_clk or posedge i_rstb) begin
        if (~i_rstb) begin
            o_one_hot_out <= {7'b0};
        end else begin
            if (i_binary_in != 0) begin
                for (int j = 0; j < OUTPUT_WIDTH; j++) begin
                    o_one_hot_out[j] = 1'b0;
                end
                o_one_hot_out[i_binary_in] = 1'b1;
            end
        end
    end

endmodule
