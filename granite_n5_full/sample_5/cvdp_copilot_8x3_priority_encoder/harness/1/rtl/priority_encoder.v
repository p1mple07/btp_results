module priority_encoder_8x3(
    input  logic [7:0] in,
    output logic [2:0] out
);

always_comb begin
    case (in)
        8'hFF : out = 3'b111; // Highest priority
        8'hFE : out = 3'b110;
        8'hFC : out = 3'b100;
        8'hF8 : out = 3'b010;
        8'hF0 : out = 3'b001;
        default: out = 3'b000; // Default to 0 when no input is active
    endcase
end

endmodule