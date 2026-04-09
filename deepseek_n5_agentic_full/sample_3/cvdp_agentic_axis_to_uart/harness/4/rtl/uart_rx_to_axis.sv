Module Name: uart_rx_to_axis
module uart_rx_to_axis(
    parameter real_CLK_FREQ, // in MHz
    parameter integer BIT_RATE, // in bps
    parameter integer BIT_PER_WORD = 8, // number of bits per word
    parameter integer PARITY_BIT = 0, // 0=none, 1=odd, 2=even
    parameter integer STOP_BITS_NUM = 1 // 1 or 2
);

    // Parameters for clock and timing calculations
    parameter integer Cycle_per_Period = (_CLK_FREQ * 1000000 ) / BIT_RATE;
    
    // FSM states
    enum states {
        IDLE,
        START,
        DATA,
        PARITY,
        STOP1,
        STOP2,
        OUT_RDY
    };

    // State variables
    reg current_state = IDLE;
    reg bit_count = 0;
    reg [BIT_PER_WORD-1:0] data_shift_reg;
    reg parity_check = 0;

    // Input signals
    input wire aclk;
    input wire areshetn;
    input wire [BIT_RATE-1:0] RX;

    // Output signals
    output reg [BIT_PER_WORD-1:0] tdata;
    output reg tuser;
    output reg tvalid;

    // FSM control logic
    always @* begin
        case(current_state)
            IDLE:
                if (RX == high)
                    current_state = START;
                else
                    current_state = IDLE;
            
            START:
                if (bit_count >= Cycle_per_Period) begin
                    current_state = DATA;
                    bit_count = 0;
                end
            
            DATA:
                data_shift_reg[0] = RX;
                bit_count++;
                
                if (bit_count >= Cycle_per_Period) begin
                    current_state = PARITY;
                    bit_count = 0;
                end
            
            PARITY:
                if (PARITY_BIT != 0) begin
                    parity_check = 0;
                    for (integer i = 0; i < BIT_RATE; i++) {
                        parity_check ^= data_shift_reg[i];
                    }
                    parity_check = parity_check ^ (RX & (1 << (Cycle_per_Period - 1)));
                end
                
                if (bit_count >= Cycle_per_Period) begin
                    current_state = STOP1;
                    bit_count = 0;
                end
            
            STOP1:
                if (bit_count >= Cycle_per_Period) begin
                    current_state = STOP2;
                    bit_count = 0;
                end
            
            STOP2:
                if (bit_count >= Cycle_per_Period) begin
                    current_state = OUT_RDY;
                    bit_count = 0;
                end
            
            OUT_RDY:
                tvalid = 1;
                tdata = data_shift_reg;
                tuser = 0;
                current_state = IDLE;
        endcase
    end

    // Parity generation logic
    always @* begin
        if (PARITY_BIT != 0 && current_state == IDLE) begin
            integer i;
            parity_check = 0;
            for (i = 0; i < BIT_RATE; i++) {
                parity_check ^= RX & (1 << (Cycle_per_Period - 1 - i));
            }
        end
    end

endmodule