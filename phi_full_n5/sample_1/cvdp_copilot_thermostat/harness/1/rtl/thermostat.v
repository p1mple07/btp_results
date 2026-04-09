module thermostat(
    input wire i_temp_feedback[5:0],
    input wire i_fan_on,
    input wire i_enable,
    input wire i_fault,
    input wire i_clr,
    input wire i_clk,
    input wire i_rst
);

    // State declaration
    localparam [3:0] STATES = {
        AMBIENT, HEAT_LOW, HEAT_MED, HEAT_FULL,
        COOL_LOW, COOL_MED, COOL_FULL
    };

    // FSM registers
    reg [3:0] fsm_state = STATES'{AMBIENT};
    reg [1:0] transition_table = {
        {4'b0000, STATES'{HEAT_FULL}},
        {4'b0001, STATES'{HEAT_MED}},
        {4'b0010, STATES'{HEAT_LOW}},
        {4'b1000, STATES'{COOL_FULL}},
        {4'b1001, STATES'{COOL_MED}},
        {4'b1010, STATES'{COOL_LOW}}
    };

    // Reset and enable logic
    always @ (posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            fsm_state <= STATES'{AMBIENT};
        end else if (i_enable == 0) begin
            fsm_state <= STATES'{AMBIENT};
        end
    end

    // Fault handling logic
    always @ (posedge i_clk) begin
        if (i_fault) begin
            fsm_state <= STATES'{AMBIENT};
        end
    end

    // Clear fault logic
    always @ (posedge i_clk) begin
        if (i_clr) begin
            if (fsm_state != STATES'{AMBIENT}) begin
                fsm_state <= STATES'{AMBIENT};
            end
        end
    end

    // FSM transition logic
    always @ (posedge i_clk) begin
        if (!i_fault && !i_enable) begin
            case (fsm_state)
                STATES'{AMBIENT}: begin
                    if (i_temp_feedback[5]) fsm_state <= transition_table[4'b0000];
                    if (i_temp_feedback[4]) fsm_state <= transition_table[4'b0001];
                    if (i_temp_feedback[3]) fsm_state <= transition_table[4'b0010];
                    else fsm_state <= STATES'{AMBIENT};
                end
                STATES'{HEAT_LOW}: begin
                    if (i_temp_feedback[2]) fsm_state <= transition_table[4'b0100];
                    else fsm_state <= STATES'{AMBIENT};
                end
                STATES'{HEAT_MED}: begin
                    if (i_temp_feedback[1]) fsm_state <= transition_table[4'b0101];
                    else fsm_state <= STATES'{AMBIENT};
                end
                STATES'{HEAT_FULL}: begin
                    if (i_temp_feedback[0]) fsm_state <= transition_table[4'b0110];
                    else fsm_state <= STATES'{AMBIENT};
                end
                STATES'{COOL_LOW}: begin
                    if (i_temp_feedback[5]) fsm_state <= transition_table[4'b1000];
                    if (i_temp_feedback[4]) fsm_state <= transition_table[4'b1001];
                    if (i_temp_feedback[3]) fsm_state <= transition_table[4'b1010];
                    else fsm_state <= STATES'{AMBIENT};
                end
                STATES'{COOL_MED}: begin
                    if (i_temp_feedback[2]) fsm_state <= transition_table[4'b1100];
                    else fsm_state <= STATES'{AMBIENT};
                end
                STATES'{COOL_FULL}: begin
                    if (i_temp_feedback[1]) fsm_state <= transition_table[4'b1101];
                    else fsm_state <= STATES'{AMBIENT};
                end
            end
        end
    end

    // Output logic
    always @ (*) begin
        case (fsm_state)
            STATES'{AMBIENT}: begin
                o_heater_full = 0; o_heater_medium = 0; o_heater_low = 0;
                o_aircon_full = 0; o_aircon_medium = 0; o_aircon_low = 0;
                o_fan = i_fan_on;
            end
            STATES'{HEAT_LOW}: begin
                o_heater_full = 0; o_heater_medium = 0; o_heater_low = 1;
                o_aircon_full = 0; o_aircon_medium = 0; o_aircon_low = 0;
                o_fan = i_fan_on;
            end
            STATES'{HEAT_MED}: begin
                o_heater_full = 0; o_heater_medium = 1; o_heater_low = 0;
                o_aircon_full = 0; o_aircon_medium = 0; o_aircon_low = 0;
                o_fan = i_fan_on;
            end
            STATES'{HEAT_FULL}: begin
                o_heater_full = 1; o_heater_medium = 0; o_heater_low = 0;
                o_aircon_full = 0; o_aircon_medium = 0; o_aircon_low = 0;
                o_fan = i_fan_on;
            end
            STATES'{COOL_LOW}: begin
                o_heater_full = 0; o_heater_medium = 0; o_heater_low = 0;
                o_aircon_full = 1; o_aircon_medium = 0; o_aircon_low = 0;
                o_fan = i_fan_on;
            end
            STATES'{COOL_MED}: begin
                o_heater_full = 0; o_heater_medium = 0; o_heater_low = 0;
                o_aircon_full = 1; o_aircon_medium = 1; o_aircon_low = 0;
                o_fan = i_fan_on;
            end
            STATES'{COOL_FULL}: begin
                o_heater_full = 0; o_heater_medium = 0; o_heater_low = 0;
                o_aircon_full = 1; o_aircon_medium = 1; o_aircon_low = 1;
                o_fan = i_fan_on;
            end
        end
    end

endmodule

wire [5:0] i_temp_feedback;
wire i_fan_on;
wire i_enable;
wire i_fault;
wire i_clr;
wire i_clk;
wire i_rst;
wire [3:0] o_state;
wire o_heater_full;
wire o_heater_medium;
wire o_heater_low;
wire o_aircon_full;
wire o_aircon_medium;
wire o_aircon_low;
wire o_fan;

thermostat uut(
    .i_temp_feedback(i_temp_feedback),
    .i_fan_on(i_fan_on),
    .i_enable(i_enable),
    .i_fault(i_fault),
    .i_clr(i_clr),
    .i_clk(i_clk),
    .i_rst(i_rst),
    .o_state(o_state),
    .o_heater_full(o_heater_full),
    .o_heater_medium(o_heater_medium),
    .o_heater_low(o_heater_low),
    .o_aircon_full(o_aircon_full),
    .o_aircon_medium(o_aircon_medium),
    .o_aircon_low(o_aircon_low),
    .o_fan(o_fan)
);
