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
        else if (src_pulse) begin
            pls_toggle <= ~pls_toggle;
        else begin
            pls_toggle <= 1'b0;
        end
    end

    //--------------------------------------------------
    //   Double Flop Bit Synchronizer
    //---------------------------------------------------

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            pls_toggle_synca <= 1'b0;
        else begin
            pls_toggle_synca <= pls_toggle;
        end
    end

    //--------------------------------------------------
    //   Delay Logic of Output signal
    //---------------------------------------------------

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            pls_toggle_syncc <= 1'b0;
        else begin
            pls_toggle_syncc <= pls_toggle_synca;
        end
    end

    //--------------------------------------------------
    //   Assign Statement for posedge and negedge detection
    //---------------------------------------------------

    assign des_pulse = pls_toggle_syncc ^ pls_toggle_synca;
    // Add a counter to ensure single pulse per source pulse
    logic counter;
    integer ratio = 2; // des_clock is 2.5x faster than src_clock
    always_comb begin
        if (rst_in) begin
            counter <= 0;
        else
            counter <= counter + 1;
        end
        // Only increment des_pulse when counter reaches ratio
        if (counter == ratio) begin
            des_pulse <= ~des_pulse;
            counter <= 0;
        end
    end
endmodule