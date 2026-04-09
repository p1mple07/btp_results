module cvdp_prbs_gen #(
    parameter INT CHECK_MODE = 0,
    parameter INT POLY_LENGTH = 31,
    parameter INT POLY_TAP = 3,
    parameter INT WIDTH = 16
)(
    input logic clk,
    input logic rst,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);

// Internal signals
logic [WIDTH-1:0] prbs;
logic [WIDTH-1:0] temp;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        prbs <= 1'b1 << WIDTH; // all ones
        data_out <= 1'b1;
    end else begin
        case (CHECK_MODE)
            CASE_GENERATE: begin
                // For generator mode: update PRBS
                temp = prbs >> 1;
                temp[WIDTH-1] = prbs[WIDTH-1] ^ ((prbs[POLY_LENGTH] & (1'bz)) ? 1 : 0);
                prbs <= temp;
                data_out = 1'b0; // generator mode outputs 0
            end
            CASE_CHECK: begin
                // Checker mode: compare data_in with prbs
                data_out = (~data_in) & (~prbs); // XOR to detect mismatch
            end
        endcase
    end
endalways

endmodule
