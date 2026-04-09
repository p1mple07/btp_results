// Fixed code with correct delay handling
module coffee_machine #(
    parameter NBW_DLY    = 'd5,
    parameter NBW_BEANS  = 'd2,
    parameter NS_BEANS   = 'd4,
    parameter NS_OP      = 'd3,
    parameter NS_SENSOR  = 'd4  // Fixed
) (
    // Defined logic for the coffee machine
    type_t state_t;
    int state_ff, i_operation_sel, i_grind_delay, i_powder_delay, i_pour_delay;
    logic [NBW_DLY:0] counter_ff, counter_nx;
    logic [NBW_BEANS:0] bean_sel_in_ff;
    logic [NS_OP-1:0] bean_sel_in_ff;
    logic [NS_BEANS:0] o_bean_sel,
    logic [NS_BEANS:0] o_use_powder,
    logic [NS_BEANS:0] o_grind_beans,
    logic [NS_OP:1] oheat,
    logic o_pour_coffee,
    logic o_error
);

// FSM state definitions
state_t state_t (
    IDLE     = 3'b000,
    BEAN_SEL = 3'b001,
    GRIND    = 3'b010,
    POWDER    = 3'b011,
    HEAT      = 3'b100,
    POUR      = 3'b101,
    DRAIN     = 3'b110,
    default: 3'b111
) {
    // State transitions
    IDLE: begin
        o_bean_sel      = (i_sensor[0] | i_sensor[3]) | (&i_operation_sel[2:1]) & (|i_operation_sel[0]) ? 1'b0 : 1'b0;
        o_use_powder    = 1'b0;
        o_grind_beans   = 1'b0;
        o_pour_coffee   = 1'b0;
        o_error          = 1'b0;
    end else begin
        state_ff <= i_start;
    end

    BEAN_SEL: begin
        if (counter_nx >= i_grind_delay) begin
            counter_nx   <= 0;
            state_ff   <= GRIND;
        end else if (i_operation_sel[1]) begin
            state_ff   <= POUR;
        end else if (i_operation_sel[0]) begin
            state_ff   <= POUR;
        end else begin
            counter_nx   <= counter_nx + 1'b1;
            state_ff   <= BEAN_SEL;
        end
    end

    GRIND: begin
        if (counter_nx >= i_powder_delay) begin
            counter_nx   <= 0;
            state_ff   <= POWDER;
        end else begin
            counter_nx   <= counter_nx + 1'b1;
            state_ff   <= GRIND;
        end
    end

    POWDER: begin
        if (counter_nx >= i_pour_delay) begin
            counter_nx   <= 0;
            state_ff   <= POUR;
        end else begin
            counter_nx   <= counter_nx + 1'b1;
            state_ff   <= POWDER;
        end
    end

    HEAT: begin
        if (state_ff == 3'b100) begin
            if (i_sensor[0] == 1) begin
                o_bean_sel      = 1'b0;
                o_use_powder    = 1'b0;
                o_grind_beans   = 1'b0;
                o_pour_coffee   = 1'b0;
                o_error          = 1'b0;
            end else if (i_operation_sel[1]) begin
                state_ff   <= POUR;
            end else if (i_operation_sel[0]) begin
                state_ff   <= POUR;
            end else begin
                counter_nx   <= counter_nx + 1'b1;
                state_ff   <= HEAT;
            end
        end else if (state_ff == 3'b110) begin
            o_bean_sel      = 1'b0;
            o_use_powder    = 1'b0;
            o_grind_beans   = 1'b0;
            o_pour_coffee   = 1'b0;
            o_error          = 1'b1;
        end else begin
            state_ff   <= HEAT;
        end
    end

    POUR: begin
        if (counter_nx >= i_pour_delay) begin
            counter_nx   <= 0;
            state_ff   <= DRAIN;
        end else begin
            counter_nx   <= counter_nx + 1'b1;
            state_ff   <= POUR;
        end
    end

    DRAIN: begin
        if (counter_nx >= i_grind_delay) begin
            counter_nx   <= 0;
            state_ff   <= GRIND;
        end else if (i_sensor[3] == 1) begin
            state_ff   <= IDLE;
        end else begin
            counter_nx   <= counter_nx + 1'b1;
            state_ff   <= DRAIN;
        end
    end

    default: begin
        counter_nx   <= 0;
        state_ff   <= IDLE;
    end
}

// Control signals
case(state_ff)
    IDLE: begin
        o_bean_sel      = (i_sensor[0] | i_sensor[3]) | (&i_operation_sel[2:1]) & (|i_operation_sel[0]) ? 1'b0 : 1'b0;
        o_use_powder    = 1'b0;
        o_grind_beans   = 1'b0;
        o_pour_coffee   = 1'b0;
        o_error          = 1'b0;
    end
    BEAN_SEL: begin
        o_bean_sel      = 1'b0;
        o_use_powder    = 1'b0;
        o_grind_beans   = 1'b0;
        o_pour_coffee   = 1'b0;
        o_error          = 1'b0;
    end
    GRIND: begin
        o_bean_sel      = 1'b0;
        o_use_powder    = 1'b0;
        o_grind_beans   = 1'b0;
        o_pour_coffee   = 1'b0;
        o_error          = 1'b0;
    end
    POWDER: begin
        o_bean_sel      = 1'b0;
        o_use_powder    = 1'b0;
        o_grind_beans   = 1'b0;
        o_pour_coffee   = 1'b0;
        o_error          = 1'b0;
    end
    HEAT: begin
        o_bean_sel      = 1'b0;
        o_use_powder    = 1'b0;
        o_grind_beans   = 1'b0;
        o_pour_coffee   = 1'b0;
        o_error          = 1'b0;
    end
    POUR: begin
        o_bean_sel      = 1'b0;
        o_use_powder    = 1'b0;
        o_grind_beans   = 1'b0;
        o_pour_coffee   = 1'b0;
        o_error          = 1'b0;
    end
    DRAIN: begin
        o_bean_sel      = 1'b0;
        o_use_powder    = 1'b0;
        o_grind_beans   = 1'b0;
        o_pour_coffee   = 1'b0;
        o_error          = 1'b0;
    end
    default: begin
        o_bean_sel      = 1'b0;
        o_use_powder    = 1'b0;
        o_grind_beans   = 1'b0;
        o_pour_coffee   = 1'b0;
        o_error          = 1'b0;
    end
end

// Error handling
always_comb begin
    case(state_ff)
        IDLE: begin
            o_error = 1'b0;
        end
        BEAN_SEL: begin
            if (i_sensor[0] == 1) begin
                o_error = 1'b1;
            end else if (i_sensor[1] == 1) begin
                o_error = 1'b0;
            end else if (i_sensor[2] == 1) begin
                o_error = 1'b0;
            end else begin
                o_error = 1'b0;
            end
        end
        GRIND: begin
            if (i_sensor[0] == 1) begin
                o_error = 1'b1;
            end else if (i_sensor[1] == 1) begin
                o_error = 1'b0;
            end else begin
                o_error = 1'b0;
            end
        end
        POWDER: begin
            if (i_sensor[0] == 1) begin
                o_error = 1'b1;
            end else if (i_sensor[1] == 1) begin
                o_error = 1'b0;
            end else if (i_sensor[2] == 1) begin
                o_error = 1'b0;
            end else begin
                o_error = 1'b0;
            end
        end
        HEAT: begin
            if (i_sensor[0] == 1) begin
                o_error = 1'b1;
            end else if (i_sensor[1] == 1) begin
                o_error = 1'b1;
            end else else begin
                o_error = 1'b0;
            end
        end
        POUR: begin
            if (i_sensor[0] == 1) begin
                o_error = 1'b1;
            end else if (i_sensor[1] == 1) begin
                o_error = 1'b1;
            end else begin
                o_error = 1'b0;
            end
        end
        DRAIN: begin
            if (i_sensor[0] == 1) begin
                o_error = 1'b1;
            end else if (i_sensor[1] == 1) begin
                o_error = 1'b1;
            end else else begin
                o_error = 1'b0;
            end
        end
        default: begin
            o_error = 1'b0;
        end
    endcase
end

// FSM initialization
always start:
    state_ff <= IDLE;
    i_start <= 1'b1;
end