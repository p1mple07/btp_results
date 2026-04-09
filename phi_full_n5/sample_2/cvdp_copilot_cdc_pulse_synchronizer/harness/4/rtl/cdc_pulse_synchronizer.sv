module cdc_pulse_synchronizer (
    input  logic src_clock,   // Source Clock Domain
    input  logic des_clock,   // Destination Clock Domain
    input  logic rst_in,      // Reset
    input  logic src_pulse,   // Source Pulse
    output logic des_pulse    // Destination Pulse
);

    logic pls_toggle;      

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
            pls_toggle <= 1'b0;
        end else begin
            pls_toggle <= pls_toggle; // Maintain the current state, no need to toggle
        end
    end

    //--------------------------------------------------
    //   Delay Logic of Output signal
    //---------------------------------------------------

    assign des_pulse = pls_toggle ^ 1'b1; // Ensure the output is toggled once
endmodule
