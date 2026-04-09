module control_fsm #(
    parameter int NB_WAIT = 32 // Maximum wait cycles
) (
    input wire clk,
    input wire rst_async_n,
    
    // Control signals
    input wire i_enable,
    input wire i_valid,
    output wire o_valid,
    output wire o_start_calc,
    input wire i_calc_valid,
    input wire i_calc_fail,
    input wire [NB_WAIT-1:0] i_wait,
    
    // Output signals
    output reg o_subsampling,
    output reg o_start_calc,
    output reg o_valid
);

// Define the five-state FSM states
typedef enum {
    PROC_CONTROL_CAPTURE_ST,
    PROC_DATA_CAPTURE_ST,
    PROC_CALC_START_ST,
    PROC_CALC_ST,
    PROC_WAIT_ST
} proc_fsm_states;

// Define the FSM state registers
reg [1:0] fsm_state; // Current FSM state
reg [NB_WAIT-1:0] wait_count; // Wait counter for subsampling
reg [NB_WAIT-1:0] calc_count; // Countdown for calculation start
reg [NB_WAIT-1:0] general_count; // General purpose counter

// Implement the FSM control logic
always @(posedge clk or negedge rst_async_n) begin
    if (!rst_async_n) begin
        fsm_state <= PROC_CONTROL_CAPTURE_ST;
        wait_count <= 0;
        calc_count <= 0;
        general_count <= 0;
    end else begin
        case (fsm_state)
            PROC_CONTROL_CAPTURE_ST: begin
                // Data capture phase
                if (i_valid && i_enable) begin
                    // Start data capture
                    fsm_state <= PROC_DATA_CAPTURE_ST;
                    general_count <= $urandom();
                    wait_count <= i_wait;
                end
            end
            
            PROC_DATA_CAPTURE_ST: begin
                // Data capture phase
                if (general_count == 0) begin
                    // Countdown for general purpose counter
                    general_count <= general_count + 1;
                    if (general_count == 256) begin
                        // Start calculation
                        fsm_state <= PROC_CALC_START_ST;
                        calc_count <= 16;
                    end
                end else begin
                    // Increment general purpose counter
                    general_count <= general_count + 1;
                end
            end
            
            PROC_CALC_START_ST: begin
                // Calculation start phase
                if (calc_count == 16) begin
                    // Start countdown for calculation start
                    fsm_state <= PROC_CALC_ST;
                    calc_count <= 0;
                end else begin
                    // Increment countdown for calculation start
                    calc_count <= calc_count + 1;
                end
            end
            
            PROC_CALC_ST: begin
                // Perform RTL testbenches verification
                if (calc_count == 0) begin
                    // Start processing
                    fsm_state <= PROC_CALC_START_ST;
                    wait_count <= $urandom();
                end
            end
            
            PROC_WAIT_ST: begin
                // Wait for the specified time period
                if (wait_count == 10) begin
                    // Start countdown for wait period
                    fsm_state <= PROC_CONTROL_CAPTURE_ST;
                    calc_count <= 0;
                end else begin
                    // Increment wait counter
                    wait_count <= wait_count + 1;
                end
            end
        endcase
    end
endmodule