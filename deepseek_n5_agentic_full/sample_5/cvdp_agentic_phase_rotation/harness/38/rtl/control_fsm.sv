module control_fsm (
    input clock,
    input rst_async_n,
    input i_enable,
    input i_subsampling,
    input i_iwai,
    input i_valid,
    input i_calc_valid,
    input i_calc_fail,
    output o_start_calc,
    output o_valid,
    output o_subsampling
);

    state state = 0;

    // Initial state
    always @posedge clock begin
        if (rst_async_n)
            state = 4;
        else if (i_enable)
            state = 1;
        else 
            state = 4;
    end

    // State 1: PROC_CONTROL_CAPTURE_ST
    always @posedge clock when (state == 1) begin
        if (i_enable)
            state = 2;
        else
            state = 4;
    end

    // State 2: PROC_DATA_CAPTURE_ST
    always @posedge clock when (state == 2) begin
        // Initialize counter based on subsampling
        integer cnt;
        if (i_subsampling)
            cnt = 256;
        else
            cnt = 8;
        
        while (!i_valid) #1
            cnt = cnt - 1;
        end
        
        if (cnt == 0)
            state = 3;
        else
            state = 2;
    end

    // State 3: PROC_CALC_START_ST
    always @posedge clock when (state == 3) begin
        o_start_calc = 1;
        state = 4;
        // Countdown for calc
        integer cnt2;
        cnt2 = 16;
        while (cnt2 > 0) #1
            cnt2 = cnt2 - 1;
            state = 4;
        end
        state = 4;
    end

    // State 4: PROC_CALC_ST
    always @posedge clock when (state == 4) begin
        if (i_calc_valid)
            o_valid = 0;
        else if (i_calc_fail)
            state = 1;
        else
            state = 4;
    end

    // State 5: PROC_WAIT_ST
    always @posedge clock when (state == 5) begin
        integer cnt3;
        cnt3 = i_iwai;
        while (!rst_async_n && !i_enable) #1
            cnt3 = cnt3 - 1;
            if (cnt3 == 0)
                state = 1;
            else
                state = 5;
        end
        if (!rst_async_n && !i_enable)
            state = 5;
    end

    // Outputs
    assign o_subsampling = i_subsampling;

endmodule