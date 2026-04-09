Module Name: uart_rx_to_axis
// Description: Converts a serial UART input to a parallel AXI-Stream output
// Parameters: CLK_FREQ, BIT_RATE, BIT_PER_WORD, PARITY_BIT, STOP_BITS_NUM
// Interfaces: aclk, arstn, rx, tdata, tuser, tvalid

module uart_rx_to_axis(
    parameter integer_CLK_FREQ,
    parameter integer_BIT_RATE,
    parameter integer_BIT_PER_WORD,
    parameter integer_PARITY_BIT,
    parameter integer_STOP_BITS_NUM
);

// State variables
integer state = 0;
integer clks_counter = 0;
integer start_bit_counter = 0;
integer data_bit_counter = 0;

// FSM states
enum state_state_t {
    // IDLE: Waiting for start bit
    IDLE = 0,
    // START: Detecting start bit
    START = 1,
    // DATA: Sampling data bits
    DATA = 2,
    // PARITY: Checking parity bit
    PARITY = 3,
    // STOP1: Waiting for first stop bit
    STOP1 = 4,
    // STOP2: Waiting for second stop bit (if applicable)
    STOP2 = 5,
    // OUT_RDY: Validated data ready
    OUT_RDY = 6
};

// Calculate Cycle_per_Period
integer Cycle_per_Period = (_CLK_FREQ * 1000000 ) / BIT_RATE;

// Initialize clock counter
always_ff (clks_counter) begin
    clks_counter <= 0;
end

// Shift register for data bits
reg [BIT_PER_WORD-1:0] data_shift_reg = 0;

// Parity circuit
wire [0:0] parity_check;
integer actual_parity = 0;

// FSM logic
always_ff (state) begin
    case(state)
        IDLE:
            // Wait for start bit
            wait for 1 negative edge on rx;
            state = START;
            start_bit_counter = 0;
            clks_counter = 0;
            initial_delay( (Cycle_per_Period - 1) );
        
        START:
            // Center-aligned start bit detection
            if (rx & 1 && clks_counter == (Cycle_per_Period >> 1)) begin
                state = DATA;
                start_bit_counter = 0;
                clks_counter = 0;
            end
        
        DATA:
            // Sample data bits
            if (!rst) begin
                data_shift_reg <= (rx >> start_bit_counter);
                start_bit_counter++;
                
                if (start_bit_counter >= BIT_PER_WORD) begin
                    if (PARITY_BIT != 0) begin
                        // Compute parity
                        actual_parity = data_shift_reg ^ {(BIT_PER_WORD-1):0} parity_check[0];
                        parity_check <= parity_check ^ parity_check[0];
                    end
                    
                    if (data_shift_reg == parity_check && PARITY_BIT != 0) begin
                        // Parity matches
                        if (STOP_BITS_NUM > 1) begin
                            // Expect additional stop bit(s)
                            state = STOP1;
                        else
                            state = OUT_RDY;
                        end
                    else
                        // Parity mismatch
                        tuser = 1;
                    end
                end
                
                clks_counter = (clks_counter + 1) % Cycle_per_Period;
            end
            rx = 0;
    
        PARITY:
            // Parity check already performed
            
        STOP1:
            // Expect first stop bit
            if (rx & 1 && clks_counter == (Cycle_per_Period >> 1)) begin
                state = STOP2;
                clks_counter = 0;
                start_bit_counter = 0;
                initial_delay(Cycle_per_Period);
            end
        
        STOP2:
            // Expect second stop bit (if applicable)
            if (rst && STOP_BITS_NUM == 2 && rx & 1 && clks_counter == 0) begin
                state = OUT_RDY;
                clks_counter = 0;
            end
        
        OUT_RDY:
            // Validated data output
            tvalid = 1;
            
            // Generate AXI-Stream outputs
            tdata <= data_shift_reg;
            tuser <= 0;
        endcase
    endff
end

// Reset handler
always arstn: begin
    state = IDLE;
    clks_counter = 0;
    data_shift_reg = 0;
    tvalid = 0;
end

endmodule