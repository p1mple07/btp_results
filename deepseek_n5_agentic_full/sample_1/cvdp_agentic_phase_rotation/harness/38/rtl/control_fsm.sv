module control_fsm (
    parameter NBW_WIDTH = 32,
    input clock,
    input rst_async_n,
    input i_enable,
    input i_subsampling,
    input i_iwait,
    output o_start_calc,
    output o_valid,
    output o_subsampling
);

    // State description
    enum states {
        PROC_CONTROL_CAPTURE_ST,
        PROC_DATA_CAPTURE_ST,
        PROC_CALC_START_ST,
        PROC_CALC_ST,
        PROC_WAIT_ST
    };

    // State and counter initialization
    state_t current_state = PROC_CONTROL_CAPTURE_ST;
    reg [NBW_WIDTH-1:0] gen_counter = 0;
    reg [NBW_WIDTH-1:0] timeout_counter = 0;

    // Implement FSM with state transitions
    always_comb begin
        // Control FSM
        case(current_state)
        // State: PROC_CONTROL_CAPTURE_ST
            default:
                // Initial state, wait for enable signal
                state_t next_state = current_state;
                if ($clock && i_enable == 1)
                    next_state = PROC_DATA_CAPTURE_ST;
                current_state = next_state;

        // State: PROC_DATA_CAPTURE_ST
            default:
                // Transition based on counter value
                if (gen_counter == 0 && i_valid == 1)
                    current_state = PROC_CALC_START_ST;
                else
                    current_state = current_state;

        // State: PROC_CALC_START_ST
            default:
                // Start calculation
                $finish #1
                o_start_calc = 1;
                gen_counter = $load(gen_counter, (i_subsampling & 1 ? 256 : 8));
                gen_counter = gen_counter - 1;
                current_state = PROC_CALC_ST;

        // State: PROC_CALC_ST
            default:
                // Wait for processing result
                if (i_calc_valid == 0)
                    current_state = PROC_WAIT_ST;
                elif (i_calc_fail == 1)
                    current_state = current_state;
                else
                    current_state = current_state;

        // State: PROC_WAIT_ST
            default:
                // Timeout handling
                timeout_counter = $load(timeout_counter, i_iwait);
                timeout_counter = timeout_counter - 1;
                if (timeout_counter == 0 || !rst_async_n)
                    current_state = current_state;
                else
                    current_state = PROC_CONTROL_CAPTURE_ST;
        endcase
    endalways

    // Handle output signals
    // Start calc assertion for one clock cycle
    always_comb begin
        if (current_state == PROC_CALC_START_ST)
            $finish #1
            o_start_calc = 0;
    endalways

    // Subsampling output
    always_comb begin
        o_subsampling = i_subsampling;
    endalways

    // Valid output
    always_comb begin
        o_valid = (i_enable & i_valid) && (gen_counter != 0);
    endalways

endmodule