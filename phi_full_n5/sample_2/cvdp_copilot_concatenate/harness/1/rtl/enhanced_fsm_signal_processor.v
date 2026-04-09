module enhanced_fsm_signal_processor(
    input clk,
    input rst_n,
    input enable,
    input clear,
    input ack,
    input fault,
    input [4:0] vector_1,
    input [4:0] vector_2,
    input [4:0] vector_3,
    input [4:0] vector_4,
    input [4:0] vector_5,
    input [4:0] vector_6,
    output reg o_ready,
    output reg o_error,
    output [1:0] o_fsm_status,
    output [7:0] o_vector_1,
    output [7:0] o_vector_2,
    output [7:0] o_vector_3,
    output [7:0] o_vector_4
);

    // State declaration
    typedef enum {IDLE, PROCESS, READY, FAULT} state_t;
    state_t current_state, next_state;

    // State register
    reg [1:0] state_reg = 2'b00; // Default to IDLE

    // State transition logic
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            current_state <= IDLE;
            state_reg <= IDLE;
        end else begin
            current_state <= state_reg;
            case (current_state)
                IDLE: begin
                    if (!enable) begin
                        state_reg <= IDLE;
                    end else if (fault) begin
                        state_reg <= FAULT;
                    end
                end
                PROCESS: begin
                    if (fault) begin
                        state_reg <= FAULT;
                    end else begin
                        o_vector_1 <= vector_1;
                        o_vector_2 <= vector_2;
                        o_vector_3 <= vector_3;
                        o_vector_4 <= vector_4;
                        state_reg <= READY;
                    end
                end
                READY: begin
                    if (ack) begin
                        state_reg <= IDLE;
                    end else if (fault) begin
                        state_reg <= FAULT;
                    end
                end
                FAULT: begin
                    o_error <= 1;
                    if (clear && !fault) begin
                        state_reg <= IDLE;
                    end
                end
            endcase
        end
    end

    // Output logic
    always @(posedge clk) begin
        o_ready <= (current_state == READY);
        o_error <= (current_state == FAULT);
        o_fsm_status <= state_reg;
        o_vector_1 <= (current_state == PROCESS) ? {vector_1, 1'b1, vector_2, 1'b1, vector_3, 1'b1, vector_4, 1'b1} : 8'b0;
        o_vector_2 <= (current_state == PROCESS) ? {vector_1, 1'b1, vector_2, 1'b1, vector_3, 1'b1, vector_4, 1'b1} : 8'b0;
        o_vector_3 <= (current_state == PROCESS) ? {vector_1, 1'b1, vector_2, 1'b1, vector_3, 1'b1, vector_4, 1'b1} : 8'b0;
        o_vector_4 <= (current_state == PROCESS) ? {vector_1, 1'b1, vector_2, 1'b1, vector_3, 1'b1, vector_4, 1'b1} : 8'b0;
    end

endmodule
