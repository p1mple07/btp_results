module cdc_pulse_synchronizer #(parameter NUM_CHANNELS = 4) (
    input wire src_clock,
    input wire des_clock,
    input wire rst_in,
    input wire [NUM_CHANNELS-1:0] src_pulse,
    output wire [NUM_CHANNELS-1:0] des_pulse
);

logic [NUM_CHANNELS-1:0] src_pulse_toggle;
logic [NUM_CHANNELS-1:0] src_pulse_toggle_synca, src_pulse_toggle_syncb;
logic [NUM_CHANNELS-1:0] des_pulse_synca, des_pulse_syncb;

always_ff @(posedge src_clock or posedge rst_in) begin
    if (rst_in) begin
        src_pulse_toggle_synca <= '0;
        src_pulse_toggle_syncb <= '0;
    end else begin
        src_pulse_toggle_synca <= src_pulse_toggle;
        src_pulse_toggle_syncb <= src_pulse_toggle_synca;
    end
end

assign src_pulse_toggle = src_pulse ^ src_pulse_toggle_synca;

always_ff @(posedge des_clock or posedge rst_in) begin
    if (rst_in) begin
        des_pulse_synca <= '0;
        des_pulse_syncb <= '0;
    end else begin
        des_pulse_synca <= des_pulse_toggle;
        des_pulse_syncb <= des_pulse_toggle_synca;
    end
end

assign des_pulse = (des_pulse_syncb | des_pulse_synca) & ((~des_pulse_synca) ^ (~des_pulse_syncb));

endmodule