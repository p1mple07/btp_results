module axis_to_uart_tx(
    parameter CLK_FREQ,
    parameter BIT_RATE,
    parameter BIT_PER_WORD,
    parameter PARITY_BIT,
    parameter STOP_BITS_NUM,
    input wire aclk,
    input wire aresetn,
    input wire tdata,
    input wire tvalid,
    input wire tready
);

    // State variables
    enum state States = StateRange(0, 5);
    reg wire [7:0] current_state = 0;
    
    // FSM states: IDLE(0), START(1), DATA(2), PARITY(3), STOP1(4), STOP2(5)
    // State encoding: 
    // 0 - IDLE 
    // 1 - START 
    // 2 - DATA 
    // 3 - PARITY 
    // 4 - STOP1 
    // 5 - STOP2 

    // FIFO buffer for data latching
    FIFO8bit FIFOBuff;

    // Shift register for data transmission
    shift_reg8bit DataReg;
    
    // Counters for bit timing
    reg Clk_Count;
    reg Bit_Count;

    // Parity calculation variables
    reg [7:0] data_bits = 0;
    reg parity_bit = 0;

    // Register for TX output
    reg [7:0] TX;

    // Parameters assignments
    parameter DEFAULT_BIT_COUNT = BIT_PER_WORD - 1;

    // Initialize FIFO buffer and other registers on reset
    initial begin
        FIFOBuff.init();
        DataReg = 0;
        Clk_Count = 0;
        Bit_Count = 0;
        parity_bit = 0;
        TX = 0;
        current_state = 0;
    end

    // Always block for clock counter and bit counting
    always_comb begin
        if (current_state == States.START || current_state == States.DATA ||
            current_state == States.PARITY || current_state == States.STOP1) 
            Clk_Count <= Clk_Count + 1;
    end

    // Always block for data latching and parity calculation
    always_ff (
        input valid = tvalid & tready,
        output valid = tready,
        next_state = current_state
    ) begin
        case(current_state)
            States.IDLE: 
                if (tvalid && tready) begin
                    current_state = States.START;
                    // Start bit
                    tx_start_bit();
                end
            States.START: 
                if (Clk_Count == Cycle_per_Period) begin
                    current_state = States.DATA;
                    Clk_Count = 0;
                end
            States.DATA: 
                if (Bit_Count == DEFAULT_BIT_COUNT) begin
                    current_state = (States.PARITY | (Parity_bit)) ? States.PARITY : States.STOP1;
                    Clk_Count = 0;
                end
            States.PARITY: 
                if (Bit_Count == DEFAULT_BIT_COUNT) begin
                    current_state = States.STOP1;
                    Clk_Count = 0;
                end
            States.STOP1: 
                if (Clk_Count == Cycle_per_Period) begin
                    current_state = (States.STOP2 | (Stop_bits_num >= 2)) ? States.STOP2 : States.IDLE;
                    Clk_Count = 0;
                end
            States.STOP2: 
                if (Clk_Count == Cycle_per_Period) begin
                    current_state = States.IDLE;
                    Clk_Count = 0;
                end
        endcase
    end

    // Start bit transmission
    always_comb tx_start_bit() begin
        tx_start_bit = 1;
        TX = 1;
        tready = 1;
        current_state = States.START;
    end

    // Data bit transmission
    always_comb data_bit() begin
        data_bits ^= DataReg;
        TX = data_bits;
        current_state = States.DATA;
    end

    // Parity bit calculation
    always_comb parity_bit_calc() begin
        parity_bit = parity_bit ^ data_bits;
        if (Parity_bit == 1) parity_bit = !parity_bit;
        parity_bit = parity_bit;
    end

    // Stop bit transmission
    always_comb tx_stop_bit() begin
        TX = 1;
        tready = 1;
        current_state = States.STOP1;
    end

    // Module initialization
    initial begin
        $display("Axis_to_UART_TransmitterInitialized");
        // Wait for first valid start bit
        #10ns;
        $display("Ready for data transmission");
    end

endmodule