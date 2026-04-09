module thermostat(
    input wire [5:0] i_temp_feedback,
    input wire i_fan_on,
    input wire i_enable,
    input wire i_fault,
    input wire i_rst,
    output reg [2:0] o_state,
    output reg [5:0] o_heater,
    output reg [5:0] o_aircon,
    output reg o_fan
);

    // State transition table
    reg [2:0] next_state;

    always @posedge i_clk) begin
        if (i_rst) begin
            o_state = 000;
            o_heater = 000000;
            o_aircon = 000000;
            o_fan = 0;
        elsif (i_fault) begin
            o_state = 000;
            o_heater = 000000;
            o_aircon = 000000;
            o_fan = 0;
        elsif (i_enable) begin
            case (o_state)
                000: 
                    if (i_temp_feedback[5] & 1) next_state = 011;
                    else if (i_temp_feedback[4] & 1) next_state = 010;
                    else if (i_temp_feedback[3] & 1) next_state = 001;
                    else if (i_temp_feedback[2] & 1) next_state = 100;
                    else if (i_temp_feedback[1] & 1) next_state = 101;
                    else if (i_temp_feedback[0] & 1) next_state = 110;
                    else next_state = 000;
                011: 
                    if (i_temp_feedback[5] & 1) next_state = 011;
                    else if (i_temp_feedback[4] & 1) next_state = 010;
                    else if (i_temp_feedback[3] & 1) next_state = 001;
                    else if (i_temp_feedback[2] & 1) next_state = 100;
                    else if (i_temp_feedback[1] & 1) next_state = 101;
                    else next_state = 110;
                010: 
                    if (i_temp_feedback[5] & 1) next_state = 011;
                    else if (i_temp_feedback[4] & 1) next_state = 010;
                    else if (i_temp_feedback[3] & 1) next_state = 001;
                    else if (i_temp_feedback[2] & 1) next_state = 100;
                    else if (i_temp_feedback[1] & 1) next_state = 101;
                    else next_state = 110;
                001: 
                    if (i_temp_feedback[5] & 1) next_state = 011;
                    else if (i_temp_feedback[4] & 1) next_state = 010;
                    else if (i_temp_feedback[3] & 1) next_state = 001;
                    else if (i_temp_feedback[2] & 1) next_state = 100;
                    else if (i_temp_feedback[1] & 1) next_state = 101;
                    else next_state = 110;
                100: 
                    if (i_temp_feedback[5] & 1) next_state = 101;
                    else if (i_temp_feedback[4] & 1) next_state = 100;
                    else if (i_temp_feedback[3] & 1) next_state = 010;
                    else if (i_temp_feedback[2] & 1) next_state = 001;
                    else if (i_temp_feedback[1] & 1) next_state = 110;
                    else next_state = 100;
                101: 
                    if (i_temp_feedback[5] & 1) next_state = 101;
                    else if (i_temp_feedback[4] & 1) next_state = 100;
                    else if (i_temp_feedback[3] & 1) next_state = 010;
                    else if (i_temp_feedback[2] & 1) next_state = 001;
                    else next_state = 110;
                110: 
                    if (i_temp_feedback[5] & 1) next_state = 101;
                    else if (i_temp_feedback[4] & 1) next_state = 100;
                    else if (i_temp_feedback[3] & 1) next_state = 010;
                    else if (i_temp_feedback[2] & 1) next_state = 001;
                    else next_state = 110;
                default next_state = 000;
            endcase
        else begin
            case (o_state)
                000: 
                    if (i_fan_on) o_fan = 1;
                    else o_fan = 0;
                    next_state = o_state;
                011: 
                    if (i_fan_on) o_fan = 1;
                    else o_fan = 0;
                    next_state = o_state;
                010: 
                    if (i_fan_on) o_fan = 1;
                    else o_fan = 0;
                    next_state = o_state;
                001: 
                    if (i_fan_on) o_fan = 1;
                    else o_fan = 0;
                    next_state = o_state;
                100: 
                    if (i_fan_on) o_fan = 1;
                    else o_fan = 0;
                    next_state = o_state;
                101: 
                    if (i_fan_on) o_fan = 1;
                    else o_fan = 0;
                    next_state = o_state;
                110: 
                    if (i_fan_on) o_fan = 1;
                    else o_fan = 0;
                    next_state = o_state;
                default next_state = o_state;
            endcase
        end
    );

    // Assign outputs
    o_state = next_state;
    o_heater = [ (o_state & 4'b110000) >> 3 : 1,
                  (o_state & 4'b011000) >> 2 : 1,
                  (o_state & 4'b001100) >> 1 : 1,
                  (o_state & 4'b000111) : 1,
                  0 : 0 ];
    o_aircon = [ (o_state & 4'b110000) >> 3 : 1,
                 (o_state & 4'b011000) >> 2 : 1,
                 (o_state & 4'b001100) >> 1 : 1,
                 (o_state & 4'b000111) : 1,
                 0 : 0 ];
    o_fan = o_fan;

    // Always ensure proper initialization
    always @* begin
        o_state = 000;
        o_heater = 000000;
        o_aircon = 000000;
        o_fan = 0;
    end
endmodule