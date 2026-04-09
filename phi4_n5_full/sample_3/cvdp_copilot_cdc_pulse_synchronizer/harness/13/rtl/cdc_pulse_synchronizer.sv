// File: rtl/cdc_pulse_synchronizer.sv
//
// This module has been modified to support NUM_CHANNELS independent pulse signals.
// Each channel’s single‐cycle pulse in the source clock domain is converted into a toggle,
// transferred to the destination clock domain using a two‐stage CDC synchronizer, and then
// an edge is detected to produce the synchronized pulse output.
//
// NOTE: In a real design the transfer of a signal (src_toggle) from the source clock domain
// to the destination clock domain requires a proper CDC synchronizer (e.g. a dual‐clock FIFO
// or handshake). For the purposes of this exercise the structure follows the original code’s
// approach.

module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 1
) (
    input  logic src_clock,         // Source clock domain
    input  logic des_clock,         // Destination clock domain
    input  logic rst_in,            // Asynchronous active-HIGH reset (resets all signals to 0)
    input  logic [NUM_CHANNELS-1:0] src_pulse,  // Vector of single-cycle pulses in src_clock domain
    output logic [NUM_CHANNELS-1:0] des_pulse   // Vector of synchronized pulses in des_clock domain
);

    //-------------------------------------------------------------------------
    // Synchronize reset in the source domain
    //-------------------------------------------------------------------------
    logic rst_src_sync;
    logic rst_src_synca, rst_src_syncb;
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_src_synca <= 1'b1;
            rst_src_syncb <= 1'b1;
        end else begin
            rst_src_synca <= 1'b0;
            rst_src_syncb <= rst_src_synca;
        end
    end
    assign rst_src_sync = rst_src_syncb;

    //-------------------------------------------------------------------------
    // Synchronize reset in the destination domain
    //-------------------------------------------------------------------------
    logic rst_des_sync;
    logic rst_des_synca,