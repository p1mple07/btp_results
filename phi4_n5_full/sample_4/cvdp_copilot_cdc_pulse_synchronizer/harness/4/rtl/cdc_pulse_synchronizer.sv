module cdc_pulse_synchronizer (
    input  logic src_clock,   // Source Clock Domain
    input  logic des_clock,   // Destination Clock Domain
    input  logic rst_in,      // Reset
    input  logic src_pulse,   // Source Pulse (level‐sensitive)
    output logic des_pulse    // Destination Pulse
);

    // Internal signals for toggling and synchronization
    logic pls_toggle;
    logic pls_toggle_synca;
    logic pls_toggle_syncc;
    logic src_pulse_d; // Registered version of src_pulse for edge detection
    logic pulse;       // One-cycle pulse generated on rising edge of src_pulse

    //----------------------------------------------------------------
    // Register src_pulse to detect its rising edge
    //----------------------------------------------------------------
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in)
            src_pulse_d <= 1'b0;
        else
            src_pulse_d <= src_pulse;
    end

    // Generate a one-cycle pulse on the rising edge of src_pulse
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in)
            pulse <= 1'b0;
        else if (src_pulse && ~src_pulse_d)
            pulse <= 1'b1;
        else
            pulse <= 1'b0;
    end

    //----------------------------------------------------------------
    // Toggle flop in source domain: Toggle only on the one-cycle pulse
    //----------------------------------------------------------------
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in)
            pls_toggle <= 1'b0;
        else if (pulse)
            pls_toggle <= ~pls_toggle;
    end

    //----------------------------------------------------------------
    // Double flop synchronizer in destination domain
    //----------------------------------------------------------------
    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in)
            pls_toggle_synca <= 1'b0;
        else
            pls_toggle_synca <= pls_toggle;
    end

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in)
            pls_toggle_syncc <= 1'b0;
        else
            pls_toggle_syncc <= pls_toggle_synca;
    end

    //----------------------------------------------------------------
    // Generate the destination pulse using XOR of the two synchronizer stages
    //----------------------------------------------------------------
    assign des_pulse = pls_toggle_syncc ^ pls_toggle_synca;

endmodule