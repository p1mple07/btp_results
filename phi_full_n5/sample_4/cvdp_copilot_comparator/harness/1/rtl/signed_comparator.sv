module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input logic i_enable,
    input logic i_mode,
    input logic [WIDTH-1:0] i_A,
    input logic [WIDTH-1:0] i_B,
    output logic o_greater,
    output logic o_less,
    output logic o_equal
);

    // Define internal signals
    logic [WIDTH-1:0] signed_A, signed_B;
    logic unsigned_A, unsigned_B;

    // Separate the inputs based on mode
    always_comb begin
        if (i_mode) begin
            // Signed mode: interpret MSB as sign bit
            signed_A = i_A;
            signed_B = i_B;
        end else begin
            // Magnitude mode: treat inputs as unsigned
            unsigned_A = i_A;
            unsigned_B = i_B;
        end

        // Convert to unsigned for magnitude mode comparison
        if (!i_mode) begin
            unsigned_A = {signed_A[WIDTH-1:0], 1'b0};
            unsigned_B = {signed_B[WIDTH-1:0], 1'b0};
        end
    end

    // Perform comparison
    always_comb begin
        if (i_enable) begin
            if (unsigned_A > unsigned_B) begin
                o_greater = 1'b1;
                o_less = 1'b0;
                o_equal = 1'b0;
            end else if (unsigned_A < unsigned_B) begin
                o_greater = 1'b0;
                o_less = 1'b1;
                o_equal = 1'b0;
            end else begin
                o_greater = 1'b0;
                o_less = 1'b0;
                o_equal = 1'b1;
            end
        end else begin
            o_greater = 1'b0;
            o_less = 1'b0;
            o_equal = 1'b0;
        end
    end
endmodule
