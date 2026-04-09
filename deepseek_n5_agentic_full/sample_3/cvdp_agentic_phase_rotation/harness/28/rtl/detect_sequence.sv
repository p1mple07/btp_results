module detect_sequence #(
    parameter NS = 64,
    parameter NBW_DATA_SYMB = 8,
    parameter NBI_DATA_SYMB = 2,
    parameter NS_FAW = 23,
    parameter NS_FAW_OVERLAP = 22
)
(
    input  logic                               _clk         ,
    input  logic                               [NS+NS_FAW_OVERLAP-1:0] i_data_i    ,
    input  logic [NS+NS_FAW_OVERLAP-1:0]       i_data_q    ,
    input  logic       [NS+NS_FAW_OVERLAP-1:0]   i_conj_seq_i,
    input  logic       [NS+NS_FAW_OVERLAP-1:0]   i_conj_seq_q,
    output logic [1:0]                         o_proc_detected
);

// Internal variables
reg signed [NBW_DATA_SYMB + NBI_DATA_SYMB -1 : 0] correlation_i_dff;
reg signed [NBW_DATA_SYMB + NBI_DATA_SYMB -1 : 0] correlation_q_dff;

// Enable pipeline stages
always_ff @(posedge _clk) begin : proc_enable_pipeline_dff
    if(i_enable) begin
        correlation_i_dff <= o_data_i;
        correlation_q_dff <= o_data_q;
    end 
end

// Energy computation
reg signed [2*(NBW_DATA_SYMB + NBI_DATA_SYMB) -1 : 0] energy_i;
reg signed [2*(NBW_DATA_SYMB + NBI_DATA_SYMB) -1 : 0] energy_q;
reg unsigned [32] o_energy;

wire signed [NBW_DATA_SYMB + NBI_DATA_SYMB -1 : 0] correlation_i;
wire signed [NBW_DATA_SYMB + NBI_DATA_SYMB -1 : 0] correlation_q;

// Adder layers
adder_2d_layers #(
    .NBW_IN   (NBW_DATA_SYMB + NBI_DATA_SYMB),
    .NS_IN    (NS + NS_FAW_OVERLAP),
    .N_LEVELS (7),
    .REGS     (8'b10001000),
    .NBW_ENERGY (5),
    .NBW_adder_tree_out (8)
) uu_adder_2d_layers (
    .clk       (_clk),
    .i_enable  (i_enable),
    .i_data_i  (correlation_i_dff),
    .i_data_q  (correlation_q_dff),
    .o_data_i  (correlation_i),
    .o_data_q  (correlation_q),
    .o_energy (o_energy)
);

// Final stage logic
always ff @(posedge _clk) begin : proc_detection_logic
    if(i_enable && ((o_energy >> 5) & 3) > ((NBW_ENERGY >> 2) & 3)) begin
        o_proc_detected <= 1;
    end 
end