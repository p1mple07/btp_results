module binary_to_one_hot_decoder(
    input binary_in,
    output one_hot_out
);
    parameter BINARY_WIDTH = 5;
    parameter OUTPUT_WIDTH = 32;
    integer i;
    
    if (binary_in >= (1 << BINARY_WIDTH)) begin
        one_hot_out = 0;
    else begin
        one_hot_out = (1 << binary_in);
    end
endmodule