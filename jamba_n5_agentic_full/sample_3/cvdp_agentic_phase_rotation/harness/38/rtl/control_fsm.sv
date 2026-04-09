module control_fsm (
    input  clk,
    input  rst_async_n,
    input  i_enable,
    input  i_subsampling,
    input  o_subsampling,
    input  i_valid,
    output o_valid,
    output o_subsampling,
    output o_calc_valid,
    output o_calc_fail,
    output o_wait,
    output o_start_calc
);

// State enumeration
enum int {
    CONTROL_CAPTURE,
    DATA_CAPTURE,
    CALC_START,
    CALC_ST,
    WAIT
};

current_state current_state = CONTROL_CAPTURE;

// Clock and asynchronous reset
always @(posedge clk or posedge rst_async_n) begin
    if (rst_async_n) begin
        current_state <= CONTROL_CAPTURE;
        o_valid <= 1'b0;
        o_subsampling <= 1'b0;
        o_calc_valid <= 1'b0;
        o_calc_fail <= 1'b0;
        o_wait <= 0;
        o_start_calc <= 1'b0;
    end else begin
        // State transitions according to the FSM design
        case (current_state)
            CONTROL_CAPTURE: begin
                if (i_enable) begin
                    current_state = DATA_CAPTURE;
                    o_start_calc <= 1'b1;
                end else if (i_valid) begin
                    current_state = DATA_CAPTURE;
                end
            end
            DATA_CAPTURE: begin
                if (i_enable && !i_valid) begin
                    current_state = CALC_START;
                end else if (i_valid && i_enable) begin
                    // Transition to data capture
                    current_state = DATA_CAPTURE;
                end
                o_start_calc <= 1'b0;
            end
            CALC_START: begin
                // Start the 16‑cycle countdown
                gen_cnt <= 4'b1111;
                always_comb begin
                    if (~gen_cnt[0]) gen_cnt <= gen_cnt[1];
                    else gen_cnt <= gen_cnt[0];
                end
                #16
                if (gen_cnt == 0) begin
                    current_state = PROC_CALC_ST;
                end else begin
                    current_state = CONTROL_CAPTURE;
                end
            end
            PROC_CALC_ST: begin
                // Wait for validation or failure
                if (i_calc_valid) begin
                    current_state = PROC_WAIT_ST;
                end else if (i_calc_fail) begin
                    current_state = PROC_CONTROL_CAPTURE;
                end else begin
                    current_state = PROC_CALC_ST;
                end
                o_calc_valid <= 1'b0;
                o_calc_fail <= 1'b0;
            end
            PROC_WAIT_ST: begin
                // Load the wait value into the timeout counter
                o_wait <= i_wait;
                // Transition back to control capture
                current_state = CONTROL_CAPTURE;
                o_start_calc <= 1'b0;
            end
            default:
                current_state = CONTROL_CAPTURE;
                o_valid <= 1'b0;
                o_start_calc <= 1'b0;
                o_calc_valid <= 1'b0;
                o_calc_fail <= 1'b0;
                o_wait <= 0;
                o_start_calc <= 1'b0;
        endcase
    end
end

endmodule
