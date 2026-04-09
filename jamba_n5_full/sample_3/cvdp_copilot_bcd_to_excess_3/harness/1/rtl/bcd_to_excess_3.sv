module bcd_to_excess_3 (
    input wire [3:0] bcd,
    output reg [3:0] excess3,
    output reg error
);

    assign error = bcd >= 10;
    assign excess3 = (bcd < 10) ? (bcd + 3) : 0;

endmodule
