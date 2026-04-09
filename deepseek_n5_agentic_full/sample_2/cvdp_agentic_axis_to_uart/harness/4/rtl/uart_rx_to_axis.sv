Module declaration
module uart_rx_to_axis (
    parameter clocks_clk_freq = 100_000_000,
    parameter clocks_bit_rate = 115200,
    parameter clocks_bit_word = 8,
    parameter clocks_parity = 0,
    parameter clocks_stop_bits = 1
);

// Include necessary modules
#include "rtl/fifo.sv"
#include "rtl/bb_clock_counter.sv"

// Module ports
output clocks_tvalid;
output clocks_tuser;
output clocks_tdata;
input clocks_aclk;
input clocks_arstn;
input clocks_rx;

// FSM states
enum state: 8'b0 = IDLE;
enum state: 8'b1 = START;
enum state: 8'b2 = DATA;
enum state: 8'b3 = PARITY;
enum state: 8'b4 = STOP1;
enum state: 8'b5 = STOP2;
enum state: 8'b6 = OUT_RDY;

// State reg
reg state fsm = IDLE;

// Bit counter
reg [clocks_bit_word -1] bit_counter = 0;

// FIFO buffer for data
fifo_t data_FIFO;

// Shift register for data
reg [clocks_bit_word -1] data_shift_reg = 0;

// Parity flags
reg parity_computed, parity_result;

// FSM control logic
always @* begin
    case(fsm)
        IDLE:
            // Initial state: wait for start bit
            if (arstn)
                fsm = IDLE;
            else if (rx == 1)
                fsm = START after 1ns;
            endcase

        START:
            // Start bit detection
            if (arstn)
                fsm = START after 1ns;
            else if (rx == 0)
                fsm = DATA after 1ns;
            endcase

        DATA:
            // Data bit sampling
            if (arstn)
                fsm = DATA after 1ns;
            else if (bit_counter == 0)
                fsm = DATA after 1ns;
            endcase

        PARITY:
            // Parity bit sampling
            if (arstn)
                fsm = PARITY after 1ns;
            else if (parity_mode == 1 || parity_mode == 2)
                fsm = PARITY after 1ns;
            endcase

        STOP1:
            // First stop bit sampling
            if (arstn)
                fsm = STOP1 after 1ns;
            else if (rx == 1)
                fsm = STOP1 after 1ns;
            endcase

        STOP2:
            // Second stop bit sampling
            if (arstn)
                fsm = STOP2 after 1ns;
            else if (clocks_bit_rate > 0 && rx == 1)
                fsm = STOP2 after 1ns;
            endcase

        OUT_RDY:
            // Valid data ready
            tvalid = 1;
            // Output data
            tdata = data_FIFO.value;
            // Reset state
            fsm = IDLE after 1ns;
            arstn = 1;
            endcase
    endcase
end

// Calculate cycle per period
reg uint32_t Clk_Count = 0;
always @posedge clocks_aclk #((clocks_clk_freq * 1000000) / clocks_bit_rate - 1);
begin
    Clk_Count <= Clk_Count + 1;
    // Check if overflow occurred (if using 32-bit count)
    if (Clk_Count >= (clocks_clk_freq * 1000000) / clocks_bit_rate)
        Clk_Count = 0;
end

// Data handling
always @* begin
    case(fsm)
        IDLE | START | DATA | PARITY | STOP1 | STOP2:
            // No data handling
            data_FIFO.next = 0;
            break;
        OUT_RDY:
            // Load data from FIFO
            data_FIFO.next = data_shift_reg;
            break;
        default:
            data_FIFO.next = 0;
            break;
    endcase
end

// Parity calculation
always @* begin
    case(fsm)
        IDLE | START | DATA | PARITY | STOP1:
            parity_computed = 1;
            break;
        default:
            parity_computed = 0;
            break;
    endcase
    if (parity_mode == 0)
        parity_result = 0;
    else if (parity_mode == 1)
        parity_result = ~data_shift_reg[0];
    else if (parity_mode == 2)
        parity_result = parity_computed ^ data_shift_reg[0];
    endcase
end

// Parity error indication
always @* begin
    case(fsm)
        IDLE | START | DATA | PARITY | STOP1 | STOP2 | OUT_RDY:
            tuser = 0;
            break;
        default:
            tuser = parity_result;
            break;
    endcase
end

// Reset initialization
initial begin
    // Initialize all registers and counters
    $init_process();
    // Reset the module
    $rst(1'0);
    // Wait for the next rising edge
    while ($clk_rising(clks_aclk)) $finish;
end
endmodule