module cdc_pulse_synchronizer (
    input  logic src_clock,   // Source Clock Domain
    input  logic des_clock,   // Destination Clock Domain
    input  logic rst_in,      // Reset
    input  logic src_pulse,   // Source Pulse
    output logic des_pulse    // Destination Pulse
);

    //-------------------------------------------------------------------------
    // Generate a one-cycle pulse in the source clock domain.
    // The original design toggled a signal and then synchronized it,
    // which—due to the asynchronous clock domains—resulted in two pulses.
    // The fix is to generate a pulse that is high for exactly one src_clock cycle.
    //-------------------------------------------------------------------------
    logic pulse_sync;
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in)
            pulse_sync <= 1'b0;
        else if (src_pulse)
            pulse_sync <= 1'b1;
        else
            pulse_sync <= 1'b0;
    end

    //-------------------------------------------------------------------------
    // Double-flop synchronizer in the destination clock domain.
    // This chain safely transfers the pulse from src_clock to des_clock.
    //-------------------------------------------------------------------------
    logic pulse_sync_ff1, pulse_sync_ff2;
    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            pulse_sync_ff1 <= 1'b0;
            pulse_sync_ff2 <= 1'b0;
        end else begin
            pulse_sync_ff1 <= pulse_sync;
            pulse_sync_ff2 <= pulse_sync_ff1;
        end
    end

    //-------------------------------------------------------------------------
    // Generate a one-cycle pulse in the destination clock domain.
    // Using an AND gate (pulse_sync_ff1 & ~pulse_sync_ff2) ensures that
    // the pulse is generated for exactly one des_clock cycle.
    //-------------------------------------------------------------------------
    assign des_pulse = pulse_sync_ff1 & ~pulse_sync_ff2;

endmodule