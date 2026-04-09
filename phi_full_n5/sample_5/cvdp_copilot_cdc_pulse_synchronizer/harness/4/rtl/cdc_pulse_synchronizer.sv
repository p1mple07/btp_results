module cdc_pulse_synchronizer (
    input  logic src_clock,   // Source Clock Domain
    input  logic des_clock,   // Destination Clock Domain
    input  logic rst_in,      // Reset
    input  logic src_pulse,   // Source Pulse
    output logic des_pulse    // Destination Pulse
);

    logic pls_toggle;      
    logic pls_toggle_synca;
    logic pls_toggle_syncc;

    //--------------------------------------------------
    //   Toggle Flop Circuit
    //---------------------------------------------------

    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            pls_toggle <= 1'b0;
        end else if (src_pulse) begin
            pls_toggle <= ~pls_toggle;
        end else begin
            pls_toggle <= 1'b0;
        end
    end

    //--------------------------------------------------
    //   Double Flop Bit Synchronizer
    //---------------------------------------------------

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            pls_toggle_synca <= 1'b0;
        end else begin
            pls_toggle_synca <= pls_toggle;
        end
    end

    //--------------------------------------------------
    //   Delay Logic of Output signal
    //---------------------------------------------------

    // Introduce a delay to account for the clock frequency difference
    // Assuming a 250 MHz / 100 MHz = 2.5 times faster des_clock
    // We need to introduce a delay equivalent to half the period of des_clock
    // to ensure that only one pulse from src_pulse is captured
    // by the synchronization circuit.
    // Since we cannot directly implement delays in RTL, we simulate the behavior
    // by introducing a register that captures the state of src_pulse
    // at the appropriate time.

    logic des_pulse_capture;

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            des_pulse_capture <= 1'b0;
        end else if (src_pulse) begin
            // Capture the state of src_pulse when the des_clock arrives
            // at the halfway point of its period (12.5 ns for 250 MHz)
            if (des_clock_half_period <= rising_edge(des_clock)) begin
                des_pulse_capture <= src_pulse;
            end
        end
    end

    // Assign Statement for posedge and negedge detection
    assign des_pulse = des_pulse_capture ^ pls_toggle_synca;
endmodule
