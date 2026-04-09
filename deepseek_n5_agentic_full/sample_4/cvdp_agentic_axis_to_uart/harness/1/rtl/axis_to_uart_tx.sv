// Parameter declarations
PARAMETER CLK_FREQ = 100_000_000;
PARAMETER BIT_RATE = 115200;
PARAMETER BIT_PER_WORD = 8;
PARAMETER PARITY_BIT = 0;
PARAMETER STOP_BITS_NUM = 1;

// Module interface
input aclk;
input aresetn;
input [7..0] tdata;
input tvalid;
input tready;
output reg tx;
output reg [1:0] state;

// State variables
reg [1:0] fsm_state = 0b00;
reg clks_per_period = 0;

// Data handling and parity calculation
reg [7..0] data_reg = 0;
reg [7..0] data_shift_reg = 0;
reg parity_bitout = 0;

// Stop bits
bit [STOP_BITS_NUM-1:0] stop_bits = 0;

// Clock counter setup
integer cycle_per_period = (CLK_FREQ * 1000000) / BIT_RATE;

// Event variables
event tvalid_event;
event tready_event;
event tx_event;

// Initializations
initial begin
    // Initialize state to IDLE
    fsm_state = 0b00;
    
    // Initialize counters
    clks_per_period = 0;
    
    // Initialize data storage
    data_shift_reg = 0;
endinit

// State machine implementation
always_ff @(posedge aclk) begin
    case(fsm_state)
        0b0000: // IDLE
            if(tvalid & tready)
                fsm_state = 0b0100;
            else
                fsm_state = 0b0000;
            end
        0b0100: // START
            fsm_state = 0b0101;
        0b0101: // DATA
            if(clks_per_period == cycle_per_period - 1)
                fsm_state = fsm_state ^ 0b0010;
        0b0111: // PARITY
            if(stop_bits[0])
                fsm_state = fsm_state ^ 0b0110;
        0b1001: // STOP1
            if(stop_bits[0])
                fsm_state = fsm_state ^ 0b1000;
            else
                fsm_state = 0b0000;
        0b1010: // STOP2
            if(stop_bits[1])
                fsm_state = fsm_state ^ 0b0010;
    endcase
end

// Data latching
always_ff @(tvalid_event) begin
    if(!tvalid) 
        tvalid_event disappearance;
    else
        data_shift_reg <= tdata;
        tvalid_event appearance;
    end
end

// Parity computation
always_ff @(tvalid_event || fsm_state change) begin
    if(fsm_state == 0b0101 && !tvalid)
        parity_bitout = 0;
    else
        parity_bitout = ~((data << 7)[0] ^ parity_bitout);
    end
end

// UART TX Output Generation
always @(posedge aclk) begin
    case(fsm_state)
        0b0000: // IDLE
            tx = 1;
            tx_event appearance;
        0b0100: // START
            tx = 0;
            tx_event appearance;
        0b0101: // DATA
            tx = (data_shift_reg >> clks_per_period)[0];
            tx_event appearance;
        0b0111: // PARITY
            tx = parity_bitout;
            tx_event appearance;
        0b1001: // STOP1
            tx = 1;
            tx_event appearance;
        0b1010: // STOP2
            tx = 1;
            tx_event appearance;
    endcase
end

// Reset handling
always @(posedge aresetn) begin
    fsm_state = 0b0000;
    clks_per_period = 0;
    data_shift_reg = 0;
    parity_bitout = 0;
end

// Final initialization
initial
    $init_process();
    $monitor("Axis_to_UART_tx module started");
    $stop;
endinit

// Event cleanup
always ensure(tvalid_event, tready_event, tx_event);