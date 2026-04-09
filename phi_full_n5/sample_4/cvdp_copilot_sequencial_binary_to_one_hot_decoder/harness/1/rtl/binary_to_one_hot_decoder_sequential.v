module binary_to_one_hot_decoder_sequential #(parameter BINARY_WIDTH=5, OUTPUT_WIDTH=32)
(
    input wire i_clk,
    input wire i_rstb,
    input wire [BINARY_WIDTH-1:0] i_binary_in,
    output reg [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    // Initialize the output to all zeros on reset
    always @(posedge i_clk or posedge i_rstb) begin
        if (i_rstb) begin
            o_one_hot_out <= 0;
        end else begin
            case (i_binary_in)
                BINARY_WIDTH'd(0): o_one_hot_out <= {OUTPUT_WIDTH{1'b0}};
                BINARY_WIDTH'd(1): o_one_hot_out <= {OUTPUT_WIDTH{1'b0}, 1'b1};
                BINARY_WIDTH'd(2): o_one_hot_out <= {OUTPUT_WIDTH{1'b0, 1'b0, 1'b1}};
                BINARY_WIDTH'd(3): o_one_hot_out <= {OUTPUT_WIDTH{1'b0, 1'b0, 1'b0, 1'b1}};
                BINARY_WIDTH'd(4): o_one_hot_out <= {OUTPUT_WIDTH{1'b0, 1'b0, 1'b0, 1'b0, 1'b1}};
                BINARY_WIDTH'd(5): o_one_hot_out <= {OUTPUT_WIDTH{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1}};
                default: o_one_hot_out <= 1'bx; // Invalid input
            endcase
        end
    end

endmodule
