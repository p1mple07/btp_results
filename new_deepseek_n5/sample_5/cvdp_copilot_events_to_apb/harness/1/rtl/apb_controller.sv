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

    // State variables
    reg state = IDLE;
    reg [31:0] addr = 0;
    reg [31:0] data = 0;
    reg [3:0] timeout_counter = 0;

    // Event processing
    always @posedge clock begin
        case (state)
            IDLE:
                if (select_a_i || select_b_i || select_c_i) begin
                    // Determine highest priority event
                    select_a_i ? addr = addr_a_i; data = data_a_i : 
                        select_b_i ? addr = addr_b_i; data = data_b_i : 
                        addr = addr_c_i; data = data_c_i;
                    state = IDLE;
                end
            SETUP:
                // Setup phase
                apb_psel_o = 1;
                apb_pwrite_o = 1;
                apb_paddr_o = addr;
                apb_pwdata_o = data;
                apb_penable_o = 0;
                state = ACCESS;
            ACCESS:
                apb_penable_o = 1;
                while (1) begin
                    if (apb_pready_i) begin
                        // Transaction completed
                        apb_psel_o = 0;
                        apb_penable_o = 0;
                        apb_pwrite_o = 0;
                        apb_paddr_o = 0;
                        apb_pwdata_o = 0;
                        state = IDLE;
                        break;
                    end
                    if (timeout_counter >= 15) begin
                        // Timeout occurred
                        apb_psel_o = 0;
                        apb_penable_o = 0;
                        apb_pwrite_o = 0;
                        apb_paddr_o = 0;
                        apb_pwdata_o = 0;
                        state = IDLE;
                        timeout_counter = 0;
                        break;
                    end
                    timeout_counter = timeout_counter + 1;
                end
        default:
            // No event processing
            state = IDLE;
    end

    // Initial state
    initial state = IDLE;
    // Initialize outputs
    apb_psel_o = 0;
    apb_penable_o = 0;
    apb_pwrite_o = 0;
    apb_paddr_o = 0;
    apb_pwdata_o = 0;

    // State mappings
    IDLE: addr = 0, data = 0, timeout_counter = 0;
    default: 
        addr = 0, data = 0, timeout_counter = 0;