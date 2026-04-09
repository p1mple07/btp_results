// pseudoRandGenerator_ca.sv
`timescale 1ns/1ps

module pseudoRandGenerator_ca #(
    parameter STATE_WIDTH = 16,
    parameter RULE_SEL_WIDTH = 2
)(
    input wire clock,
    input wire reset,
    input wire [15:0] CA_seed,
    input wire [1:0] rule_sel,
    output reg [15:0] CA_out
);

reg [15:0] next_CA_out;

always_comb begin
    next_CA_out = 0;
    for (int i = 0; i < 16; i = i + 1) begin
        // Compute left and right neighbours with wrap‑around
        reg left, right;
        left = CA_out[(i - 1) % 16];
        right = CA_out[(i + 1) % 16];

        // Rule 30 (default)
        if (rule_sel == 2'b00) begin
            if (left == 1'b1 && right == 1'b1)
                next_CA_out[i] = 1'b0;
            else if (left == 1'b1 && right == 1'b0)
                next_CA_out[i] = 1'b0;
            else if (left == 1'b1 && right == 1'b1)
                next_CA_out[i] = 1'b0;
            else if (left == 1'b0 && right == 1'b0)
                next_CA_out[i] = 1'b0;
            // Add more rules as needed
        end

        // Rule 110 (example)
        else if (rule_sel == 2'b01) begin
            if (left == 1'b1 && right == 1'b1)
                next_CA_out[i] = 1'b0;
            else if (left == 1'b1 && right == 1'b0)
                next_CA_out[i] = 1'b1;
            else if (left == 1'b1 && right == 1'b1)
                next_CA_out[i] = 1'b0;
            else if (left == 1'b0 && right == 1'b0)
                next_CA_out[i] = 1'b0;
            // Add more rules as needed
        end
    end

    CA_out = next_CA_out;
endalways_comb

endmodule
