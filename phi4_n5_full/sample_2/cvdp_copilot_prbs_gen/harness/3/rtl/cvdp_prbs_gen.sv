module cvdp_prbs_gen #(
    parameter int CHECK_MODE   = 0,  // 0 = Generator Mode, 1 = Checker Mode
    parameter int POLY_LENGTH  = 31, // Length of the LFSR (number of stages)
    parameter int POLY_TAP     = 3,  // Tap position (1-indexed; must be <= POLY_LENGTH)
    parameter int WIDTH        = 16  // Data bus width
)(
    input  logic         clk,
    input  logic         rst,           // Active high synchronous reset
    input  logic [WIDTH-1:0] data_in,    // In generator mode, expected to be all zeros
    output logic [WIDTH-1:0] data_out    // In generator mode: PRBS pattern; in checker mode: error flags
);

    // Internal LFSR register (width = POLY_LENGTH)
    logic [POLY_LENGTH-1:0] prbs_reg;

    // Synchronous process: LFSR update and output generation
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // On reset: initialize PRBS register to all ones and set data_out to all ones
            prbs_reg <= {POLY_LENGTH{1'b1}};
            data_out <= {WIDTH{1'b1}};
        end else begin
            // Compute feedback bit:
            // Note: Using 1-indexed positions: bit at POLY_TAP is prbs_reg[POLY_TAP-1]
            // and the MSB is prbs_reg[POLY_LENGTH-1].
            logic fb;
            fb = prbs_reg[POLY_TAP-1] ^ prbs_reg[POLY_LENGTH-1];
            
            // Update LFSR: shift right and insert feedback bit at MSB
            prbs_reg <= {fb, prbs_reg[POLY_LENGTH-1:1]};
            
            // Mode-dependent output assignment
            if (CHECK_MODE == 0) begin
                // Generator Mode: Output the generated PRBS pattern (lower WIDTH bits of LFSR)
                data_out <= prbs_reg[WIDTH-1:0];
            end else begin
                // Checker Mode: Compare input data with the generated PRBS pattern.
                // The XOR result will be non-zero if there is any bit mismatch.
                data_out <= data_in ^ prbs_reg[WIDTH-1:0];
            end
        end
    end

endmodule