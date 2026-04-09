module priority_encoder_8x3 (
    input [7:0] in,
    output reg [2:0] out
);

    assign out = 3'b000;

    always @(*) begin
        if (in[7]) out = 3'b111;
        else if (in[6] && ~in[7]) out = 3'b110;
        else if (in[5] && ~in[6] && ~in[7]) out = 3'b101;
        else if (in[4] && ~in[5] && ~in[6] && ~in[7]) out = 3'b100;
        else if (in[3] && ~in[4] && ~in[5] && ~in[6] && ~in[7]) out = 3'b011;
        else if (in[2] && ~in[3] && ~in[4] && ~in[5] && ~in[6] && ~in[7]) out = 3'b010;
        else if (in[1] && ~in[2] && ~in[3] && ~in[4] && ~in[5] && ~in[6] && ~in[7]) out = 3'b001;
        else if (in[0] && ~in[1] && ~in[2] && ~in[3] && ~in[4] && ~in[5] && ~in[6] && ~in[7]) out = 3'b000;
    end

endmodule
