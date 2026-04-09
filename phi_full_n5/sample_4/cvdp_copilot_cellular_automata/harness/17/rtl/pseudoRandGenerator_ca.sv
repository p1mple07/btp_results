module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic [15:0] q[15:0];

    always_ff @(posedge clock) begin
        if (reset) begin
            CA_out <= CA_seed;
        end else begin
            for (int i = 15; i >= 0; i = i - 1) begin
                q[i] <= CA_out[i+1] ^ CA_out[i+2];
            end
            CA_out <= q;
        end
    end

endmodule
