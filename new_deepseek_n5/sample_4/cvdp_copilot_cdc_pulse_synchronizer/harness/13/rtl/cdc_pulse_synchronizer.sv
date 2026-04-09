module cdc_pulse_synchronizer (
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic src_pulse,       // Source Pulse (NUM_CHANNELS-bit vector)
    output logic des_pulse        // Destination Pulse (NUM_CHANNELS-bit vector)
);

    parameter NUM_CHANNELS = 4;  // Number of independent pulse channels

    logic pls_toggle[NUM_CHANNELS];      
    logic pls_toggle_synca[NUM_CHANNELS];
    logic pls_toggle_syncb[NUM_CHANNELS];
    logic rst_src_sync[NUM_CHANNELS];
    logic rst_des_sync[NUM_CHANNELS];
    logic rst_src_syncb[NUM_CHANNELS];
    logic rst_des_syncb[NUM_CHANNELS];
    logic rst_des_syncc[NUM_CHANNELS];

    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            for (int i = 0; i < NUM_CHANNELS; i++) begin
                rst_src_sync[i] <= 1'b1;
                rst_src_syncb[i] <= 1'b1;
            end
        end else begin
            for (int i = 0; i < NUM_CHANNELS; i++) begin
                rst_src_sync[i] <= 1'b0;
                rst_src_syncb[i] <= rst_src_sync[i];
            end
        end
    end

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            for (int i = 0; i < NUM_CHANNELS; i++) begin
                rst_des_sync[i] <= 1'b1;
                rst_des_syncb[i] <= 1'b1;
            end
        end else begin
            for (int i = 0; i < NUM_CHANNELS; i++) begin
                rst_des_sync[i] <= 1'b0;
                rst_des_syncb[i] <= rst_des_sync[i];
            end
        end
    end

    always_ff @(posedge src_clock or posedge rst_src_sync[i]) begin
        if (rst_src_sync[i]) begin
            pls_toggle[i] <= 1'b0;
        end else if (src_pulse[i]) begin
            pls_toggle[i] <= ~pls_toggle[i];
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_sync[i]) begin
        if (rst_des_sync[i]) begin
            pls_toggle_synca[i] <= 1'b0;
            pls_toggle_syncb[i] <= 1'b0;
        end else begin
            pls_toggle_synca[i] <= pls_toggle[i];
            pls_toggle_syncb[i] <= pls_toggle_synca[i];
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_syncc[i]) begin
        if (rst_des_syncc[i]) begin
            pls_toggle_syncc[i] <= 1'b0;
        end else begin
            pls_toggle_syncc[i] <= pls_toggle_syncb[i];
        end
    end

    assign 
        des_pulse[i] = pls_toggle_syncc[i] ^ pls_toggle_syncb[i];
    endmodule