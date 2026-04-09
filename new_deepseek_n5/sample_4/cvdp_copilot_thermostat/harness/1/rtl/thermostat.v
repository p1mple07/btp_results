module thermostat (
    input wire [5:0] i_temp_feedback,
    input wire i_fan_on,
    input wire i_enable,
    input wire i_fault,
    input wire i_clr,
    input wire i_clk,
    input wire i_rst,
    output reg [2:0] o_state,
    output reg [5:0] o_heater,
    output reg [5:0] o_aircon,
    output reg o_fan
);

    reg current_state = 0;

    always @(posedge i_clk) begin
        if (i_rst) begin
            current_state = 0;
            o_heater = 0;
            o_aircon = 0;
            o_fan = 0;
        elsif (i_fault) begin
            current_state = 0;
            o_heater = 0;
            o_aircon = 0;
            o_fan = 0;
        elsif (i_enable) begin
            current_state = 0;
            o_heater = 0;
            o_aircon = 0;
            o_fan = 0;
        else begin
            case (current_state)
                0: 
                    if (i_full_cold) begin
                        current_state = 3;
                    elsif (i_medium_cold) begin
                        current_state = 2;
                    elsif (i_low_cold) begin
                        current_state = 1;
                    elsif (i_low_hot) begin
                        current_state = 4;
                    elsif (i_medium_hot) begin
                        current_state = 5;
                    elsif (i_full_hot) begin
                        current_state = 6;
                    end else:
                        current_state = 0;
                3: 
                    if (i_full_cold) current_state = 3;
                    else if (i_medium_cold) current_state = 2;
                    else if (i_low_cold) current_state = 1;
                    else current_state = 0;
                2: 
                    if (i_full_cold) current_state = 3;
                    else if (i_medium_cold) current_state = 2;
                    else if (i_low_cold) current_state = 1;
                    else current_state = 0;
                4: 
                    if (i_full_hot) current_state = 6;
                    else if (i_medium_hot) current_state = 5;
                    else if (i_low_hot) current_state = 4;
                    else current_state = 0;
                5: 
                    if (i_full_hot) current_state = 6;
                    else if (i_medium_hot) current_state = 5;
                    else if (i_low_hot) current_state = 4;
                    else current_state = 0;
                6: 
                    if (i_full_hot) current_state = 6;
                    else if (i_medium_hot) current_state = 5;
                    else if (i_low_hot) current_state = 4;
                    else current_state = 0;
                default: current_state = 0;
            end case
        end
    end

    // Set outputs based on state and inputs
    o_state = current_state;
    o_heater[5] = (current_state & 0x100) ? 1 : 0;
    o_heater[4] = (current_state & 0x080) ? 1 : 0;
    o_heater[3] = (current_state & 0x040) ? 1 : 0;
    o_aircon[5] = (current_state & 0x100) ? 0 : 0;
    o_aircon[4] = (current_state & 0x080) ? 0 : 0;
    o_aircon[3] = (current_state & 0x040) ? 0 : 0;
    o_fan = (current_state & 0x008) ? 1 : 0;
    o_fan |= i_fan_on;
endmodule