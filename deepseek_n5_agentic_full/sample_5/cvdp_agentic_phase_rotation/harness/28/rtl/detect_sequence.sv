module and connections
module detect_sequence #(
    parameter NS,
    parameter NBW_DATA_SYMB,
    parameter NBI_DATA_SYMB,
    parameter NBW_TH_FAW,
    parameter NBW_ENERGY,
    parameter NS_FAW,
    parameter NS_FAW_OVERLAP
) (
    input  logic                                clk,
    input  logic                               i_enable,
    input  logic [NBW_DATA_SYMB*NS-1:0]        i_data_i,
    input  logic [NBW_DATA_SYMB*NS-1:0]        i_data_q,
    output logic [NBW_ENERGY-1:0]             o_energy,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         awd_data_i,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         awd_data_q,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_wdata_i,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_wdata_q,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_data_i,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_data_q,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_data_i,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_data_q,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_data_i,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_data_q,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_data_i,
    wire  logic [NBW_DATA_SYMB*NS-1:0]         i_data_q,

    // Instantiate cross_correlation module
    cross_correlation #(
        .NS_DATA_IN (NS),
        .NBW_DATA_IN (NBW_DATA_SYMB),
        .NBI_DATA_IN (NBI_DATA_SYMB),
        .NBW_TH_FAW (NBW_TH_FAW),
        .NBW_ENERGY (NBW_ENERGY),
        .NS_FAW (NS_FAW),
        .NS_FAW_OVERLAP (NS_FAW_OVERLAP)
    ) (
        .clk (clk),
        .i_enable (i_enable),
        .i_data_i (awd_data_i),
        .i_data_q (awd_data_q),
        .i_conj_seq_i (i_wdata_i),
        .i_conj_seq_q (i_wdata_q),
        .o_energy (o_energy)
    );
endmodule