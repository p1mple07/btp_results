Module declaration
module control_fsm (
    input clock, 
    input rst_async_n, 
    input enable, 
    input subsampling_mode,
    input wait_value,
    output start_calc,
    output valid,
    output subsampling_reg,
    output calc_valid,
    output calc_fail,
    output wait_counter
);

// State declarations
enum state = {
    Idle,
    PROC_CONTROL_CAPTURE_ST,
    PROC_DATA_CAPTURE_ST,
    PROC_CALC_START_ST,
    PROC_CALC_ST,
    PROC_WAIT_ST
};
state fsm_state = Idle;

// State transitions
always @(posedge clock or negedge rst_async_n) begin
    case(fsm_state)
        Idle:
            // Initial state waits for enable
            if (enable) begin
                fsm_state = PROC_CONTROL_CAPTURE_ST;
            end
            // If enable is not asserted, stay in Idle
            default:
                fsm_state = Idle;
                wait_counter = 0;
            endcase

        PROC_CONTROL_CAPTURE_ST:
            // Captures initial control signals
            if (enable) begin
                fsm_state = PROC_DATA_CAPTURE_ST;
                wait_counter = wait_value;
            end
            default:
                fsm_state = Idle;
            endcase

        PROC_DATA_CAPTURE_ST:
            // General-purpose counter begins counting down
            if (enable && !valid || calc_valid) begin
                if (subsampling_mode) begin
                    // Count 256 valid cycles
                    wait_counter = 256;
                else begin
                    // Count 8 cycles
                    wait_counter = 8;
                end
                fsm_state = PROC CALC_START_ST;
            end
            default:
                fsm_state = Idle;
            endcase

        PROC_CALC_START_ST:
            // Triggers start of processing
            start_calc = 1;
            // Countdown using same counter
            wait_counter = 16;
            fsm_state = PROC Calc_ST;
            start_calc = 0;
            wait_counter = 0;
            default:
                fsm_state = Idle;
            endcase

        PROC Calc_ST:
            // Waits for processing result
            if (calc_valid) begin
                // Success: transition to WAIT_ST
                fsm_state = PROC_WAIT_ST;
            elsif (calc_fail) begin
                // Failure: transition back to CONTROL CAPTURE_ST
                fsm_state = PROC_CONTROL_CAPTURE_ST;
                start_calc = 1;
            end
            default:
                fsm_state = Idle;
            endcase

        PROC_WAIT_ST:
            // Timeout counter begins counting down from i_wait
            wait_counter = wait_value;
            fsm_state = PROC_CONTROL_CAPTURE_ST;
            default:
                fsm_state = Idle;
                wait_counter = 0;
            endcase
    end
end

// Output definitions
output reg start_calc, valid, subsampling_reg, calc_valid, calc_fail, wait_counter;

// Additional logic
always begin
    // Hold subsampling_mode at the beginning of the control sequence
    subsampling_reg = subsampling_mode;
end
endmodule