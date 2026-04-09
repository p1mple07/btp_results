module bcd_to_excess_3(
    input [3:0] bcd,
    output reg [3:0] excess3,
    output reg error
);

always @(*) begin
    if (bcd < 0 || bcd > 9) begin
        excess3 = 4'd0;
        error = 1;
    end else begin
        excess3 = bcd + 3;
        error = 0;
    end
end

endmodule
