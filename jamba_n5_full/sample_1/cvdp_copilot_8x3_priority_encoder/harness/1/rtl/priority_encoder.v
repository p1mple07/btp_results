module priority_encoder_8x3 (
    input [7:0] in,
    output [2:0] out
);

    wire [2:0] highest_set;

    always @(*) begin
        highest_set = -1;
        for (int i = 7; i >= 0; i = i - 1) begin
            if (in[i]) highest_set = i;
            else break;
        end

        if (highest_set == -1)
            out = 3'b000;
        else
            out = 3'b{highest_set};
    end

endmodule
