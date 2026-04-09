module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 4 // Parameterization for the number of channels
) (
    input  logic [NUM_CHANNELS-1:0] src_pulse, // Vector of single-cycle pulse signals in the source domain
    input  logic src_clock,                   // Source Clock Domain
    input  logic des_clock,                   // Destination Clock Domain
    input  logic rst_in,                      // Asynchronous Active-High Reset
    output logic [NUM_CHANNELS-1:0] des_pulse // Vector of synchronized single-cycle pulse signals in the destination domain
);

    logic pls_toggle[NUM_CHANNELS-1:0]; // Array to hold the toggle signals for each channel
    logic pls_toggle_synca[NUM_CHANNELS-1:0];
    logic rst_src_sync[NUM_CHANNELS-1:0];
    logic rst_des_sync[NUM_CHANNELS-1:0];

    // Synchronizer for each channel
    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_src_sync = {NUM_CHANNELS{1'b1}};
            rst_des_sync = {NUM_CHANNELS{1'b1}};
        end else begin
            rst_src_sync = {NUM_CHANNELS{1'b0}};
            rst_des_sync = {NUM_CHANNELS{1'b0}};
        end
    end

    // Assign des_pulse based on the synchronized toggle
    assign des_pulse = {NUM_CHANNELS{pls_toggle_synca}};

    always_ff @(posedge src_clock or posedge rst_src_sync[0]) begin // Trigger for the first channel
        if (rst_src_sync[0]) begin
            pls_toggle[0] <= 1'b0;
        end else if (src_pulse[0]) begin
            pls_toggle[0] <= ~pls_toggle[0];
        end
    end

    // Generate synchronized toggle signals for each channel
    always_ff @(posedge des_clock or posedge rst_des_sync[0]) begin
        if (rst_des_sync[0]) begin
            pls_toggle_synca[0] <= 1'b0;
        end else begin
            pls_toggle_synca[0] <= pls_toggle[0];
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_sync[0]) begin
        if (rst_des_sync[0]) begin
            pls_toggle_syncc[0] <= 1'b0;
        end else begin
            pls_toggle_syncc[0] <= pls_toggle_synca[0];
        end
    end

    // XOR gate to generate the final des_pulse signal for each channel
    always_comb begin
        for (int i=0; i<NUM_CHANNELS; i++) begin
            des_pulse[i] <= pls_toggle_syncc[i] ^ pls_toggle_synca[i];
        end
    end

endmodule
