Module detect_sequence.sv
include "rtl/adder_2d_layers.sv"
include "rtl/adder_tree_2d.sv"
include "rtl/correlate.sv"

module detect_sequence #(
    parameter NS_DATA_IN      = 64,
    parameter NBW_PILOT_POS   = 6,
    parameter NBW_DATA_SYMB   = 8,
    parameter NBI_DATA_SYMB   = 7,
    parameter NBW_ENERGY      = 10,
    parameter NS_FAW           = 23,
    parameter NS_FAW_OVERLAP   = 22,
    parameter NBW_TH_FAW      = 10,
    parameter NBW_ENERGY      = 10
) (
    input  logic                               _clk,
    input  logic         [NBW_DATA_SYMB*NS_DATA_IN-1:0] i_data_i,
    input  logic         [NBW_DATA_SYMB*NS_DATA_IN-1:0] i_data_q,
    input  logic         [NS_DATA_IN-1:0]      i_enable,
    input  logic [NS_DATA_IN-1:0]               i_proc_pol,
    input  logic [NBW_PILOT_POS-1:0]        i_proc_pos,
    input  logic [NBW_DATA_SYMB-1:0]          i_static_threshold,
    input  logic [NBW_DATA_SYMB-1:0]          i_data符号_cw,
    output logic [NBW_ENERGY-1:0]             o_proc_detected,
    output logic [NBW_ENERGY-1:0]             o_energy
);

registers [
    logic signed [NBW_DATA_SYMB*NS_DATA_IN-1:0]  i_buffered_data
] i_buffered_data;

always_ff @(posedge _clk) begin
    if (i_enable && i_proc_pos) begin
        i_buffered_data <= i_data_i[ (i_proc_pos + 1)*NBW_DATA_SYMB - 1 : 0 ];
    end
end

correlate #(
    NS_DATA_IN       : NS_DATA_IN,
    NBW_DATA_SYMB    : NBW_DATA_SYMB,
    NBW_ADDER_TREE_IN : NBW_DATA_SYMB + 2
) cross_correlate(

    .i_data_i    : i_buffered_data[NS_DATA_IN*NBW_DATA_SYMB : NS_DATA_IN*NBW_DATA_SYMB + NS_DATA_IN - 1],
    .i_data_q    : i_buffered_data[NS_DATA_IN*NBW_DATA_SYMB + NS_DATA_IN : NS_DATA_IN*(NBW_DATA_SYMB + 1) - 1],
    .i_conj_seq_i : i_conj_seq_i,
    .i_conj_seq_q : i_conj_seq_q,

    .o_sum_i     : o_sum_i,
    .o_sum_q     : o_sum_q
);

always_ff @posedge _clk begin : process_energy
    if (i_enable && !o_energy_valid) begin
        o_energy_valid <= 1;
        o_energy <= cross_correlate.o_energy;
    end
end

always_ff @posedge _clk begin : process_detection
    if (o_energy > i_static_threshold && i_enable && !o_energy_valid) begin
        o_proc_detected <= 1;
        o_energy_valid <= 1;
    end
end
endmodule