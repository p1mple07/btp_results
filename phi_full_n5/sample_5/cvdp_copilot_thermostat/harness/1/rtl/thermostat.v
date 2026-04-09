module thermostat(
    input [5:0] i_temp_feedback,
    input i_fan_on,
    input i_enable,
    input i_fault,
    input i_clr,
    input i_clk,
    input i_rst,
    output reg [1:0] o_state,
    output reg [2:0] o_heater_full,
    output reg [2:0] o_heater_medium,
    output reg [2:0] o_heater_low,
    output reg [2:0] o_aircon_full,
    output reg [2:0] o_aircon_medium,
    output reg [2:0] o_aircon_low,
    output reg o_fan
);

    // State definitions
    localparam [3:0] STATE_AMBIENT = 4'b000,
                STATE_HEAT_LOW = 4'b001,
                STATE_HEAT_MED = 4'b010,
                STATE_HEAT_FULL = 4'b011,
                STATE_COOL_LOW = 4'b100,
                STATE_COOL_MED = 4'b101,
                STATE_COOL_FULL = 4'b110;

    // Internal state register
    reg [3:0] int_state;

    // FSM logic
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            int_state <= STATE_AMBIENT;
            o_state <= STATE_AMBIENT;
            o_heater_full <= 0;
            o_heater_medium <= 0;
            o_heater_low <= 0;
            o_aircon_full <= 0;
            o_aircon_medium <= 0;
            o_aircon_low <= 0;
            o_fan <= 0;
        end else if (i_fault) begin
            int_state <= STATE_AMBIENT;
            o_state <= STATE_AMBIENT;
            o_heater_full <= 0;
            o_heater_medium <= 0;
            o_heater_low <= 0;
            o_aircon_full <= 0;
            o_aircon_medium <= 0;
            o_aircon_low <= 0;
            o_fan <= 0;
        end else if (i_clr) begin
            int_state <= STATE_AMBIENT;
            o_state <= STATE_AMBIENT;
            o_heater_full <= 0;
            o_heater_medium <= 0;
            o_heater_low <= 0;
            o_aircon_full <= 0;
            o_aircon_medium <= 0;
            o_aircon_low <= 0;
            o_fan <= 0;
        end else if (!i_enable) begin
            int_state <= STATE_AMBIENT;
            o_state <= STATE_AMBIENT;
            o_heater_full <= 0;
            o_heater_medium <= 0;
            o_heater_low <= 0;
            o_aircon_full <= 0;
            o_aircon_medium <= 0;
            o_aircon_low <= 0;
            o_fan <= 0;
        end else begin
            case (int_state)
                STATE_AMBIENT: begin
                    if (i_full_cold) begin
                        int_state <= STATE_HEAT_FULL;
                        o_heater_full <= 1;
                        o_heater_medium <= 0;
                        o_heater_low <= 0;
                        o_aircon_full <= 0;
                        o_aircon_medium <= 0;
                        o_aircon_low <= 0;
                        o_fan <= i_fan_on;
                    end
                end
                STATE_HEAT_LOW: begin
                    if (i_medium_cold) begin
                        int_state <= STATE_HEAT_MED;
                        o_heater_medium <= 1;
                        o_heater_full <= 0;
                        o_heater_low <= 0;
                        o_aircon_full <= 0;
                        o_aircon_medium <= 0;
                        o_aircon_low <= 0;
                        o_fan <= i_fan_on;
                    end
                end
                STATE_HEAT_MED: begin
                    if (i_low_cold) begin
                        int_state <= STATE_HEAT_LOW;
                        o_heater_low <= 1;
                        o_heater_full <= 0;
                        o_heater_medium <= 0;
                        o_aircon_full <= 0;
                        o_aircon_medium <= 0;
                        o_aircon_low <= 0;
                        o_fan <= i_fan_on;
                    end
                end
                STATE_HEAT_FULL: begin
                    if (i_full_hot) begin
                        int_state <= STATE_COOL_FULL;
                        o_heater_full <= 0;
                        o_heater_medium <= 0;
                        o_heater_low <= 0;
                        o_aircon_full <= 1;
                        o_aircon_medium <= 0;
                        o_aircon_low <= 0;
                        o_fan <= i_fan_on;
                    end
                end
                STATE_COOL_LOW: begin
                    if (i_medium_hot) begin
                        int_state <= STATE_COOL_MED;
                        o_aircon_medium <= 1;
                        o_heater_full <= 0;
                        o_heater_medium <= 0;
                        o_heater_low <= 0;
                        o_aircon_low <= 0;
                        o_fan <= i_fan_on;
                    end
                end
                STATE_COOL_MED: begin
                    if (i_low_hot) begin
                        int_state <= STATE_COOL_LOW;
                        o_aircon_low <= 1;
                        o_heater_full <= 0;
                        o_heater_medium <= 0;
                        o_heater_low <= 0;
                        o_aircon_medium <= 0;
                        o_fan <= i_fan_on;
                    end
                end
                STATE_COOL_FULL: begin
                    if (i_full_cold) begin
                        int_state <= STATE_AMBIENT;
                        o_heater_full <= 0;
                        o_heater_medium <= 0;
                        o_heater_low <= 0;
                        o_aircon_full <= 0;
                        o_aircon_medium <= 0;
                        o_aircon_low <= 0;
                        o_fan <= 0;
                    end
                end default: begin
                    int_state <= STATE_AMBIENT;
                    o_heater_full <= 0;
                    o_heater_medium <= 0;
                    o_heater_low <= 0;
                    o_aircon_full <= 0;
                    o_aircon_medium <= 0;
                    o_aircon_low <= 0;
                    o_fan <= 0;
                end
            endcase
        end
    end

endmodule
