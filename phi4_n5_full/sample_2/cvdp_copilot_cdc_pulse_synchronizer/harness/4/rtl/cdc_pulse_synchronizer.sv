module cdc_pulse_synchronizer (
    input  logic src_clock,   // Source Clock Domain
    input  logic des_clock,   // Destination Clock Domain
    input  logic rst_in,      // Reset
    input  logic src_pulse,   // Source Pulse
    output logic des_pulse    // Destination Pulse
);

    // Instead of toggling on src_pulse, we stretch the pulse in the source domain
    // so that it is at least one src_clock cycle wide.
    logic pulse_stretched;
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in)
            pulse_stretched <= 1'b0;
        else if (src_pulse)
            pulse_stretched <= 1'b1;
        else
            pulse_stretched <= 1'b0;
    end

    // Synchronize the stretched pulse to the destination clock domain using a double-flop synchronizer.
    logic pulse_sync1, pulse_sync2;
    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in)
            pulse_sync1 <= 1'b0;
        else
            pulse_sync1 <= pulse_stretched;
    end

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in)
            pulse_sync2 <= 1'b0;
        else
            pulse_sync2 <= pulse_sync1;
    end

    // Generate a single pulse on the rising edge of the synchronized signal.
    // This edge detector ensures that only one pulse is produced per src_pulse.
    logic pulse_sync_prev;
    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            des_pulse      <= 1'b0;
            pulse_sync_prev<= 1'b0;
        end else begin
            if (pulse_sync2 && !pulse_sync_prev)
                des_pulse <= 1'b1;
            else
                des_pulse <= 1'b0;
            pulse_sync_prev <= pulse_sync2;
        end
    end

endmodule