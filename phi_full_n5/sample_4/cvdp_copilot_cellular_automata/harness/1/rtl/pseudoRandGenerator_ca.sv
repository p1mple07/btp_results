module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic [15:0] q[0:15]; // Shift register to hold the CA states

    // Initialization logic
    always @(posedge clock) begin
        if (reset) begin
            q <= {CA_seed[15], CA_seed[14], CA_seed[13], CA_seed[12], CA_seed[11],
                  CA_seed[10], CA_seed[9], CA_seed[8], CA_seed[7], CA_seed[6],
                  CA_seed[5], CA_seed[4], CA_seed[3], CA_seed[2], CA_seed[1],
                  CA_seed[0]};
        end
    end

    // Rule 90 and Rule 150 logic
    always @(posedge clock) begin
        if (!reset) begin
            // Rule 90: q[i] = q[i-1] XOR q[i+1]
            q[15] <= q[0] ^ q[15];
            for (int i = 14; i >= 0; i--) begin
                q[i] <= q[i+1] ^ q[i-1];
            end

            // Rule 150: q[i] = q[i] XOR q[i-1] XOR q[i+1]
            q[15] <= q[15] ^ q[0] ^ q[15];
            for (int i = 14; i >= 0; i--) begin
                q[i] <= q[i] ^ q[i-1] ^ q[i+1];
            end

            // Shift the states for the next clock cycle
            q <= {q[15], q[14], q[13], q[12], q[11],
                  q[10], q[9], q[8], q[7], q[6],
                  q[5], q[4], q[3], q[2], q[1],
                  q[0]};
        end
    end

    // Output logic
    assign CA_out = q[15];

endmodule
