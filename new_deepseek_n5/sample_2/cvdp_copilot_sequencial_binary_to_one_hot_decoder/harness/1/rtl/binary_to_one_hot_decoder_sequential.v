module binary_to_one_hot_decoder_sequencial (
    parameter BINARY_WIDTH,
    parameter OUTPUT_WIDTH,
    input i_binary_in,
    input i_clk,
    input i_rstb,
    output o_one_hot_out
);

    reg [OUTPUT_WIDTH - 1: 0] one_hot_out;

    always clocked (
        i_clk
    ) begin
        if (i_rstb)
            one_hot_out = 0;
        else
            for (int j = 0; j < BINARY_WIDTH; j++) begin
                one_hot_out[j] = (i_binary_in >> j) & 1;
            end
        end
    end

    o_one_hot_out = one_hot_out;
endmodule