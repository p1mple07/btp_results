module cvdp_prbs_gen #(parameter POLY_LENGTH = 31, parameter POLY_TAP = 3, parameter WIDTH = 16)
(
    input clk,
    input rst,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out,
    parameter int CHECK_MODE = 0
);

    // Internal signals
    reg [POLY_LENGTH-1:0] prbs_reg [WIDTH-1:0];
    reg [POLY_TAP-1:0] taps;

    // Parameter validation
    always @* begin
        if (POLY_TAP < 0 || POLY_TAP > POLY_LENGTH) begin
            $error("POLY_TAP must be a positive integer and less than POLY_LENGTH");
        end
        if (POLY_LENGTH < POLY_TAP || POLY_LENGTH < WIDTH) begin
            $error("POLY_LENGTH must be greater than or equal to POLY_TAP and WIDTH");
        end
    end

    // Reset behavior
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prbs_reg = {WIDTH{1'b1}};
            data_out = {WIDTH{1'b1}};
        end else begin
            case (CHECK_MODE)
                0: // Generator Mode
                    // Initialize LFSR taps based on POLY_TAP
                    taps = {POLY_TAP{1'b1}, (POLY_TAP-1:0)(1'b0)};
                    // Generate PRBS in LFSR
                    for (int i = 0; i < WIDTH; i++) begin
                        prbs_reg[i] = prbs_reg[i-1] >> 1;
                        prbs_reg[i] = prbs_reg[i] ^ prbs_reg[taps];
                    end
                    data_out = prbs_reg;
                1: // Checker Mode
                    // Generate expected PRBS in LFSR
                    for (int i = 0; i < WIDTH; i++) begin
                        prbs_reg[i] = prbs_reg[i-1] >> 1;
                        prbs_reg[i] = prbs_reg[i] ^ prbs_reg[taps];
                    end
                    // Compare input data with generated PRBS
                    data_out = data_in ^ prbs_reg;
            endcase
        end
    end

endmodule
