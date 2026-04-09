module binary_to_one_hot_decoder_sequential #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
) (
    input wire [BINARY_WIDTH-1:0] i_binary_in,
    input wire i_clk,
    input wire i_rstb,
    output reg [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    // Sequential register to hold the one-hot encoded output
    reg [OUTPUT_WIDTH-1:0] one_hot_reg;

    // State machine to update the one-hot encoded output
    always @(posedge i_clk or posedge i_rstb) begin
        if (i_rstb) begin
            one_hot_reg <= 0; // Asynchronously reset to all zeros
        end else if (i_binary_in < (1 << BINARY_WIDTH)) begin
            // Update the one-hot encoded output based on the input
            one_hot_reg <= {(1 << BINARY_WIDTH) - 1'b1, one_hot_reg[BINARY_WIDTH-1:0] & ~(1 << (i_binary_in - 1))};
        end
        // The output is the value of the sequential register
        o_one_hot_out <= one_hot_reg;
    end

endmodule
