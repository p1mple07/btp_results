Module Name: uart_rx_to_axis
// Description: Converts a serial UART input into a parallel AXI-Stream output.

module uart_rx_to_axis(
    parameter_CLK_FREQ,
    parameter_BIT_RATE,
    parameter_BIT_PER_WORD,
    parameter_PARITY_BIT,
    parameter_STOP_BITS_NUM
);

    // State Variables
    reg [sizeof(bit_counter)-1:0] bit_counter;
    reg [sizeof(data_shift_reg)-1:0] data_shift_reg;
    reg [sizeof(shift_amount)-1:0] shift_amount;
    reg [sizeof(clock_counter)-1:0] clock_counter;

    // FSM State Variable
    enum fsm_state { IDLE, START, DATA, PARITY, STOP1, STOP2, OUT_RDY } fsm_state = IDLE;

    // Input Pins
    input wire [BIT_RATE-1:0] rx;
    input wire aclk;
    input wire arsetn;

    // Output Pins
    output reg [BIT_PER_WORD-1:0] tdata;
    output reg tuser;
    output reg tvalid;

    // Parameters
    parameter Cycle_per_Period = (_CLK_FREQ * 1000000 ) / BIT_RATE;

    // Initializations
    initial begin
        // Initialize state variables
        fsm_state = IDLE;
        bit_counter = 0;
        data_shift_reg = 0;
        clock_counter = 0;
        
        // Reset outputs on negative edge of system clock
        always_negedge aclk begin
            tvalid = 0;
            tuser = 0;
        end
    end

    // FSM State Transitions
    always_ff @* (
        fsm_state == IDLE && !rx || 
        fsm_state == START && (rx & 1)
    ) begin
        // Transition from IDLE to START on falling edge of rx
        fsm_state = START;
    end

    always_ff @* (
        fsm_state == START && ~rx
    ) begin
        // Transition from START to DATA after half-period delay
        fsm_state = DATA;
        bit_counter = 0;
    end

    always_ff @* (
        fsm_state == DATA && bit_counter < BIT_PER_WORD
    ) begin
        // Shift data into shift register
        data_shift_reg = (rx & 1) << shift_amount;
        shift_amount = 0;
        
        // Increment bit counter
        bit_counter++;
        
        // Transition to next state based on parity and data completion
        case (fsm_state)
            IDLE: fsm_state = START;
            START: fsm_state = DATA;
            DATA: fsm_state = PARITY;
            STOP1: fsm_state = STOP2;
            STOP2: fsm_state = OUT_RDY;
            OUT_RDY: fsm_state = IDLE;
        endcase
    end

    always_ff @* (
        fsm_state == PARITY && !rx
    ) begin
        // Transition from PARITY to STOP1
        fsm_state = STOP1;
    end

    always_ff @* (
        fsm_state == STOP1 && !rx
    ) begin
        // Transition from STOP1 to STOP2
        fsm_state = STOP2;
    end

    always_ff @* (
        fsm_state == STOP2 && !rx
    ) begin
        // Transition from STOP2 to OUT_RDY
        fsm_state = OUT_RDY;
    end

    // Parity Calculation
    integer local_num_data_bits = BIT_PER_WORD - 1;
    integer local_parity_bit = 0;

    always_ff @* (
        fsm_state == PARITY && bit_counter == local_num_data_bits
    ) begin
        // Calculate parity
        local_num_data_bits downto 0 begin
            local_parity_bit = local_parity_bit ^ rx >> i;
        end

        // Compare with actual parity bit
        if ((local_parity_bit == (rx >> (local_num_data_bits))) ? 0 : 1) != PARITY_BIT) {
            tuser = 1;
        }

        // Transition back to IDLE after parity check
        fsm_state = IDLE;
    end

    // AXI-Stream Output Generation
    // After transitioning to OUT_RDY, assert tvalid and output data
    always_ff @* (
        fsm_state == OUT_RDY
    ) begin
        tvalid = 1;
        tdata = data_shift_reg;
    end

    // Reset on falling edge of aclk
    default case (*)
        // Reset outputs
        tvalid = 0;
        tuser = 0;
    endcase
endmodule