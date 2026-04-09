Module: apb_controller
module apb_controller (
    input clock,
    input reset_n,
    input select_a_i,
    input select_b_i,
    input select_c_i,
    input [31:0] addr_a_i,
    input [31:0] data_a_i,
    input [31:0] addr_b_i,
    input [31:0] data_b_i,
    input [31:0] addr_c_i,
    input [31:0] data_c_i,
    output reg apb_psel_o,
    output reg apb_penable_o,
    output reg apb_pwrite_o,
    output reg [31:0] apb_paddr_o,
    output reg [31:0] apb_pwdata_o
);

// State machine states
enum state_t: 3;
state_t state = IDLE;

// State transitions and behavior
always @posedge clock begin
    case(state)
        IDLE:
            // Check for events
            if (select_a_i) begin
                // Event A has highest priority
                apb_paddr_o = addr_a_i;
                apb_pwdata_o = data_a_i;
                apb_psel_o = 1;
                state = SETUP;
                continue;
            end
            else if (select_b_i) begin
                // Event B has next priority
                apb_paddr_o = addr_b_i;
                apb_pwdata_o = data_b_i;
                apb_psel_o = 1;
                state = SETUP;
                continue;
            end
            else if (select_c_i) begin
                // Event C has lowest priority
                apb_paddr_o = addr_c_i;
                apb_pwdata_o = data_c_i;
                apb_psel_o = 1;
                state = SETUP;
                continue;
            end
            // No event, stay in IDLE
            default: state = IDLE;
            endcase
        SETUP:
            // Assert APB signals
            apb_psel_o = 1;
            apb_pwrite_o = 1;
            apb_paddr_o = 0;
            apb_pwdata_o = 0;
            state = ACCESS;
            continue;
        ACCESS:
            // Wait for ready signal
            if (apb_pready_i) begin
                // Transaction complete
                apb_psel_o = 0;
                apb_penable_o = 0;
                state = IDLE;
                continue;
            end
            // Otherwise, check timeout
            if (timeout_counter <= 15) begin
                // Timeout occurred
                apb_psel_o = 0;
                apb_penable_o = 0;
                apb_pwrite_o = 0;
                apb_paddr_o = 0;
                state = IDLE;
                timeout_counter = 0;
                continue;
            end
            // Timeout not occurred, stay in ACCESS
            timeout_counter = timeout_counter + 1;
            continue;
    endcase
end

// Timeout counter
reg unsigned timeout_counter = 0;

// Initial state
initial state = IDLE;
endmodule