module pseudoRandGenerator_ca (
    input clock,
    input reset,
    input [15:0] CA_seed,
    input [1:0] rule_sel,
    output reg [15:0] CA_out
);

reg [15:0] next_CA_out;

always_comb begin
    next_CA_out = 16'h00000000;
    for (int i = 0; i < 16; i = 1) begin
        localvar bit_left = CA_out[i - 1];
        localvar bit_right = CA_out[i + 1];

        if (rule_sel == 2'b00) begin
            if (bit_left == 1 && bit_right == 1)
                next_bit = 0;
            else if (bit_left == 1 || bit_right == 1)
                next_bit = 0;
            else
                next_bit = 1;
        end else if (rule_sel == 2'b01) begin
            if (bit_left == 1 && bit_right == 1)
                next_bit = 0;
            else if (bit_left == 1 && bit_right == 0)
                next_bit = 1;
            else if (bit_left == 0 && bit_right == 1)
                next_bit = 1;
            else
                next_bit = 0;
        end default // rule_sel == 2'b10
        next_bit = 1; // fallback
    end
end

always_ff @(posedge clock) begin
    CA_out <= next_CA_out;
end

endmodule
