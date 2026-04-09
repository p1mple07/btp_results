module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 4
)(
    input  logic src_clock,
    input  logic des_clock,
    input  logic rst_in,
    input  logic src_pulse[NUM_CHANNELS][1], // array of NUM_CHANNELS bits
    output logic [NUM_CHANNELS-1:0] des_pulse
);

    logic pls_toggle;
    logic pls_toggle_synca, pls_toggle_syncb, pls_toggle_syncc;
    logic rst_src_sync;
    logic rst_des_sync;
    logic rst_src_synca, rst_src_syncb;
    logic rst_des_synca, rst_des_syncb;

    // ... existing code ...

endmodule
