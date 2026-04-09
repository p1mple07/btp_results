// Fixed delays (bean selection and powder usage)
localparam SEL_CYCLES    = 'd3;
localparam POWDER_CYCLES = 'd2;

// FSM update
always_comb begin
    case(state_ff)
        IDLE: begin
            counter_nx = 0;

            if(start_ff) begin
                if(~(|i_operation_sel[2:1])) begin
                    state_nx = HEAT;
                end else if(i_operation_sel[1]) begin
                    state_nx = BEAN_SEL;
                end else if(i_operation_sel[0]) begin
                    state_nx = POUR;
                end else begin
                    state_nx = POWDER;
                end
            end else begin
                state_nx = IDLE;
            end
        end
        BEAN_SEL: begin
            if(counter_ff >= SEL_CYCLES) begin
                counter_nx = 0;
                state_nx   = GRIND;
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx   = BEAN_SEL;
            end
        end
        GRIND: begin
            if(counter_ff >= grind_delay_ff) begin
                counter_nx = 0;
                if(operation_sel_ff[0]) begin
                    state_nx = POWDER;
                end else begin
                    state_nx = HEAT;
                end
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx   = GRIND;
            end
        end
        POWDER: begin
            if(counter_ff >= POWDER_CYCLES) begin
                counter_nx = 0;
                state_nx   = POUR;
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx   = POWDER;
            end
        end
        HEAT: begin
            if(counter_ff >= heat_delay_ff) begin
                counter_nx = 0;
                if(|operation_sel_ff[1:0]) begin
                    state_nx = POWDER;
                end else begin
                    state_nx = POUR;
                end
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx   = HEAT;
            end
        end
        POUR: begin
            if(counter_ff >= pour_delay_ff) begin
                counter_nx = 0;
                state_nx   = IDLE;
            end else begin
                counter_nx = counter_ff + 1'b1;
                state_nx   = POUR;
            end
        end
        default: begin
            counter_nx = 0;
            state_nx   = IDLE;
            o_error = 1'b1;
        end
    endcase
end

// Controller outputs
always_comb begin
    case(state_ff)
        IDLE: begin
            o_bean_sel      = {NS_BEANS{1:0}};
            o_use_powder    = 1'b0;
            o_grind_beans   = 1'b0;
            o_heat_water    = 1'b0;
            o_pour_coffee   = 1'b0;
        end
        BEAN_SEL: begin
            o_bean_sel                      = 1'b0;
            o_bean_sel[bean_sel_in_ff]      = 1'b1; // Only the position of bean_sel_ff should be 1
            o_grind_beans                   = 1'b0;
            o_use_powder                    = 1'b0;
            o_heat_water                    = 1'b0;
            o_pour_coffee                   = 1'b0;
        end
        GRIND: begin
            o_bean_sel      = {NS_BEANS{1:0}};
            o_grind_beans   = 1'b1;
            o_use_powder    = 1'b0;
            o_heat_water    = 1'b0;
            o_pour_coffee   = 1'b0;
        end
        POWDER: begin
            o_bean_sel      = {NS_BEANS{1:0}};
            o_grind_beans   = 1'b0;
            o_use_powder    = 1'b1;
            o_heat_water    = 1'b0;
            o_pour_coffee   = 1'b0;
        end
        HEAT: begin
            o_bean_sel      = {NS_BEANS{1:0}};
            o_grind_beans   = 1'b0;
            o_use_powder    = 1'b0;
            o_heat_water    = 1'b1;
            o_pour_coffee   = 1'b0;
        end
        POUR: begin
            o_bean_sel      = {NS_BEANS{1:0}};
            o_grind_beans   = 1'b0;
            o_use_powder    = 1'b0;
            o_heat_water    = 1'b0;
            o_pour_coffee   = 1'b1;
        end
        default: begin
            o_bean_sel      = {NS_BEANS{1:0}};
            o_grind_beans   = 1'b0;
            o_use_powder    = 1'b0;
            o_heat_water    = 1'b0;
            o_pour_coffee   = 1'b0;
            o_error          = 1'b1;
        end
    endcase
end