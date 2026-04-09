module lfsr_8bit(
    input         clock,
    input         reset,
    input [7:0]   lfsr_seed,
    output reg    [7:0]  lfsr_out
);

    reg [7:0]    state;

    initial begin
        state = lfsr_seed;
    end

    always_ff @(posedge clock or negedge reset) begin
        if (!reset)
            state <= lfsr_seed;
        else
            state <= {state[7], state[6], state[5], state[1]};
    end

    assign lfsr_out = state;

endmodule
