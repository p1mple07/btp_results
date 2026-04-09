module cvdp_prbs_gen #(
    parameter int POLY_LENGTH = 31,
    parameter int POLY_TAP = 3,
    parameter int WIDTH = 16
) (
    input logic clk,
    input logic rst,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);

    // Internal signals
    logic [POLY_LENGTH-1:0] prbs_register [WIDTH-1:0];
    logic [POLY_LENGTH-1:0] feedback_bit;

    // Internal state
    logic [WIDTH-1:0] expected_prbs;

    // Parameter constraints
    always @* begin
        if (POLY_TAP > POLY_LENGTH) begin
            $error("POLY_TAP must be less than or equal to POLY_LENGTH");
        end
        if (POLY_TAP < 0) begin
            $error("POLY_TAP must be a positive integer");
        end
        if (WIDTH < 1) begin
            $error("WIDTH must be a positive integer");
        end
    end

    // Generator Mode
    always_ff @(posedge clk) begin
        if (rst) begin
            prbs_register <= {WIDTH{1'b1}};
            feedback_bit <= 0;
        end else if (CHECK_MODE == 0) begin
            feedback_bit = prbs_register[POLY_TAP] ^ prbs_register[POLY_LENGTH];
            prbs_register <= {feedback_bit{WIDTH-1}} << 1;
            expected_prbs <= prbs_register;
        end
    end

    // Checker Mode
    always_ff @(posedge clk) begin
        if (rst) begin
            data_out <= 0;
        end else if (CHECK_MODE == 1) begin
            feedback_bit = prbs_register[POLY_TAP] ^ prbs_register[POLY_LENGTH];
            prbs_register <= {feedback_bit{WIDTH-1}} << 1;
            expected_prbs <= prbs_register;
            data_out = data_in ^ expected_prbs;
        end
    end

endmodule
