
module bcd_to_excess_3 (
    input       bcd,
    output reg [3:0] excess3,
    output reg error
);

always @(bcd) begin
    if (bcd < 10) begin
        excess3 <= bcd + 3;
        error <= 0;
    end else begin
        excess3 <= 4'b0000;
        error <= 1;
    end
end

endmodule
