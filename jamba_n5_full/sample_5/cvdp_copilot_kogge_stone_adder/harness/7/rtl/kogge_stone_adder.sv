module kogge_stone_adder (
    input logic clk,
    input logic reset,
    input logic [15:0] A,
    input logic [15:0] B,
    input logic start,
    output logic [16:0] Sum,
    output logic done
);

    parameter N = 16;
    reg [N-1:0] G0, G1, G2, G3;
    reg [N-1:0] P0, P1, P2, P3;
    reg [16:0] carry;
    reg [3:0] stage;
    reg active;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            Sum <= 0;
            done <= 0;
            active <= 0;
            stage <= 0;
            G0 <= 0; G1 <= 0; G2 <= 0; G3 <= 0;
            P0 <= 0; P1 <= 0; P2 <= 0; P3 <= 0;
            carry <= 0;
        end else begin
            if (active) begin
                if (stage == 0) begin
                    // Stage 0: G0 = A & B, P0 = A ^ B
                    G0 <= A & B;
                    P0 <= A ^ B;
                end else if (stage == 1) begin
                    // Stage 1: G1 = G0 | (P0 & G0[0])? Actually, standard formula:
                    // G1[i] = G0[i] | (P0[i] & G0[i-1])
                    // P1[i] = P0[i] & P0[i-1]
                    // But we need to implement properly.
                    // Simplify: In Kogge-Stone, the first stage G0, P0.
                    G1 <= G0 | (P0 & G0[0]);
                    P1 <= P0 & P0[0];
                end else if (stage == 2) begin
                    G2 <= G1 | (P1 & G1[1]);
                    P2 <= P1 & P1[1];
                end else if (stage == 3) begin
                    G3 <= G2 | (P2 & G2[2]);
                    P3 <= P2 & P2[2];
                end else begin
                    G3 <= 0;
                    P3 <= 0;
                end

                // Compute sum_comb
                sum_comb <= P0[15] ^ carry[15];

                // Update carry
                carry <= {G3[15], carry[14:0]};

                // Determine next stage
                stage <= stage + 1;
                if (stage == 4) stage <= 3;
            end

            always_comb begin
                Sum <= {P0[15], P1[15], P2[15], P3[15]};
                done <= active;
            end
        end
    end

endmodule
