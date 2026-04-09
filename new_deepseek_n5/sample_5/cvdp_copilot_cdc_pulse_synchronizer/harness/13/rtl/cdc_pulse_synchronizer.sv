module cdc_pulse_synchronizer (
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic src_pulse,       // Source Pulse (NUM_CHANNELS-bit)
    output logic des_pulse        // Destination Pulse (NUM_CHANNELS-bit)
);

    parameter NUM_CHANNELS = 4;
    logic pls_toggle[NUM_CHANNELS];      
    logic pls_toggle_synca[NUM_CHANNELS], pls_toggle_syncb[NUM_CHANNELS], pls_toggle_syncc[NUM_CHANNELS];
    logic rst_src_sync[NUM_CHANNELS];
    logic rst_des_sync[NUM_CHANNELS];
    logic rst_src_syncb[NUM_CHANNELS], rst_src_synca[NUM_CHANNELS];
    logic rst_des_syncb[NUM_CHANNELS], rst_des_synca[NUM.CHANNELS];

    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_src_sync <= (1'b1, NUM_CHANNELS-1 * 1'b1);
            rst_src_syncb <= rst_src_sync;
        else begin
            rst_src_sync <= (1'b0, NUM_CHANNELS-1 * 1'b0);
            rst_src_syncb <= rst_src_sync;
        end
    end

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_des_sync <= (1'b1, NUM_CHANNELS-1 * 1'b1);
            rst_des_syncb <= rst_des_sync;
        else begin
            rst_des_sync <= (1'b0, NUM_CHANNELS-1 * 1'b0);
            rst_des_syncb <= rst_des_sync;
        end
    end

    for (int i = 0; i < NUM_CHANNELS; i++) begin
        always_ff @(posedge src_clock or posedge rst_src_sync[i]) begin
            if (rst_src_sync[i]) begin
                pls_toggle[i] <= 1'b0;
            end else if (src_pulse[i]) begin
                pls_toggle[i] <= !pls_toggle[i];
            end
        end
    end

    for (int i = 0; i < NUM_CHANNELS; i++) begin
        always_ff @(posedge des_clock or posedge rst_des_sync[i]) begin
            if (rst_des_sync[i]) begin
                pls_toggle_synca[i] <= 1'b0;
                pls_toggle_syncb[i] <= 1'b0;
            end else begin
                pls_toggle_synca[i] <= pls_toggle[i];
                pls_toggle_syncb[i] <= pls_toggle_synca[i];
            end
        end
    end

    for (int i = 0; i < NUM_CHANNELS; i++) begin
        always_ff @(posedge des_clock or posedge rst_des_sync[i]) begin
            if (rst_des_sync[i]) begin
                pls_toggle_syncc[i] <= 1'b0;
            end else begin
                pls_toggle_syncc[i] <= pls_toggle_syncb[i];
            end
        end
    end

    des_pulse[0:NUM_CHANNELS-1] <= (pls_toggle_syncc[0:NUM_CHANNELS-1] ^ pls_toggle_syncb[0:NUM_CHANNELS-1]);

endmodule