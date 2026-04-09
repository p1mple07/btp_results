module copilot_rs_232 (
    input  clock,
    input  reset_neg,
    input  tx_datain_ready,
    input  Present_Processing_Completed,
    input  [7:0] tx_datain,
    output tx_transmitter,
    output tx_transmitter_valid
);
    // Parameters
    parameter HIGH          = 1'b1;
    parameter LOW           = 1'b0;
    parameter CLOCK_FREQ     = 100000000; // 100MHz
    parameter BAUD_RATE      = 115200;    // Default baud rate
    parameter REG_INPUT      = 1;
    parameter BAUD_ACC_WIDTH = 16;

    // Internal signals
    reg tx_transmitter;
    wire baud_pulse;
    reg  [3:0] state;       // State machine state register
    reg  [2:0] bit_index;   // Bit index for data bits (0 to 7)
    reg  [7:0] data_reg;    // Registered data input

    // Instantiate the Baud Rate Generator
    baud_rate_generator #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .BAUD_ACC_WIDTH(BAUD_ACC_WIDTH)
    ) baud_gen (
        .clock      (clock),
        .reset_neg  (reset_neg),
        .enable     (tx_transmitter_valid),
        .baud_pulse (baud_pulse)
    );

    // ---------------------------------------------------------------------
    // Transmitter State Machine
    // State encoding:
    //   0 : Idle (waiting for tx_datain_ready)
    //   1 : Start bit (transmit 0)
    //   2 to 9 : Data bits (bit 0 to 7 from data_reg)
    //   10 : Stop bit (transmit 1)
    // ---------------------------------------------------------------------
    always @(posedge clock or negedge reset_neg) begin
        if (!reset_neg) begin
            state      <= 0;       // Idle state
            bit_index  <= 0;
            data_reg   <= 8'b0;
        end else if (Present_Processing_Completed) begin
            // Pause transmission: hold current state and data
            state      <= state;
            bit_index  <= bit_index;
            data_reg   <= data_reg;
        end else if (baud_pulse) begin
            case (state)
                0: begin
                    // Idle: Wait for new data to be ready.
                    if (tx_datain_ready) begin
                        data_reg <= tx_datain; // Latch data (if REG_INPUT is 1, this happens on tx_datain_ready)
                        state    <= 1;         // Move to Start state
                        bit_index<= 0;
                    end
                end
                1: begin
                    // Start bit already transmitted; move to data bit transmission.
                    state    <= 2;
                    bit_index<= 0;
                end
                2: begin
                    // Transmit data bit 0.
                    state    <= 3;
                    bit_index<= bit_index + 1;
                end
                3: begin
                    // Transmit data bit 1.
                    state    <= 4;
                    bit_index<= bit_index + 1;
                end
                4: begin
                    // Transmit data bit 2.
                    state    <= 5;
                    bit_index<= bit_index + 1;
                end
                5: begin
                    // Transmit data bit 3.
                    state    <= 6;
                    bit_index<= bit_index + 1;
                end
                6: begin
                    // Transmit data bit 4.
                    state    <= 7;
                    bit_index<= bit_index + 1;
                end
                7: begin
                    // Transmit data bit 5.
                    state    <= 8;
                    bit_index<= bit_index + 1;
                end
                8: begin
                    // Transmit data bit 6.
                    state    <= 9;
                    bit_index<= bit_index + 1;
                end
                9: begin
                    // Transmit data bit 7.
                    state    <= 10;
                    bit_index<= bit_index + 1;
                end
                10: begin
                    // Stop bit transmitted; return to Idle.
                    state    <= 0;
                    bit_index<= 0;
                end
                default: state <= 0;
            endcase
        end
    end

    // ---------------------------------------------------------------------
    // Output Multiplexer: Assemble Start, Data, and Stop Bits
    // The transmitter output (tx_transmitter) is driven as follows:
    //   Idle (state 0): HIGH (idle/stop level)
    //   Start (state 1): LOW (start bit)
    //   Data bits (states 2 to 9): data_reg[bit_index]
    //   Stop (state 10): HIGH (stop bit)
    // ---------------------------------------------------------------------
    always @(posedge clock or negedge reset_neg) begin
        if (!reset_neg) begin
            tx_transmitter <= HIGH;
        end else if (Present_Processing_Completed) begin
            tx_transmitter <= HIGH;
        end else begin
            case (state)
                0: tx_transmitter <= HIGH;    // Idle: Stop bit level
                1: tx_transmitter <= LOW;     // Start bit
                2: tx_transmitter <= data_reg[0]; // Data bit 0
                3: tx_transmitter <= data_reg[1]; // Data bit 1
                4: tx_transmitter <= data_reg[2]; // Data bit 2
                5: tx_transmitter <= data_reg[3]; // Data bit 3
                6: tx_transmitter <= data_reg[4]; // Data bit 4
                7: tx_transmitter <= data_reg[5]; // Data bit 5
                8: tx_transmitter <= data_reg[6]; // Data bit 6
                9: tx_transmitter <= data_reg[7]; // Data bit 7
                10: tx_transmitter <= HIGH;      // Stop bit
                default: tx_transmitter <= HIGH;
            endcase
        end
    end

    // tx_transmitter_valid: Asserted when transmitter is busy (state != Idle)
    assign tx_transmitter_valid = (state != 0);

endmodule

// ---------------------------------------------------------------------
// Baud Rate Generator Module
// This module generates a periodic baud pulse based on the system clock,
// desired baud rate, and accumulator width.
// ---------------------------------------------------------------------
module baud_rate_generator #(
    parameter CLOCK_FREQ     = 100000000, // 100MHz
    parameter BAUD_RATE      = 115200,    // Default baud rate
    parameter BAUD_ACC_WIDTH = 16
)
(
    input  clock,
    input  reset_neg,
    input  enable,
    output reg baud_pulse
);

    // Internal signals
    wire [BAUD_ACC_WIDTH:0] baud_inc;
    reg  [BAUD_ACC_WIDTH:0] baud_acc;

    // Calculate the baud increment value.
    // This computes the approximate number of clock cycles per baud period.
    assign baud_inc = (CLOCK_FREQ / BAUD_RATE) + 1;  // +1 for rounding

    // Baud rate generation logic
    always @(posedge clock or negedge reset_neg) begin
        if (!reset_neg) begin
            baud_acc   <= 0;
            baud_pulse <= 0;
        end else begin
            if (enable) begin
                baud_acc <= baud_acc + 1;
                if (baud_acc >= baud_inc - 1) begin
                    baud_acc   <= 0;
                    baud_pulse <= 1;
                end else begin
                    baud_pulse <= 0;
                end
            end else begin
                baud_acc   <= 0;
                baud_pulse <= 0;
            end
        end
    end

endmodule