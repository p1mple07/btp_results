module pseudoRandGenerator_ca (
    input  logic       clock,
    input  logic       reset,
    input  logic [15:0] CA_seed,
    output logic [15:0] CA_out
);

    reg [15:0] q;
    reg [15:0] next_q;

    assign CA_out = next_q;

    always_ff @(posedge clock or reset) begin
        if (reset)
            q <= {16'b0};
        else
            q <= CA_seed;
    end

    always_comb begin
        next_q = {
            q[15],
            q[14],
            q[12],
            q[11],
            q[9],
            q[8],
            q[6],
            q[5],
            q[3],
            q[2],
            q[0],
            q[1],
            q[4],
            q[13],
            q[15]
        };
    end

endmodule
