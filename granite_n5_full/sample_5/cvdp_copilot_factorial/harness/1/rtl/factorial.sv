module factorial_rtl
#(
    parameter NUM_BITS = 5
)
(
    input logic clk,
    input logic arst_n,
    input logic [NUM_BITS - 1 : 0] num_in,
    input logic start,
    output logic busy,
    output logic [63 : 0] fact,
    output logic done
);

    typedef enum logic {
        IDLE,
        BUSY,
        DONE
    } fsm_state_t;

    // Declare internal signals and variables here

    // Implement FSM here

    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            // Reset values here
        end else begin
            // Update signals based on FSM state transitions
        end
    end

endmodule