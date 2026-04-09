module pseudoRandGenerator_ca (
    input logic         clock,
    input logic         reset,
    input logic [15:0] CA_seed,
    input logic [1:0]   rule_sel,
    output logic [15:0] CA_out
);

    logic [15:0] next_CA_out;
    int i;

    always_comb begin
        for (i = 0; i < 16; i = i + 1) begin
            logic left, right;
            left = CA_out[(i - 1) % 16];
            right = CA_out[(i + 1) % 16];

            if (rule_sel == 2'b00) begin
                case (left && right)
                    {1, 0, 1} => next_CA_out[i] = 0;
                    {1, 0, 0} => next_CA_out[i] = 1;
                    {0, 1, 1} => next_CA_out[i] = 1;
                    {0, 1, 0} => next_CA_out[i] = 1;
                    {0, 0, 1} => next_CA_out[i] = 1;
                    {0, 0, 0} => next_CA_out[i] = 0;
                endcase
            end
            else begin
                case (left && right)
                    {1, 1, 1} => next_CA_out[i] = 0;
                    {1, 1, 0} => next_CA_out[i] = 1;
                    {1, 0, 1} => next_CA_out[i] = 1;
                    {1, 0, 0} => next_CA_out[i] = 0;
                    {0, 1, 1} => next_CA_out[i] = 1;
                    {0, 1, 0} => next_CA_out[i] = 1;
                    {0, 0, 1} => next_CA_out[i] = 1;
                    {0, 0, 0} => next_CA_out[i] = 0;
                endcase
            end
        end

        CA_out = next_CA_out;
    end

endmodule
