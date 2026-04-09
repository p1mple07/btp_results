module cvdp_prbs_gen #(parameter WIDTH = 16, parameter POLY_LENGTH = 31, parameter POLY_TAP = 3)
(
    input clk,
    input rst,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    // Internal signals
    reg [POLY_LENGTH-1:0] prbs_reg;
    reg [POLY_TAP-1:0] taps_reg;

    // Reset behavior
    always_ff @(posedge clk) begin
        if (rst) begin
            prbs_reg <= {WIDTH{1'b1}};
            taps_reg <= {POLY_TAP{1'b1}};
            data_out <= {WIDTH{1'b1}};
        end else begin
            data_out <= prbs_reg;
        end
    end

    // Generator mode (CHECK_MODE = 0)
    always_ff @(posedge clk) begin
        if (CHECK_MODE == 0) begin
            taps_reg = {POLY_TAP{1'b1}};
            prbs_reg <= {POLY_TAP{1'b0}, ^(taps_reg & prbs_reg)};
        end
    end

    // Checker mode (CHECK_MODE = 1)
    always_ff @(posedge clk) begin
        if (CHECK_MODE == 1) begin
            taps_reg = {POLY_TAP{1'b1}};
            prbs_reg <= {POLY_TAP{1'b0}, ^(taps_reg & prbs_reg)};
            data_out = (data_in != prbs_reg);
        end
    end

endmodule
