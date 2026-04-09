module cdc_pulse_synchronizer (
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic src_pulse,       // Source Pulse (NUM_CHANNELS-bit)
    output logic des_pulse        // Destination Pulse (NUM_CHANNELS-bit)
);

    parameter NUM_CHANNELS = 4;  // Number of independent pulse channels

    logic pls_toggle[NUM_CHANNELS];  // Toggle signal for each channel
    logic rst_src_sync[NUM_CHANNELS];  // Source reset state for each channel
    logic rst_des_sync[NUM_CHANNELS];  // Destination reset state for each channel

    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_src_sync[i] <= 1'b1 for all i in 0..NUM_CHANNELS-1;
        else begin
            rst_src_sync[i] <= rst_src_sync[i] & ~rst_in for all i in 0..NUM_CHANNELS-1;
        end
    end

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_des_sync[i] <= 1'b1 for all i in 0..NUM_CHANNELS-1;
        else begin
            rst_des_sync[i] <= rst_des_sync[i] & ~rst_in for all i in 0..NUM_CHANNELS-1;
        end
    end

    always_ff @(posedge src_clock or posedge rst_src_sync[i]) begin
        if (rst_src_sync[i]) begin
            pls_toggle[i] <= 1'b0;
        else if (src_pulse[i]) begin
            pls_toggle[i] <= ~pls_toggle[i];
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_sync[i]) begin
        if (rst_des_sync[i]) begin
            pls_toggle[i] <= 1'b0;
        else begin
            pls_toggle[i] <= pls_toggle[i];
        end
    end

    assign des_pulse[i] = pls_toggle[i] ^ pls_toggle[i-1] for all i in 1..NUM_CHANNELS-1;
    assign des_pulse[0] = pls_toggle[0];

    endmodule