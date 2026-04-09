module binary_to_one_hot_decoder_sequencial(
    parameter BINARY_WIDTH,
    parameter OUTPUT_WIDTH,
    input i_binary_in,
    input i_clk,
    input i_rstb,
    output o_one_hot_out
);
    // Module implementation
    reg [OUTPUT_WIDTH-1:0] o_one_hot_out;
    always @ (i_clkposededge)
    begin
        if (i_rstb)
            o_one_hot_out = 0;
        else
            o_one_hot_out = 0;
            o_one_hot_out[i_binary_in] = 1;
    end
endmodule