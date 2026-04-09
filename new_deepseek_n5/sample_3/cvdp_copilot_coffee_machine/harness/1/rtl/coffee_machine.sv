// Fixed delays (bean selection and powder usage)
localparam SEL_CYCLES    = 'd3;
localparam POWDER_CYCLES = 'd2;

// typedef enum logic [2:0] {
//     IDLE     = 3'b000,
//     BEAN_SEL = 3'b001,
//     GRIND    = 3'b010,
//     POWDER   = 3'b011,
//     HEAT     = 3'b100
// } state_t;

// Register
logic [NBW_DLY:0]     counter_ff, counter_nx;
logic [NBW_DLY-1:0]   grind_delay_ff, heat_delay_ff, pour_delay_ff;
logic [NS_OP-1:0]     operation_sel_ff;
logic [NS_BEANS-1:0] bean_sel_in_ff;
logic                 start_ff;

// Output assignment (error conditions)
always_comb begin : error_logic
    if(state_ff == IDLE) begin
        o_error = (i_sensor[0] | i_sensor[3]) 
                | (&i_operation_sel[2:1]) 
                | (i_operation_sel[1] & i_sensor[1]) 
                | ((i_operation_sel == 3'b100 || i_operation_sel == 3'b101) & i_sensor[2]);
    end else begin
        o_error = i_sensor[3];
    end
end

// Register
always @(posedge clk) begin : data_regs
    if(~rst_async_n) begin
        state_ff <= IDLE;
    end else begin
        state_ff <= state_nx;
    end
end

// FSM update
always_comb begin
    case(state_ff)
        IDLE: begin
            counter_nx = 0;
            o_bean_sel = {NS_BEANS{1'b0}};
            o_grind_beans = 1'b0;
            o_use_powder = 1'b0;
            o_heat_water = 1'b0;
            o_pour_coffee = 1'b0;
            start_ff <= i_start & ~(i_sensor[0] | i_sensor[3]) & (~i_operation_sel[2:1]) & ~i_operation_sel[1] & ~i_sensor[1] & ~((i_operation_sel == 3'b100 || i_operation_sel == 3'b101) & i_sensor[2]);
        end
        BEAN_SEL: begin
            if(counter_ff >= SEL_CYCLES) begin
                counter_nx = 0;
                state_nx = GRIND;
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx = BEAN_SEL;
            end
        end
        GRIND: begin
            if(counter_ff >= POWDER_CYCLES) begin
                counter_nx = 0;
                if(operation_sel_ff[0]) begin
                    state_nx = POWDER;
                end else begin
                    state_nx = HEAT;
                end
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx = GRIND;
            end
        end
        POWDER: begin
            if(counter_ff >= POWDER_CYCLES) begin
                counter_nx = 0;
                state_nx = POUR;
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx = POWDER;
            end
        end
        HEAT: begin
            if(counter_ff >= POWDER_CYCLES) begin
                counter_nx = 0;
                if(|operation_sel_ff[1:0]) begin
                    state_nx = POWDER;
                end else begin
                    state_nx = POUR;
                end
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx = HEAT;
            end
        end
        POUR: begin
            if(counter_ff >= POWDER_CYCLES) begin
                counter_nx = 0;
                state_nx = IDLE;
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx = POUR;
            end
        end
        default: begin
            counter_nx = 0;
            state_nx = IDLE;
        end
    endcase
end

// Controller outputs
always_comb begin
    case(state_ff)
        IDLE: begin
            o_bean_sel = {NS_BEANS{1'b0}};
            o_grind_beans = 1'b0;
            o_use_powder = 1'b0;
            o_heat_water = 1'b0;
            o_pour_coffee = 1'b0;
        end
        BEAN_SEL: begin
            o_bean_sel = 1'b0;
            o_bean_sel[bean_sel_in_ff] = 1'b1;
            o_grind_beans = 1'b0;
            o_use_powder = 1'b0;
            o_heat_water = 1'b0;
            o_pour_coffee = 1'b0;
        end
        GRIND: begin
            o_bean_sel = {NS_BEANS{1'b0}};
            o_grind_beans = 1'b1;
            o_use_powder = 1'b0;
            o_heat_water = 1'b0;
            o_pour_coffee = 1'b0;
        end
        POWDER: begin
            o_bean_sel = {NS_BEANS{1'b0}};
            o_use_powder = 1'b1;
            o_grind_beans = 1'b0;
            o_heat_water = 1'b0;
            o_pour_coffee = 1'b0;
        end
        HEAT: begin
            o_bean_sel = {NS_BEANS{1'b0}};
            o_grind_beans = 1'b0;
            o_use_powder = 1'b0;
            o_heat_water = 1'b1;
            o_pour_coffee = 1'b0;
        end
        POUR: begin
            o_bean_sel = {NS_BEANS{1'b0}};
            o_grind_beans = 1'b0;
            o_use_powder = 1'b0;
            o_heat_water = 1'b0;
            o_pour_coffee = 1'b1;
        end
        default: begin
            o_bean_sel = {NS_BEANS{1'b0}};
            o_grind_beans = 1'b0;
            o_use_powder = 1'b0;
            o_heat_water = 1'b0;
            o_pour_coffee = 1'b0;
        end
    endcase
end