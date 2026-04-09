// Module detect_sequence.sv
include "rtl/core/arithmetic.h"
include "rtl/adder_2d_layers.h"
include "rtl/correlate.h"

module detect_sequence (
    parameter NS = 64, // Number of pilot symbols
    parameter NBW_DATA_SYMB = 8, // Bit width of each I/Q data sample
    parameter NBI_DATA_SYMB = 2, // Integer bits in the data
    parameter NBW_ENERGY = 10, // Bit width of the final energy output
    parameter NS_DATA_IN = NS, // Number of input data samples
    parameter NBW_TH_FAW = NBW_DATA_SYMB + 2, // Bit width of static threshold
    parameter NBW_ENERGY = 10 // Bit width of energy output
) 
(
    input logic [NBW_DATA_SYMB*NS_DATA_IN-1:0] i_data_i, // Flattened I input samples
    input logic [NBW_DATA_SYMB*NS_DATA_IN-1:0] i_data_q, // Flattened Q input samples
    input logic [NBW_DATA_SYMB:NS_DATA_IN-1:0] i_conj_seq_i, // Conjugate reference sequence (Real parts)
    input logic [NBW_DATA_SYMB:NS_DATA_IN-1:0] i_conj_seq_q, // Conjugate reference sequence (Imaginary parts)
    output logic [NBW_ENERGY-1:0] o_energy // Energy output
);

localparam ADDER_2D_LAYERS_PARAM = `NBW_IN=$NS_DATA_IN, 
    NS_IN=$NS, 
    N_LEVELS=`clog2($NS), 
    REGS=8'b100010_0,
    NBW_ADDER_TREE_OUT=8,
    NBW_ENERGY=$NBW_ENERGY`;

localparam CORRELATE_PARAM = `NS_DATA_IN=$NS_DATA_IN, 
    NBW_DATA_IN=$NBW_DATA_SYMB, 
    NBI_DATA_IN=$NBI_DATA_SYMB, 
    NBW_ADDER_TREE_IN=$NBW_DATA_SYMB + 2,
    NBW_ADDER_TREE_OUT=8,
    NBW_ENERGY=$NBW_ENERGY`;

localparam ADDER_TREE_PARAM = `NBW_IN=$NS_DATA_IN, 
    NS_IN=$NS, 
    N_LEVELS=`clog2($NS), 
    REGS=8'b100010_0,
    NBW_ADDER_TREE_OUT=8,
    NBW_ENERGY=$NBW_ENERGY`;

reg param i_enable ($NS_DATA_IN*NBW_DATA_SYMB);
reg param i_valid ($NS_DATA_IN*NBW_DATA_SYMB);
reg param i correlated ($NS_DATA_IN*NBW_DATA_SYMB);

always_comb begin 
    if ($rst) begin 
        i_enable = 1;
        i_valid = 1;
        o_energy = 0;
    else 
        o_energy = 0;
    end 
end

always_ff @(posedge clk) begin 
    if (i_enable && i_valid) 
        i correlated <= i_data_i;
    end 
end

// Instantiate cross-correlation module
cross_correlation #(
    .NS_DATA_IN ($NS_DATA_IN),
    .NBW_DATA_IN ($NBW_DATA_SYMB),
    .NBI_DATA_IN ($NBI_DATA_SYMB),
    .NBW_ENERGY ($NBW_ENERGY)
) uu_correlate (
    .i_enable (i_enable),
    .i_data_i (i_data_i),
    .i_data_q (i_data_q),
    .i_conj_seq_i (i_conj_seq_i),
    .i_conj_seq_q (i_conj_seq_q),
    .o_energy ($o_energy)
);

// Instantiate adder_2d_layers module
adder_2d_layers #(
    .NBW_IN ($NS_DATA_IN),
    .NS_IN ($NS),
    .N_LEVELS (`clog2($NS)),
    .REGS=8'b100010_0,
    .NBW_ADDER_TREE_OUT=8,
    .NBW_ENERGY=$NBW_ENERGY
) uu_adder_2d_layers (
    .clk (clk),
    .i_enable (i_enable),
    .i_data_i (correlated_i),
    .i_data_q (correlated_q),
    .o_data_i (correlation_i),
    .o_data_q (correlation_q),
    .o_energy (o_energy)
);

// Final stage setup
if ($rst) 
    uu_adder_2d_layers.en = 1;
end