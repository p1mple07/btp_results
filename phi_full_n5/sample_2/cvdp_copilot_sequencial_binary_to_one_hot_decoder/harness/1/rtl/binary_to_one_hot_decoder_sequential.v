module binary_to_one_hot_decoder_sequential #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
) (
    input wire [BINARY_WIDTH-1:0] i_binary_in,
    input wire i_clk,
    input wire i_rstb,
    output reg [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    // Sequential register to hold the state of the one-hot encoded output
    reg [OUTPUT_WIDTH-1:0] one_hot_reg;

    // State update logic
    always @(posedge i_clk or posedge i_rstb) begin
        if (i_rstb) begin
            // Asynchronous reset logic
            one_hot_reg <= 0;
        end else begin
            // Update the one-hot encoded register based on input
            case (i_binary_in)
                // For each possible input value, set the corresponding bit
                // and clear all others
                default: one_hot_reg <= {(1 << (i_binary_in)), 1'b0};
            endcase
        end
    end

    // Output logic
    assign o_one_hot_out = one_hot_reg;

endmodule
