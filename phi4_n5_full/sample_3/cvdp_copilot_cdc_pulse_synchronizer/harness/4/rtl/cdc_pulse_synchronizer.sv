module cdc_pulse_synchronizer (
    input  logic src_clock,   // Source Clock Domain
    input  logic des_clock,   // Destination Clock Domain
    input  logic rst_in,      // Reset
    input  logic src_pulse,   // Source Pulse
    output logic des_pulse    // Destination Pulse
);

    // Pulse generation in source domain (one-shot pulse)
    logic pulse_reg;
    // Synchronized pulse registers in destination domain
    logic pulse_reg_sync_a;
    logic pulse_reg_sync_b;

    // Generate a one-shot pulse in src clock domain
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in)
            pulse_reg <= 1'b0;
        else if (src_pulse)
            pulse_reg <= 1'b1;
        else
            pulse_reg <= 1'b0;
    end

    // First stage of synchronization
    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in)
            pulse_reg_sync_a <= 1'b0;
        else
            pulse_reg_sync_a <= pulse_reg;
    end

    // Second stage of synchronization
    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in)
            pulse_reg_sync_b <= 1'b0;
        else
            pulse_reg_sync_b <= pulse_reg_sync_a;
    end

    // Detect rising edge of synchronized pulse (pulse width one clock cycle)
    assign des_pulse = pulse_reg_sync_a ^ pulse_reg_sync_b;

endmodule