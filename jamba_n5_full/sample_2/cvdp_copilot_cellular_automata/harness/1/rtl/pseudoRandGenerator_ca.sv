module pseudoRandGenerator_ca (
    input  logic       clock,
    input  logic       reset,
    input  logic [15:0] CA_seed,
    output logic [15:0] CA_out
);

    logic [15:0] state;
    logic [15:0] next_state;

    always @(clock or reset) begin
        if (reset) begin
            state <= {CA_seed[15:0]};
            next_state <= '{};
        end else begin
            next_state[0] = state[15] ^ state[0];
            next_state[1] = state[1] ^ state[0] ^ state[2];
            next_state[2] = state[2] ^ state[1] ^ state[3];
            next_state[3] = state[3] ^ state[2] ^ state[4];
            next_state[4] = state[4] ^ state[3] ^ state[5];
            next_state[5] = state[5] ^ state[4] ^ state[6];
            next_state[6] = state[6] ^ state[5] ^ state[7];
            next_state[7] = state[7] ^ state[6] ^ state[8];
            next_state[8] = state[8] ^ state[7] ^ state[9];
            next_state[9] = state[9] ^ state[8] ^ state[10];
            next_state[10] = state[10] ^ state[9] ^ state[11];
            next_state[11] = state[11] ^ state[10] ^ state[12];
            next_state[12] = state[12] ^ state[11] ^ state[13];
            next_state[13] = state[13] ^ state[12] ^ state[14];
            next_state[14] = state[14] ^ state[13] ^ state[15];
            next_state[15] = state[15] ^ state[14] ^ state[0];

            state <= next_state;
        end
    end

    CA_out <= state;

endmodule
