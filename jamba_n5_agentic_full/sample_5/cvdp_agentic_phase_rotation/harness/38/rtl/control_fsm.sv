module control_fsm #(
    parameter NBW_WAIT = 32
)(
    input clk,
    input rst_async_n,
    input i_enable,
    input i_subsampling,
    input i_valid,
    input o_valid,
    input i_calc_valid,
    input i_calc_fail,
    input i_wait,
    output reg o_start_calc,
    output reg o_valid,
    output reg o_subsampling,
    output reg o_start_calc_trigger
);

reg [31:0] general_counter;
reg timeout_counter;
reg [31:0] subsampling_value;
reg is_capturing;
reg is_calculating;
reg is_waiting;

// State transitions
always_comb begin
    case (state)
        PROC_CONTROL_CAPTURE_ST: begin
            // Capture control signals
            i_enable <= i_enable;
            i_subsampling <= i_subsampling;
            general_counter <= 32'hFFFF;
            is_capturing = 1'b1;
            o_start_calc = 1'b0;
        end

        PROC_DATA_CAPTURE_ST: begin
            if (i_enable) begin
                is_capturing = 1'b1;
                general_counter <= 32'h0;
                o_start_calc = 1'b1;
            end else begin
                is_capturing = 1'b0;
            end
        end

        PROC_CALC_START_ST: begin
            is_calculating = 1'b1;
            // countdown 16 cycles
            if (is_capturing) begin
                timeout_counter <= 16;
            end
        end

        PROC_CALC_ST: begin
            if (i_calc_valid) begin
                is_calculating = 1'b0;
            end else if (i_calc_fail) begin
                is_calculating = 1'b0;
            end else begin
                timeout_counter <= timeout_counter - 1;
                if (timeout_counter == 0) begin
                    state = PROC_WAIT_ST;
                end else begin
                    state = PROC_CALC_ST;
                end
            end
        end

        PROC_WAIT_ST: begin
            if (i_wait == 32'h0) begin
                state = PROC_CONTROL_CAPTURE_ST;
            end else begin
                state = PROC_WAIT_ST;
            end
        end
    endcase
endalways

assign o_start_calc = (state == PROC_CONTROL_CAPTURE_ST) ? 1'b1 : 1'b0;
assign o_valid = (state == PROC_DATA_CAPTURE_ST) && i_valid;
assign o_subsampling = i_subsampling;
assign o_start_calc_trigger = (state == PROC_CONTROL_CAPTURE_ST) ? 1'b1 : 1'b0;

endmodule
