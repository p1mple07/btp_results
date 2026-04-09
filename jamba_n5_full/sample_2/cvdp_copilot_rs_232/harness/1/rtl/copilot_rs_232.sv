module copilot_rs_232 (
    clock,
    reset_neg,
    tx_datain_ready,
    Present_Processing_Completed,
    tx_datain,
    tx_transmitter,
    tx_transmitter_valid
);

    // Configuration parameters
    parameter HIGH = 1'b1;
    parameter LOW = 1'b0;
    parameter CLOCK_FREQ = 100000000;   // 100 MHz
    parameter BAUD_RATE = 115200;        // Default baud rate
    parameter REG_INPUT = 1;
    parameter BAUD_ACC_WIDTH = 16;

    // Inputs
    input reset_neg;
    input clock;
    input tx_datain_ready;
    input Present_Processing_Completed;
    input [7:0] tx_datain;

    // Outputs
    output tx_transmitter;
    output tx_transmitter_valid;

    // Internal state machine registers
    reg tx_transmitter;
    wire baud_pulse;

    // Baud‑rate generator
    baud_rate_generator #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .BAUD_ACC_WIDTH(BAUD_ACC_WIDTH)
    ) baud_gen (
        .clock(clock),
        .reset_neg(reset_neg),
        .enable(tx_transmitter_valid),
        .baud_pulse(baud_pulse)
    );

    // State machine
    reg state;
    always @(posedge clock) begin
        state <= CASE {
            0 => 1,
            1 => 2,
            2 => 3,
            3 => 4,
            default => 0;
        };
    end

    // Start bit generation
    always @(state = 1) begin
        tx_transmitter <= LOW;
    end

    // Data bits
    always @(state = 2, 3, 4) begin
        if (state == 2) begin
            tx_transmitter <= TX_DATA_0;
        end else if (state == 3) begin
            tx_transmitter <= TX_DATA_1;
        end else if (state == 4) begin
            tx_transmitter <= TX_DATA_2;
        end
    end

    // Stop bit generation
    always @(state = 4) begin
        tx_transmitter <= TX_STOP_BIT;
    end

    // Final output
    always @(*) begin
        tx_transmitter_valid = tx_transmitter;
    end

endmodule

module baud_rate_generator #(
    parameter CLOCK_FREQ = 100000000,
    parameter BAUD_RATE = 115200,
    parameter BAUD_ACC_WIDTH = 16
)
(
    input clock,
    input reset_neg,
    input enable,
    output reg baud_pulse
);

    // Internal logic
    wire [BAUD_ACC_WIDTH:0] baud_inc;
    reg [BAUD_ACC_WIDTH:0] baud_acc;

    assign baud_inc = ((BAUD_RATE << (BAUD_ACC_WIDTH - 4)) + (CLOCK_FREQ >> 5)) / (CLOCK_FREQ >> 4);

    assign baud_pulse = (baud_acc >= (CLOCK_FREQ >> 4));

endmodule
