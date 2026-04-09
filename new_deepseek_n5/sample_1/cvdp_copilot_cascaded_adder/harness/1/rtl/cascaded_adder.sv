module cascaded_adder(
    input clock,
    input rst_n,
    input i_valid,
    input [IN_DATA_WIDTH * IN_DATA_NS - 1:0] i_data,
    output [IN_DATA_WIDTH + log2(IN_DATA_NS) - 1:0] o_data,
    output o_valid
);

    // State machine control logic
    finite_state_machine fsm (
        input rst_n,
        input i_valid,
        input clock,
        output reg next_state
    );

    fsm_state = 0;
    fsm_initial_state = 0;
    fsm_next_state = fsm_initial_state;

    // Data latches
    reg [IN_DATA_WIDTH - 1:0] data_reg;
    reg [IN_DATA_WIDTH - 1:0] sum_reg;
    reg [IN_DATA_WIDTH - 1:0] next_sum_reg;

    // Control signals
    reg valid;
    reg done;

    // Initialize states
    always @(posedge clock or negedge rst_n) begin
        if (rst_n) begin
            fsm_next_state = fsm_initial_state;
            valid = 0;
            done = 0;
        end else begin
            if (i_valid) begin
                fsm_next_state = fsm_initial_state;
            end else begin
                fsm_next_state = fsm_initial_state;
            end
        end
    end

    // State transitions
    fsm always @(rst_n, i_valid, clock) begin
        case (fsm_state)
            fsm_initial_state: begin
                fsm_next_state = fsm_initial_state;
                valid = 0;
                done = 0;
            end
            fsm_initial_state: begin
                if (rst_n) begin
                    fsm_next_state = fsm_initial_state;
                    valid = 0;
                    done = 0;
                end else begin
                    if (i_valid) begin
                        fsm_next_state = fsm_initial_state + 1;
                    end else begin
                        fsm_next_state = fsm_initial_state;
                    end
                end
            end
            // ... (other state transitions) ...
        endcase
    end

    // Data processing
    always @(posedge clock) begin
        if (valid) begin
            // Unpack data and perform addition
            // ... (data processing logic) ...
            sum_reg = data_reg + next_sum_reg;
            next_sum_reg = sum_reg;
        end
    end

    // Output latches
    always @(posedge clock) begin
        if (done) begin
            o_valid = 1;
            o_data = next_sum_reg;
        end
    end

    // Final state
    fsm_state = fsm_initial_state;
endmodule