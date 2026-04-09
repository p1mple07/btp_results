module lfsr_8bit(input clock, reset, input [7:0] lfsr_seed, output reg [7:0] lfsr_out);

reg [7:0] state;

always_ff @(posedge clock or negedge reset)
begin
    if (!reset)
        state <= lfsr_seed;
    else
        state <= state + 1;
end

assign lfsr_out = state[7:0];

endmodule
