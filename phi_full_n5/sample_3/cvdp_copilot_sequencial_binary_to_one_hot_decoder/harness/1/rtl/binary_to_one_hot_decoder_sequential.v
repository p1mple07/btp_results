module binary_to_one_hot_decoder_sequential #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
) (
    input [BINARY_WIDTH-1:0] i_binary_in,
    input i_clk,
    input i_rstb,
    output reg [OUTPUT_WIDTH-1:0] o_one_hot_out
);

    // Sequential register to hold the one-hot encoded output
    reg [OUTPUT_WIDTH-1:0] seq_register;

    // Combinational logic to set the one-hot encoded output
    always @(posedge i_clk or posedge i_rstb) begin
        if (i_rstb) begin
            seq_register <= 0;
        end else begin
            seq_register <= {seq_register[OUTPUT_WIDTH-1-i_binary_in], 1'b0};
        end
    end

    // Output assignment
    assign o_one_hot_out = seq_register;

endmodule
