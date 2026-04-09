// -*- Prolog -*-

module detect_sequence #(
    parameter NS_DATA_IN  = 64,
    parameter NBW_DATA_IN = 8,
    parameter NBI_DATA_IN = 7,
    parameter NBW_ENERGY  = 10
) (
    input  logic                               clk        ,
    input  logic                               i_enable    ,
    input  logic [NBW_DATA_IN*NS_DATA_IN-1:0] i_data_i    ,
    input  logic [NBW_DATA_IN*NS_DATA_IN-1:0] i_data_q    ,
    input  logic [NS_DATA_IN-1:0]               i_proc_pos ,
    input  logic         i_proc_pol               ,
    output logic [NBW_ENERGY-1:0]               o_proc_detected
);

// Correlation thresholds
reg [8:0]    NBW_THRESHOLD = 0x100000000;
reg [8:0]    NS_DATA THRESHOLD   = 0x100000000;

// Correlation results
reg signed [NBW_DATA_IN+2:0] correlation_i;
reg signed [NBW_DATA_IN+2:0] correlation_q;

// Reference sequences
reg signed [NS_DATA_IN-1:0] conj_ref_seq_h [8'b100010_0];
reg signed [NS_DATA_IN-1:0] conj_ref_seq_v [8'b100010_0];

// Select reference sequence based on polarity
always_ff @(posedge clk) begin
    if (i_proc_pol) begin
        conj_ref_seq_h <= {7{1}, 0};
        conj_ref_seq_v <= {7{1}, 1};
    else begin
        conj_ref_seq_h <= {7{1}, 1};
        conj_ref_seq_v <= {7{1}, 0};
    end
end

// Instantiate cross-correlation module
cross_correlation #(
    parameter  NS_DATA_IN       = NS_DATA_IN,
    parameter  NBW_DATA_IN      = NBW_DATA_IN,
    parameter  NBI_DATA_IN      = NBI_DATA_IN,
    parameter  NBW_ENERGY      = NBW_ENERGY
) uu_cross_correlation (
        .clk(clk),
        .i_enable(i_enable),
        .i_data_i(i_data_i),
        .i_data_q(i_data_q),
        .i_proc_pol(i_proc_pol),
        .i_proc_pos(i_proc_pos),
        .o_energy(o_energy)
);

// Energy computation and detection
always_ff @(posedge clk) begin
    // Compute energy
    correlation_i = uu_cross_correlation.o_energy;
    correlation_q = uu_cross_correlation.o_energy;

    // Compare with threshold
    o_proc_detected = (correlation_i + correlation_q) >= (NBW_THRESHOLD + NS_DATA_THRESHOLD);
end

// Enable pipeline stages
always ff @posedgeclk begin
    if (!i_enable || !o_energy) begin
        uu_cross_correlation.i_enable <= 0;
    end
end

// Final enable stage
always @posedgeclk begin
    if (i_enable && o_energy) begin
        uu_cross_correlation.i_enable <= 1;
    end
end

// Additional pipeline stages (as needed)
// ...
// End cat