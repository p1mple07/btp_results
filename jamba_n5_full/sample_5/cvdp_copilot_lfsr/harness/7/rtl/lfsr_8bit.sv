module lfsr_fib (
    input wire clock,
    input wire reset,
    input wire [7:0] seed,
    output reg [7:0] lfsr_out
);

    reg [7:0] next_state;

    always @(posedge clock or posedge reset) begin
        if (reset)
            lfsr_out <= seed;
        else
            assign next_state = {lfsr_out[0], lfsr_out[7], lfsr_out[6], lfsr_out[5], lfsr_out[4], lfsr_out[3], lfsr_out[2], lfsr_out[1]};
            assign lfsr_out = next_state;
    end

endmodule
