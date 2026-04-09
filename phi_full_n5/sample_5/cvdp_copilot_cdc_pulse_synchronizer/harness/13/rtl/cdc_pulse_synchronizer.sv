module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 4
) (
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic [NUM_CHANNELS-1:0] src_pulse,       // Source Pulse Vector
    output logic [NUM_CHANNELS-1:0] des_pulse        // Destination Pulse Vector
);

    logic pls_toggle[NUM_CHANNELS-1:0];      
    logic pls_toggle_synca[NUM_CHANNELS-1:0], pls_toggle_syncb[NUM_CHANNELS-1:0];
    logic rst_src_sync[NUM_CHANNELS-1:0];
    logic rst_des_sync[NUM_CHANNELS-1:0];
    logic rst_src_synca[NUM_CHANNELS-1:0], rst_src_syncb[NUM_CHANNELS-1:0];
    logic rst_des_synca[NUM_CHANNELS-1:0], rst_des_syncb[NUM_CHANNELS-1:0];

    always_ff @(posedge src_clock or posedge rst_in) begin
        for (integer i=0; i<NUM_CHANNELS; i++) begin
            if (rst_in) begin
                rst_src_synca[i] <= 1'b1;
                rst_src_syncb[i] <= 1'b1;
                rst_des_synca[i] <= 1'b1;
                rst_des_syncb[i] <= 1'b1;
            end else begin
                rst_src_synca[i] <= 1'b0;
                rst_src_syncb[i] <= rst_src_synca[i];
                rst_des_synca[i] <= 1'b0;
                rst_des_syncb[i] <= rst_des_synca[i];
            end
        end
    end

    assign rst_src_sync = rst_src_syncb;

    always_ff @(posedge des_clock or posedge rst_des_sync) begin
        for (integer i=0; i<NUM_CHANNELS; i++) begin
            if (rst_des_sync[i]) begin
                pls_toggle_synca[i] <= 1'b0;
                pls_toggle_syncb[i] <= 1'b0;
                pls_toggle_syncc[i] <= 1'b0;
            end else begin
                pls_toggle_synca[i] <= pls_toggle[i];
                pls_toggle_syncb[i] <= pls_toggle_synca[i];
                pls_toggle_syncc[i] <= pls_toggle_syncb[i];
            end
        end
    end

    assign des_pulse = pls_toggle_syncc ^ pls_toggle_syncb;

endmodule

cdc_pulse_synchronizer.sv
rtl/cdc_pulse_synchronizer.sv module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 4
) (
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic [NUM_CHANNELS-1:0] src_pulse,       // Source Pulse Vector
    output logic [NUM_CHANNELS-1:0] des_pulse        // Destination Pulse Vector
);

    logic pls_toggle[NUM_CHANNELS-1:0];      
    logic pls_toggle_synca[NUM_CHANNELS-1:0], pls_toggle_syncb[NUM_CHANNELS-1:0];
    logic rst_src_sync[NUM_CHANNELS-1:0];
    logic rst_des_sync[NUM_CHANNELS-1:0];
    logic rst_src_synca[NUM_CHANNELS-1:0], rst_src_syncb[NUM_CHANNELS-1:0];
    logic rst_des_synca[NUM_CHANNELS-1:0], rst_des_syncb[NUM_CHANNELS-1:0];

    always_ff @(posedge src_clock or posedge rst_in) begin
        for (integer i=0; i<NUM_CHANNELS; i++) begin
            if (rst_in) begin
                rst_src_synca[i] <= 1'b1;
                rst_src_syncb[i] <= 1'b1;
                rst_des_synca[i] <= 1'b1;
                rst_des_syncb[i] <= 1'b1;
            end else begin
                rst_src_synca[i] <= 1'b0;
                rst_src_syncb[i] <= rst_src_synca[i];
                rst_des_synca[i] <= 1'b0;
                rst_des_syncb[i] <= rst_des_synca[i];
            end
        end
    end

    assign rst_src_sync = rst_src_syncb;

    always_ff @(posedge des_clock or posedge rst_des_sync) begin
        for (integer i=0; i<NUM_CHANNELS; i++) begin
            if (rst_des_sync[i]) begin
                pls_toggle_synca[i] <= 1'b0;
                pls_toggle_syncb[i] <= 1'b0;
                pls_toggle_syncc[i] <= 1'b0;
            end else begin
                pls_toggle_synca[i] <= pls_toggle[i];
                pls_toggle_syncb[i] <= pls_toggle_synca[i];
                pls_toggle_syncc[i] <= pls_toggle_syncb[i];
            end
        end
    end

    assign des_pulse = pls_toggle_syncc ^ pls_toggle_syncb;

endmodule