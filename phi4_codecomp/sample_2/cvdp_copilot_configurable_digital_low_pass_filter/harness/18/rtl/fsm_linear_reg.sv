module fsm_linear_reg #(
    parameter DATA_WIDTH = 16
) (
    input  logic clk,                                // Clock
    input  logic reset,                              // Asynchronous reset
    input  logic start,                              // Start signal
    input  logic signed [DATA_WIDTH-1:0] x_in,       // Input data
    input  logic signed [DATA_WIDTH-1:0] w_in,       // Trained weight (from sgd_linear_regression)
    input  logic signed [DATA_WIDTH-1:0] b_in,       // Trained bias (from sgd_linear_regression)
    output logic signed [2*DATA_WIDTH-1:0] result1,    // Output result of logic 1
    output logic signed [DATA_WIDTH:0] result2,    // Output result of logic 2
    output logic done                                // Completion signal
);

    // State Encoding
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        DONE    = 2'b10
    } state_t;

    state_t current_state, next_state;

    // Intermediate signals for combinational logic
    logic signed [2*DATA_WIDTH-1:0] compute1;
    logic signed [DATA_WIDTH:0] compute2;

    // FSM State Transition
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // FSM Next State Logic
    always_comb begin
        case (current_state)
            IDLE: begin
                if (start)
                    next_state = COMPUTE;
                else
                    next_state = IDLE;
            end
            COMPUTE: begin
                next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Combinational Logic 1: Weighted Sum of w_in and x_in
    always_comb begin
        compute1 = (w_in * x_in) >>> 1;  // Multiply and shift right by 1
    end

    // Combinational Logic 2: Weighted Sum of b_in and Shifted x_in
    always_comb begin
        compute2 = (b_in + (x_in >>> 2)); // Add b_in to x_in shifted right by 2
    end

    // FSM Output Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            result1 <= 0;
            result2 <= 0;
            done    <= 0;
        end else begin
            case (current_state)
                COMPUTE: begin
                    result1 <= compute1;
                    result2 <= compute2;
                end
                DONE: begin
                    done <= 1;
                end
                default: begin
                    result1 <= 0;
                    result2 <= 0;
                    done    <= 0;
                end
            endcase
        end
    end

endmodule