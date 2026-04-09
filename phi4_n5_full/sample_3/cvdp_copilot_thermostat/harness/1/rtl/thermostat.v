module thermostat (
    input  wire         i_clk,    // Clock for sequential logic
    input  wire         i_rst,    // Asynchronous active-low reset
    input  wire [5:0]   i_temp_feedback, // Temperature feedback bits:
                                        // bit5: i_full_cold, bit4: i_medium_cold, bit3: i_low_cold,
                                        // bit2: i_low_hot,   bit1: i_medium_hot, bit0: i_full_hot
    input  wire         i_fan_on, // User control: fan on (1) or off (0)
    input  wire         i_enable, // Enable thermostat (1 = enabled, 0 = disabled)
    input  wire         i_fault,  // Fault condition (1 = fault, overrides outputs)
    input  wire         i_clr,    // Clear fault condition; returns FSM to AMBIENT on next clk
    output reg          o_heater_full,    // Heating control outputs
    output reg          o_heater_medium,
    output reg          o_heater_low,
    output reg          o_aircon_full,    // Cooling control outputs
    output reg          o_aircon_medium,
    output reg          o_aircon_low,
    output reg          o_fan,             // Fan control output
    output reg [2:0]    o_state            // Current FSM state
);

    // FSM state encoding
    localparam HEAT_LOW  = 3'b000;
    localparam HEAT_MED  = 3'b001;
    localparam HEAT_FULL = 3'b010;
    localparam AMBIENT   = 3'b011;
    localparam COOL_LOW  = 3'b100;
    localparam COOL_MED  = 3'b101;
    localparam COOL_FULL = 3'b110;

    reg [2:0] state; // Current state register

    // Sequential process: state and output update
    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            // Asynchronous reset: force FSM to AMBIENT and all outputs to 0
            state          <= AMBIENT;
            o_heater_full  <= 1'b0;
            o_heater_medium<= 1'b0;
            o_heater_low   <= 1'b0;
            o_aircon_full  <= 1'b0;
            o_aircon_medium<= 1'b0;
            o_aircon_low   <= 1'b0;
            o_fan          <= 1'b0;
            o_state        <= AMBIENT;
        end else begin
            reg [2:0] next_state;
            // Determine next state based on override conditions and temperature feedback
            if (i_fault) begin
                // Fault condition: outputs forced 0; state remains unchanged unless cleared
                next_state = state;
                if (i_clr)
                    next_state = AMBIENT;
            end else if (!i_enable) begin
                // Disable condition: force outputs 0 and state to AMBIENT
                next_state = AMBIENT;
            end else begin
                // Normal operation: if clear is asserted, return to AMBIENT; otherwise, use temperature feedback
                if (i_clr)
                    next_state = AMBIENT;
                else begin
                    // Cold conditions have highest priority:
                    if (i_temp_feedback[5])
                        next_state = HEAT_FULL;  // i_full_cold asserted
                    else if (i_temp_feedback[4])
                        next_state = HEAT_MED;   // i_medium_cold asserted
                    else if (i_temp_feedback[3])
                        next_state = HEAT_LOW;   // i_low_cold asserted
                    // Hot conditions (mutually exclusive with cold conditions):
                    else if (i_temp_feedback[0])
                        next_state = COOL_FULL;  // i_full_hot asserted
                    else if (i_temp_feedback[1])
                        next_state = COOL_MED;   // i_medium_hot asserted
                    else if (i_temp_feedback[2])
                        next_state = COOL_LOW;   // i_low_hot asserted
                    else
                        next_state = AMBIENT;    // No heating or cooling required
                end
            end

            state <= next_state;

            // Output logic: if fault or disable, force outputs to 0; otherwise, drive outputs based on state
            if (i_fault || !i_enable) begin
                o_heater_full  <= 1'b0;
                o_heater_medium<= 1'b0;
                o_heater_low   <= 1'b0;
                o_aircon_full  <= 1'b0;
                o_aircon_medium<= 1'b0;
                o_aircon_low   <= 1'b0;
                o_fan          <= 1'b0;
            end else begin
                // Drive heater/aircon outputs based on current state
                case (state)
                    HEAT_LOW: begin
                        o_heater_low   <= 1'b1;
                        o_heater_full  <= 1'b0;
                        o_heater_medium<= 1'b0;
                        o_aircon_full  <= 1'b0;
                        o_aircon_medium<= 1'b0;
                        o_aircon_low   <= 1'b0;
                    end
                    HEAT_MED: begin
                        o_heater_medium<= 1'b1;
                        o_heater_full  <= 1'b0;
                        o_heater_low   <= 1'b0;
                        o_aircon_full  <= 1'b0;
                        o_aircon_medium<= 1'b0;
                        o_aircon_low   <= 1'b0;
                    end
                    HEAT_FULL: begin
                        o_heater_full  <= 1'b1;
                        o_heater_medium<= 1'b0;
                        o_heater_low   <= 1'b0;
                        o_aircon_full  <= 1'b0;
                        o_aircon_medium<= 1'b0;
                        o_aircon_low   <= 1'b0;
                    end
                    COOL_LOW: begin
                        o_aircon_low   <= 1'b1;
                        o_aircon_full  <= 1'b0;
                        o_aircon_medium<= 1'b0;
                        o_heater_full  <= 1'b0;
                        o_heater_medium<= 1'b0;
                        o_heater_low   <= 1'b0;
                    end
                    COOL_MED: begin
                        o_aircon_medium<= 1'b1;
                        o_aircon_full  <= 1'b0;
                        o_aircon_low   <= 1'b0;
                        o_heater_full  <= 1'b0;
                        o_heater_medium<= 1'b0;
                        o_heater_low   <= 1'b0;
                    end
                    COOL_FULL: begin
                        o_aircon_full  <= 1'b1;
                        o_aircon_medium<= 1'b0;
                        o_aircon_low   <= 1'b0;
                        o_heater_full  <= 1'b0;
                        o_heater_medium<= 1'b0;
                        o_heater_low   <= 1'b0;
                    end
                    AMBIENT: begin
                        o_heater_full  <= 1'b0;
                        o_heater_medium<= 1'b0;
                        o_heater_low   <= 1'b0;
                        o_aircon_full  <= 1'b0;
                        o_aircon_medium<= 1'b0;
                        o_aircon_low   <= 1'b0;
                    end
                endcase
                // Fan control: fan is on if any heater/aircon output is active OR if i_fan_on is asserted.
                o_fan <= (state != AMBIENT) || i_fan_on;
            end

            // Update FSM state output
            o_state <= state;
        end
    end

endmodule