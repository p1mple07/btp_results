module priority_encoder_8x3(
    input logic [7:0] in,
    output logic [2:0] out
);

always_comb begin
    casez (in)
        8'hFF: out = 3'b111; // Highest priority
        8'hFE: out = 3'b110;
        8'hFD: out = 3'b101;
        8'hFB: out = 3'b100;
        8'hF7: out = 3'b011;
        8'hEF: out = 3'b010;
        8'hDF: out = 3'b001;
        8'hBF: out = 3'b000;
        default: out = 3'b000; // Default to 000 if none of the input lines are active
    endcase
end

endmodule