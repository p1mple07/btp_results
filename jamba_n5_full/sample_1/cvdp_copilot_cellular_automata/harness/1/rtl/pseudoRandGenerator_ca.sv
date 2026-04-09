module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16‑bit Cellular Automata seed
    output logic [15:0] CA_out    // 16‑bit Cellular Automata output
);

    reg [15:0] state;

    always @(posedge clock) begin
        if (reset) begin
            state <= CA_seed;
        end else begin
            state = state ^ {state[1:0], state[14:15]};
        end
    end

    assign CA_out = state;

endmodule
