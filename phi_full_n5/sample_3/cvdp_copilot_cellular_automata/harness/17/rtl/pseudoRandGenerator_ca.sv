
module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic [15:0] q[16:0];

    always_ff @(posedge clock) begin
        if (reset) begin
            for (int i = 0; i < 16; i = i + 1) begin
                q[i] <= CA_seed[i];
            end
        end else begin
            q[15] <= CA_out[15];
            q[14] <= CA_out[14];
            q[13] <= CA_out[13];
            q[12] <= CA_out[12];
            q[11] <= CA_out[11];
            q[10] <= CA_out[10];
            q[9]  <= CA_out[9];
            q[8]  <= CA_out[8];
            q[7]  <= CA_out[7];
            q[6]  <= CA_out[6];
            q[5]  <= CA_out[5];
            q[4]  <= CA_out[4];
            q[3]  <= CA_out[3];
            q[2]  <= CA_out[2];
            q[1]  <= CA_out[1];
            q[0]  <= CA_out[0];
        end
    end

endmodule
