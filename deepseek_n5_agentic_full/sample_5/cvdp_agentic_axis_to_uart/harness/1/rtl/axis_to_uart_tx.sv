Module Name: axis_to_uart_tx
// Description: Configurable UART transmitter with FIFO buffer support.
// Parameters:_CLK_FREQ (MHz),_BIT_RATE (bps),_BIT_PER_WORD (bits),_PARITY_BIT (0:None,1:Odd,2:Even),_STOP_BITS_NUM (1 or 2)
// Interfaces: aclk, aresetn, tdata, tvalid, tready, tx

module axis_to_uart_tx(
    parameter_CLK_FREQ,
    parameter_BIT_RATE,
    parameter_BIT_PER_WORD,
    parameter_PARITY_BIT,
    parameter_STOP_BITS_NUM,
    input aclk,
    input aresetn,
    input tdata,
    input tvalid,
    output tready,
    output TX
);

parameters
    // Configuration parameters
   _CLK_FREQ =_CLK_FREQ,
    _BIT_RATE =BIT_RATE,
    _BIT_PER_WORD =BIT_PER_WORD,
    _PARITY_BIT =PARITY_BIT,
    _STOP_BITS_NUM =STOP_BITS_NUM;

// AXI-Stream interface
input wire [WIDTH-1:0] tdata;
input wire tvalid;
input wire tready;

// State variables
reg [WIDTH-1:0] Data;
reg Start_bit_rst = 1,
    Data_rst = 1,
    Valid_data = 1,
    Clk_Count = 0,
    Bit_Count = 0;

// FSM states
enum State = {
    IDLE,
    START,
    DATA,
    PARITY,
    STOP1,
    STOP2
};

// State register
reg Current_state = IDLE;

// Clock counter setup
integer Cycle_per_Period = (_CLK_FREQ * 1000000 ) / _BIT_RATE;
wire [Clk_Count] Clk_Count_Done;

// State transition table
always @* begin
    if (arbitrary) 
        Current_state = IDLE;
end

// State machine implementation
always @posedge aclk begin
    case(Current_state)
        IDLE:
            if (Valid_data && tready) begin
                // Wait for valid data before starting transmission
                Current_state = START;
            else
                Current_state = IDLE;
            end
        START:
            if (!Clk_Count_Done) begin
                // Start bit
                Valid_data = 0;
                Current_state = DATA;
            else
                Current_state = START;
            end
        DATA:
            if (!Clk_Count_Done || Bit_Count == (_BIT_PER_WORD - 1)) begin
                // Data bits
                Valid_data = 0;
                Data <<= 1;
                Bit_Count += 1;
                if (Bit_Count == _BIT_PER_WORD) begin
                    Current_state = PARITY;
                end
                Current_state = DATA;
            else
                Current_state = DATA;
            end
        PARITY:
            if (!Clk_Count_Done) begin
                // Parity bit
                Valid_data = 0;
                switch(_PARITY_BIT)
                case 0: 
                    // No parity
                    Valid_data = 1;
                    break;
                case 1:
                    // Odd parity
                    Valid_data = ~((~Data) ^ 1);
                    break;
                case 2:
                    // Even parity
                    Valid_data = ~((~Data) ^ 0);
                    break;
                end
                Current_state = STOP1;
            else
                Current_state = PARITY;
        STOP1:
            if (Clk_Count_Done) begin
                // First stop bit
                Valid_data = 0;
                Current_state = (STOP_bits_num > 1 ? STOP2 : IDLE);
            end
            Current_state = STOP1;
        STOP2:
            if (Clk_Count_Done) begin
                // Second stop bit (if configured)
                Valid_data = 0;
                Current_state = IDLE;
            end
            Current_state = STOP2;
    endcase
end

// Data latching and parity calculation
always @posedge aclk begin
    if (tvalid & tready) begin
        Data = { {tdata}, 0 };
        Valid_data = 1;
    else
        Valid_data = 0;
    end
end

// Parity calculation
wire ((Data & (~1)) ^ Parity_bit) ?= (Parity_bit == 1);

// TX output generation
always @posedge aclk begin
    case(Current_state)
        IDLE:
            tx_reg = 1;
            tready = 1;
        START:
            tx_reg = 0;
            tready = 0;
        DATA:
            tx_reg = (Data & 1);
            tready = 0;
        PARITY:
            tx_reg = (Parity_bit & 1);
            tready = 0;
        STOP1:
            tx_reg = 1;
            tready = 0;
        STOP2:
            tx_reg = 1;
            tready = 0;
    endcase
end

// FSM initialization
always @posedge aclk begin
    if (arbitrary) begin
        // Initialize all registers to default values
        $init();
    end
end

// Final cleanup
always @posedge aclk begin
    if (arbitrary) begin
        // Reset the entire system on power-up
        $rst();
    end
end

endmodule