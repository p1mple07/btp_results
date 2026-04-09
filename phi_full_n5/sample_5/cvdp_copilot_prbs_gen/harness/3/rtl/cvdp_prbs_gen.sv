module cvdp_prbs_gen #(parameter POLY_LENGTH = 31, parameter POLY_TAP = 3, parameter WIDTH = 16)
(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    // Internal signals
    reg [POLY_LENGTH-1:0] prbs_register;
    reg [POLY_TAP-1:0] feedback;
    reg [POLY_TAP-1:0] tap_registers [POLY_TAP-1:0];

    // Reset behavior
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            prbs_register <= {WIDTH{1'b1}};
            data_out <= {WIDTH{1'b1}};
            for (int i = 0; i < POLY_TAP; i++) begin
                tap_registers[i] <= 1'b1;
            }
        end
    end

    // Generator mode
    always_ff @(posedge clk) begin
        if (CHECK_MODE == 0) begin
            feedback = tap_registers[POLY_TAP] ^ prbs_register[POLY_LENGTH-1];
            prbs_register <= {feedback{1'b1}, prbs_register[WIDTH-1:1]};
            data_out = feedback;
        end
    end

    // Checker mode
    always_ff @(posedge clk) begin
        if (CHECK_MODE == 1) begin
            feedback = tap_registers[POLY_TAP] ^ prbs_register[POLY_LENGTH-1];
            prbs_register <= {feedback{1'b1}, prbs_register[WIDTH-1:1]};
            data_out = (data_in ^ feedback) & {WIDTH{1'b1}};
        end
    end

endmodule
