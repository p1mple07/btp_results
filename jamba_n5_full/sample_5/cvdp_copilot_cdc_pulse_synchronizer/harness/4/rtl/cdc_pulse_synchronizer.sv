module cdc_pulse_synchronizer (
    input  logic src_clock,   // Source Clock Domain
    input  logic des_clock,   // Destination Clock Domain
    input  logic rst_in,      // Reset
    input  logic src_pulse,   // Source Pulse
    output logic des_pulse    // Destination Pulse
);

    logic pls_pulse;      
    logic pls_toggle;      
    logic pls_toggle_synca;
    logic pls_toggle_syncc;

    // Toggle on rising edge of source clock
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            pls_pulse <= 1'b0;
        end else if (src_pulse) begin
            pls_toggle <= ~pls_toggle;
        end else begin
            pls_toggle <= 1'b0;
        end
    end

    // Update toggle synchro on destination clock
    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            pls_toggle_synca <= 1'b0;
        end else begin
            pls_toggle_synca <= pls_toggle;
        end
    end

    // Sync the output to the destination clock
    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            pls_toggle_syncc <= 1'b0;
        end else begin
            pls_toggle_syncc <= pls_toggle_synca;
        end
    end

    // Final assignment to the output
    assign des_pulse = pls_pulse;

endmodule
