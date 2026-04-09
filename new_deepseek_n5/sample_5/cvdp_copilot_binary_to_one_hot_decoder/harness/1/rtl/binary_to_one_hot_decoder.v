module binary_to_one_hot_decoder(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32,
    input binary_in,
    output one_hot_out
);
    integer i;
    one_hot_out = 0;
    if (binary_in >= 0 && binary_in < (1 << BINARY_WIDTH)) begin
        one_hot_out = 1 << binary_in;
    else begin
        one_hot_out = 0;
    end
endmodule