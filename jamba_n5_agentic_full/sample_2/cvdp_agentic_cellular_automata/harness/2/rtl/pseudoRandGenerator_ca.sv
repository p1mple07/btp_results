module pseudoRandGenerator_ca (
    input clock,
    input reset,
    input [15:0] CA_seed,
    input [1:0] rule_sel,
    output reg [15:0] CA_out
);

localparam RULE_30 = 2'b00;
localparam RULE_110 = 2'b01;

int compute_next_bit(int i, int left, int right)
{
    if (rule_sel == 2'b00) begin
        // Rule 30: 111 -> 0, 110 -> 0, 101 -> 0, 100 -> 1, 011 -> 1, 010 -> 1, 001 -> 1, 000 -> 0
        case (left | center | right) do
            8'b111 => 0;
            8'b110 => 0;
            8'b101 => 0;
            8'b100 => 1;
            8'b011 => 1;
            8'b010 => 1;
            8'b001 => 1;
            8'b000 => 0;
            default => 0;
        endcase
    end else if (rule_sel == 2'b01) begin
        // Rule 110: 111 -> 0, 110 -> 1, 101 -> 1, 100 -> 0, 011 -> 1, 010 -> 1, 001 -> 1, 000 -> 0
        case (left | center | right) do
            8'b111 => 0;
            8'b110 => 1;
            8'b101 => 1;
            8'b100 => 0;
            8'b011 => 1;
            8'b010 => 1;
            8'b001 => 1;
            8'b000 => 0;
            default => 0;
        endcase
    end else begin
        // Default to Rule 30
        return 0;
    end
}

always_comb
begin
    CA_out = {};
    for (integer i = 0; i < 16; i = 1) begin : cell
        integer left_index = (i > 0) ? i - 1 : 15;
        integer center_index = i;
        integer right_index = (i < 15) ? i + 1 : 0;

        int next_bit = compute_next_bit(left_index, center_index, right_index);
        CA_out[i] = next_bit;
    end
end

always_ff @(posedge clock) begin
    if (reset) begin
        CA_out <= CA_seed;
    end else begin
        // Do nothing, state remains updated
    end
end

endmodule
