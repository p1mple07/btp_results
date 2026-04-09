
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
