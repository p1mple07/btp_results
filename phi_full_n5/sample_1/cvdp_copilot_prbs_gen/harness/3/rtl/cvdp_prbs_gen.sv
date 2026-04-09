module cvdp_prbs_gen #(
    parameter WIDTH = 16,
    parameter POLY_LENGTH = 31,
    parameter POLY_TAP = 3
) (
    input clk,
    input rst,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    // Internal signals
    reg [POLY_LENGTH-1:0] prbs_reg;
    reg [WIDTH-1:0] expected_prbs;

    // LFSR feedback logic
    assign expected_prbs = ^(prbs_reg[POLY_TAP-1:0] ^ prbs_reg[POLY_LENGTH-1]);

    // Reset logic
    always_ff @(posedge clk) begin
        if (rst) begin
            prbs_reg <= {WIDTH{1'b1}};
            data_out <= {WIDTH{1'b1}};
        end
        else if (CHECK_MODE == 0) begin
            expected_prbs <= expected_prbs;
        end
    end

    // Generator logic
    always_ff @(posedge clk) begin
        if (CHECK_MODE == 0) begin
            prbs_reg <= {prbs_reg[WIDTH-POLY_TAP-1:0] << 1} | expected_prbs;
        end
    end

    // Checker logic
    always_ff @(posedge clk) begin
        if (CHECK_MODE == 1) begin
            if (data_in !== expected_prbs) begin
                data_out <= 1'b1; // Error detected
            end else begin
                data_out <= 1'b0; // No error
            end
        end
    end

endmodule
