module qam16_mapper_interpolated #(
    parameter N = 4,
    parameter IN_WIDTH = 4,
    parameter OUT_WIDTH = 3
) (
    input logic [N*4-1:0] bits,
    output logic [OUT_WIDTH-1:0] I [N + N/2 - 1 : 0],
    output logic [OUT_WIDTH-1:0] Q [N + N/2 - 1 : 0]
);

always @(*) begin
    for (int i = 0; i < N; i++) begin
        logic m1, m0, l1, l0;
        logic I_sym, Q_sym;

        logic [IN_WIDTH-1:0] sym = bits[(i*IN_WIDTH)-1 : (i*IN_WIDTH)];

        m1 = sym[IN_WIDTH-2:IN_WIDTH-3];
        m0 = sym[IN_WIDTH-1:IN_WIDTH-2];
        l1 = sym[0:1];
        l0 = sym[1:0];

        // Mapping rules
        if (m1 == 0 && m0 == 0) begin
            if (l1 == 0 && l0 == 0) I_sym = -3;
            else if (l1 == 0 && l0 == 1) I_sym = -1;
            else if (l1 == 1 && l0 == 0) I_sym = 1;
            else I_sym = 3;
        end else if (m1 == 0 && m0 == 1) begin
            I_sym = -1;
        end else if (m1 == 1 && m0 == 0) begin
            I_sym = 1;
        end else if (m1 == 1 && m0 == 1) begin
            I_sym = 3;
        end else I_sym = 0;

        // Mapping rules for Q
        if (m1 == 0 && m0 == 0) begin
            if (l1 == 0 && l0 == 0) Q_sym = -3;
            else if (l1 == 0 && l0 == 1) Q_sym = -1;
            else if (l1 == 1 && l0 == 0) Q_sym = 1;
            else Q_sym = 3;
        end else if (m1 == 0 && m0 == 1) begin
            Q_sym = -1;
        end else if (m1 == 1 && m0 == 0) begin
            Q_sym = 1;
        end else if (m1 == 1 && m0 == 1) begin
            Q_sym = 3;
        end else Q_sym = 0;

        // Output the current symbol
        assign I[i] = I_sym;
        assign Q[i] = Q_sym;

        // Interpolation for the pair
        if (i < N-1) begin
            logic I_interp = (I[i] + I[i+1]) / 2;
            logic Q_interp = (Q[i] + Q[i+1]) / 2;
            assign I[i + N/2] = I_interp;
            assign Q[i + N/2] = Q_interp;
        end
    end
end

endmodule
