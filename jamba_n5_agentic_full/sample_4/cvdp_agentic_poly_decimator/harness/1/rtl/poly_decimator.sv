// ------------------------------------------------------------
// poly_decimator.v
// ------------------------------------------------------------
module poly_decimator #(
    parameter M = 4,      // Decimation factor
    parameter DATA_WIDTH  = 16
)(
    input  logic         clk,
    input  logic         arst_n,
    input  logic [DATA_WIDTH-1:0] in_sample,
    input  logic         valid_in,
    output logic [DATA_WIDTH-1:0] out_sample,
    output logic         out_valid
);

import rtl::addertree::*;
import rtl::shift_register::*;
import rtl::coeff_ram::*;
import rtl::poly_filter::*;

// Local declarations
localparam NUM_INPUTS = 1;   // Only one input sample per decimation step
localparam ACC_WIDTH   = DATA_WIDTH + COEFF_WIDTH + $clog2(TAPS);
localparam TAPS        = 8;    // Same as in the example

// Module instances
Wire mem_addr;
logic [DATA_WIDTH-1:0] sample_reg [0:TAPS-1];
logic [$clog2(M)-1:0] phase_reg;
logic valid_stage0, valid_stage1, valid_adder;

ShiftRegister shift_reg #(.TAPS(TAPS)) (
    .clk(clk),
    .arst_n(arst_n),
    .load(valid_in),
    .new_sample(in_sample),
    .data_out(sample_reg[0]),
    .data_out_val(valid_stage0)
);

CoeffRam coeff_ram (
    .NUM_COEFFS(M*TAPS),
    .DATA_WIDTH(COEFF_WIDTH)
);

PolyFilter poly_filter_inst (
    .M(M),
    .TAPS(TAPS),
    .COEFF_WIDTH(COEFF_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
);

AdderTree adder_tree_inst (
    .NUM_INPUTS(TAPS),
    .DATA_WIDTH(DATA_WIDTH + COEFF_WIDTH)
);

always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        for (integer i = 0; i < TAPS; i = i + 1)
            sample_reg[i] <= '0;
        phase_reg    <= '0;
        valid_stage0 <= 1'b0;
    end
    else begin
        if (valid_in) begin
            for (integer i = 0; i < TAPS; i = i + 1)
                sample_reg[i] <= sample_buffer[i];
            phase_reg    <= phase;
            valid_stage0 <= 1'b1;
        end
        else begin
            valid_stage0 <= 1'b0;
        end
    end
end

always_comb begin
    // Stage 0: register input
    sample_reg[0] <= in_sample;
    phase_reg <= valid_stage0;

    // Stage 1: coefficient fetch
    for (integer j = 0; j < TAPS; j = j + 1)
        coeff[j] = coeff_ram.coeff[j];

    // Stage 2: multiplication
    for (integer k = 0; k < TAPS; k = k + 1)
        products[k] = sample_reg[k] * coeff[k];

    // Stage 3: sum with adder_tree
    sum_result = adder_tree_inst.sum_out;

    // Stage 4: output registration
    out_sample   = sum_result;
    out_valid    = valid_adder;
end

endmodule
