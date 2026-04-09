`timescale 1ns / 1ps

module binary_to_one_hot_decoder_sequential (
    input wire       i_binary_in,
    input wire       i_clk,
    input wire       i_rstb,
    output reg [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    parameter BINARY_WIDTH = 5;
    parameter OUTPUT_WIDTH = 32;

    reg [OUTPUT_WIDTH-1:0] next_state;
    reg         clk_n;

    initial begin
        o_one_hot_out = 0;
    end

    always @(posedge i_clk or negedge i_rstb) begin
        if (!i_rstb) begin
            o_one_hot_out <= 0;
        end else begin
            if (i_clk) begin
                next_state <= 0;
                for (integer j = 0; j < OUTPUT_WIDTH; j++) begin
                    if (i_binary_in[j] == 1'b1) begin
                        next_state[j] = 1'b1;
                    end else begin
                        next_state[j] = 1'b0;
                    end
                end
            end else begin
                next_state <= 0;
            end
            o_one_hot_out <= next_state;
        end
    end

endmodule
