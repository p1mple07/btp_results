module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 4 // Parameter to define the number of independent pulse channels
) (
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic src_pulse[NUM_CHANNELS-1:0], // Vector of single-cycle pulse signals (NUM_CHANNELS wide) in the source clock domain
    output logic des_pulse[NUM_CHANNELS-1:0] // Vector of synchronized single-cycle pulse signals (NUM_CHANNELS wide) in the destination clock domain
);

    logic pls_toggle[NUM_CHANNELS-1:0]; // Toggle signals for each channel
    logic pls_toggle_synca[NUM_CHANNELS-1:0];
    logic pls_toggle_syncb[NUM_CHANNELS-1:0];
    logic rst_src_sync[NUM_CHANNELS-1:0];
    logic rst_des_sync[NUM_CHANNELS-1:0];

    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_src_synca <= {1'b1, 1'b0{NUM_CHANNELS-1{1'b0}}}
            rst_src_syncb <= rst_src_synca
            rst_des_synca <= {1'b1, 1'b0{NUM_CHANNELS-1{1'b0}}}
            rst_des_syncb <= rst_des_synca
        end else begin
            rst_src_synca <= {1'b0, 1'b0{NUM_CHANNELS-1{1'b1}}}
            rst_src_syncb <= rst_src_synca
            rst_des_synca <= {1'b0, 1'b0{NUM_CHANNELS-1{1'b1}}}
            rst_des_syncb <= rst_des_synca
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_sync[NUM_CHANNELS-1]) begin
        if (rst_des_sync[NUM_CHANNELS-1]) begin
            pls_toggle_synca[NUM_CHANNELS-1:0] <= {1'b0, 1'b0{NUM_CHANNELS-1{1'b0}}}
            pls_toggle_syncb[NUM_CHANNELS-1:0] <= pls_toggle_synca
            pls_toggle_syncc[NUM_CHANNELS-1:0] <= pls_toggle_syncb
        end else begin
            pls_toggle_synca[NUM_CHANNELS-1:0] <= pls_toggle
            pls_toggle_syncb[NUM_CHANNELS-1:0] <= pls_toggle_synca
            pls_toggle_syncc[NUM_CHANNELS-1:0] <= pls_toggle_syncb
        end
    end

    assign des_pulse[NUM_CHANNELS-1:0] = pls_toggle_syncc ^ pls_toggle_syncb;

endmodule
