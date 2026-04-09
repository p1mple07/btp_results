Module Name: axis_to_uart_tx
// Description: Configurable UART transmitter with FIFO and various control features.

module axis_to_uart_tx (
    parameter_CLK_FREQ,
    parameter_BIT_RATE,
    parameter_BIT_PER_WORD,
    parameter_PARITY_BIT,
    parameter_STOP_BITS_NUM,
    input aclk,
    input aresetn,
    input tdata,
    input tvalid,
    input tready,
    output TX
);

// FSM states
enum state {
    // IDLE state: Waiting for valid data
    IDLE = 0,
    // START state: Transmitting start bit
    START = 1,
    // DATA state: Transmitting data bits
    DATA = 2,
    // PARITY state: Transmitting optional parity bit
    PARITY = 3,
    // STOP1 state: Transmitting first stop bit
    STOP1 = 4,
    // STOP2 state: Transmitting second stop bit (if configured)
    STOP2 = 5,
    // Default next state: For invalid transitions
    Default = 6
};

// Variables
reg [31:0] t_count; // Time counter
reg [7:0] Clk_Count; // Clk counter
reg [BIT_PER_WORD-1:0] ShiftReg; // Shift register for data storage
reg [1:0] ParityReg; // Parity bit register

// FSM variables
reg state FSM_state;
reg [6:0] FSM_next_state;

// Parameters
parameter CYCLE_PER_PERIOD = (_CLK_FREQ * 1000000 ) / BIT_RATE;
parameter WORD_DURATION = (BIT_RATE == 0 ? 0 : ( (1000000000 / BIT_RATE) + 1 )) ;

// Initialization
initial begin
    t_count = 0;
    Clk_Count = 0;
    ShiftReg = 0;
    FSM_state = IDLE;
end

// State transition functions
always @posedge aclk begin
    if (aresetn) 
        FSM_state = IDLE;
    else 
        FSM_state = FSM_next_state;
end

// Start state
always @(tdata, tvalid, tready) begin
    if (!tvalid || !tready) 
        FSM_next_state = IDLE;
    else 
        FSM_next_state = START;
end

// Data state
always @negative edge Clk_Count begin
    if (tvalid && tready) begin
        t_count = t_count + 1;
        if (t_count >= Bit_per_word) begin
            FSM_next_state = START;
        else 
            FSM_next_state = DATA;
        end
    end
end

// Parity state
always @negative edge Clk_Count begin
    if (tvalid && tready) begin
        t_count = t_count + 1;
        FSM_next_state = PARITY;
    end
end

// Stop1 state
always @negative edge Clk_Count begin
    if (tvalid && tready) begin
        t_count = t_count + 1;
        FSM_next_state = STOP1;
    end
end

// Stop2 state
always @negative edge Clk_Count begin
    if (tvalid && tready) begin
        t_count = t_count + 1;
        FSM_next_state = (STOP BITS_NUM == 2) ? STOP2 : IDLE;
    end
end

// Generate TX output
always @* begin
    case(FSM_state)
        IDLE: TX = 1;
        START: TX = 0;
        DATA: TX = (ShiftReg & 1);
        PARITY: TX = ParityReg[1];
        STOP1: TX = 1;
        STOP2: TX = 1;
        Default: TX = 1;
    endcase
end

// Reset handling
always @posedge aresetn begin
    if (reset == 1)
        t_count = 0;
        Clk_Count = 0;
        ShiftReg = 0;
        FSM_state = IDLE;
    end
end

endmodule