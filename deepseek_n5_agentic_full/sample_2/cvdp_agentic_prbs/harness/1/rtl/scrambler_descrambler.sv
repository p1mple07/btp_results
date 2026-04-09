Module header
module scrambler_descrambler (
    parameter POLY_LENGTH = 31,
    parameter POLY_TAP = 3,
    parameter WIDTH = 16,
    input     clk,
    input     rst,
    input     bypass_scrambling,
    input     data_in,
    input     valid_in,
    output    data_out,
    output    valid_out,
    output    bit_count
);

// Instantiate the PRBS generator/checker module
parameter CHECK_MODE = 0;
prbs_gen_check prbs_generator (
    .clk(clk),
    .rst(rst),
    .data_in(zero), // Send 0 during generator mode
    .data_out(data_out),
    .CHECK_MODE(CHECK_MODE),
    .POLY_LENGTH(POLY_LENGTH),
    .POLY_TAP(POLY_TAP),
    .WIDTH(WIDTH)
);

// Instantiate the PRBS generator/checker module in checker mode
parameter CHECK_MODE_CHECKER = 1;
prbs_gen_check prbs_checker (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .data_out(data_out),
    .CHECK_MODE(CHECK_MODE_CHECKER),
    .POLY_LENGTH(POLY_LENGTH),
    .POLY_TAP(POLY_TAP),
    .WIDTH(WIDTH)
);

// Bypass scrambling logic
always_ff @ (posedge clk) begin
    if (bypass_scrambling) begin
        data_out <= data_in;
        valid_out <= 1;
    end else begin
        // Scrambling/descrambling logic
        if (rst) begin
            prbs_generatorrst asserted, prbs_checker also asserted?
            prbs_generatorrst prbs_generator.rst prbs_checker.rst;
            data_out <= z;
            valid_out <= 0;
        end else begin
            // Generator mode: send 0 to data_in
            if (CHECK_MODE == 0) {
                prbs_generator.data_in = z;
            } else if (CHECK_MODE == 1) {
                prbs_checker.data_in = data_in;
            }
            
            // Always update data_out
            data_out <= prbs_generator.data_out;
        end
    end
end

// Counter for bit count
always @* begin
    if (valid_in) begin
        bit_count += WIDTH;
    end
end

// Signal assertions for testing purposes
wire asserts_bit_count(bit_count);
endmodule