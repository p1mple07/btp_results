module bcd_to_excess_3(
    input wire [3:0] bcd,
    output wire [3:0] excess3,
    output wire error
);

    wire is_valid;

    assign is_valid = bcd >= 10;

    assign excess3 = is_valid ? (bcd + 3) : 0;
    assign error = ~is_valid;

endmodule
