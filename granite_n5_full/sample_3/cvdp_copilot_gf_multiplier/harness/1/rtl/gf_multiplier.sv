module gf_multiplier(
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] result
);

always @(*) begin
    result = 0;
    reg [3:0] multiplicand = A;
    for(int i=0; i<4; i++) begin
        if(B[i] == 1) begin
            result = result ^ multiplicand;
            multiplicand = {multiplicand[3:1], multiplicand[0]};
            if(multiplicand[3] == 1) begin
                multiplicand = multiplicand ^ 5'b10011;
            end
        end else begin
            result = result ^ 0;
            multiplicand = {multiplicand[3:1], multiplicand[0]};
            if(multiplicand[3] == 1) begin
                multiplicand = multiplicand ^ 5'b10011;
            end
        end
    end
end

endmodule