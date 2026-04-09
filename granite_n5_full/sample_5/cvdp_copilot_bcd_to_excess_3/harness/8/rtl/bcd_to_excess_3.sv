module bcd_to_excess_3(
    input [3:0] bcd,          // 4-bit BCD input
    output reg [3:0] excess3, // 4-bit Excess-3 output
    output reg error          // Error flag to indicate invalid input
);

// The always block triggers on any change to the BCD input.
always @(bcd or enable)
begin
    if (!enable) begin
        excess3 <= 4'b0000;
        error <= 1'b0;
    end else begin
        case(bcd)
            4'b0000: excess3 <= 4'b0011;  
            //... (other cases omitted for brevity) 
            4'b1111: excess3 <= 4'b1100;  
            default: begin
                excess3 <= 4'b0000;  
                error <= 1'b1;  
            end
        endcase
    end
end

endmodule