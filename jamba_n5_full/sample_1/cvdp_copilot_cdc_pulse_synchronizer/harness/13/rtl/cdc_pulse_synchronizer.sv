module cdc_pulse_synchronizer #(
    parameter NUM_CHANNELS = 4
) (
    input  logic src_clock,
    input  logic des_clock,
    input  logic rst_in,
    input  logic [NUM_CHANNELS-1:0] src_pulse,
    output logic [NUM_CHANNELS-1:0] des_pulse
);

    logic pls_toggle;
    logic pls_toggle_synca, pls_toggle_syncb, pls_toggle_syncc;
    logic rst_src_sync;
    logic rst_des_sync;
    logic rst_src_synca, rst_src_syncb;
    logic rst_des_synca, rst_des_syncb;

    // Sync registers for each channel
    reg [0:NUM_CHANNELS-1] pls_state;
    reg [0:NUM_CHANNELS-1] pls_prev;

    // Initialization
    initial begin
        $readmemh("input_pulses.txt", src_pulse); // Not needed
        $readmemh("reset.txt", rst_in);
        $readmemh("des_pulse.txt", des_pulse);
    end

    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            pls_state <= 0;
            pls_prev <= 0;
        end else begin
            pls_state <= pls_state + 1;
            pls_prev <= pls_state;
        end
    end

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_des_sync <= 1'b1;
            rst_des_syncb <= 1'b1;
        end else begin
            rst_des_sync <= 1'b0;
            rst_des_syncb <= rst_des_syncb;
        end
    end

    assign rst_des_sync = rst_des_syncb;

    // For each channel, set up the synchronization
    genarray: for (genvar i = 0; i < NUM_CHANNELS; i++) begin
        always_ff @(posedge des_clock or posedge rst_in) begin
            if (rst_in) begin
                pls_state[i] <= 0;
                pls_prev[i] <= 0;
            end else begin
                pls_state[i] <= pls_state[i] + 1;
                pls_prev[i] <= pls_state[i];
            end
        end
    end

    // Generate output pulse for each channel
    assign des_pulse = (pls_state[0] == 1'b1) ? des_pulse_0 : 1'b0;

    // We need to generate for all channels
    for (int i = 0; i < NUM_CHANNELS; i++) begin
        assign des_pulse[i] = pls_state[i];
    end

endmodule
