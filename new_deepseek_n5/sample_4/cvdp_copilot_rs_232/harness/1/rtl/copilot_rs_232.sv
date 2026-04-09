module copilot_rs_232 (
    clock,
    reset_neg,
    tx_datain_ready,
    Present_Processing_Completed,
    tx_datain,
    tx_transmitter,
    tx_transmitter_valid
);
    // Parameters
    parameter HIGH = 1'b1;
    parameter LOW = 1'b0;
    parameter CLOCK_FREQ = 100000000; // 100MHz
    parameter BAUD_RATE = 115200;     // Default baud rate
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

    // Internal signals
    reg tx_transmitter;
    reg [3:0] state; // State: 0=Idle, 1=Start, 2=Data, 3=Stop
    wire baud_pulse;

    // Instantiate the Baud Rate Generator
    baud_rate_generator #(
        .BAUD_ACC_WIDTH(BAUD_ACC_WIDTH),
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen (
        .clock(clock),
        .reset_neg(reset_neg),
        .enable(tx_transmitter_valid),
        .baud_pulse(baud_pulse)
    );

    // State Machine
    always @ (posedge clock or posedge reset_neg) begin
        if (reset_neg == LOW) begin
            state <= 0; // Idle state
        else if (Present_Processing_Completed == HIGH) begin
            state <= 0; // Reset if processing completed
        else if (tx_datain_ready == HIGH) begin
            state <= 1; // Start transmission
        end else if (state == 1) begin
            state <= (state + 1); // Transmit data bits
        end else if (state == 8) begin
            state <= 3; // Stop transmission
        end
    end

    // Output Multiplexer
    always begin
        tx_transmitter_valid <= state; // Output valid when in transmitting state
    end

endmodule

// Baud Rate Generator Module
module baud_rate_generator #(
    parameter CLOCK_FREQ = 100000000, // 100MHz
    parameter BAUD_RATE = 115200, // Default baud rate
    parameter BAUD_ACC_WIDTH = 16
)
 (
    input clock,
    input reset_neg,
    input enable,
    output reg baud_pulse
);

    // Internal signals
    wire [BAUD_ACC_WIDTH:0] baud_inc;
    reg [BAUD_ACC_WIDTH:0] baud_acc;

    // Calculate the baud increment value
    assign baud_inc = ((BAUD_RATE << (BAUD_ACC_WIDTH - 4)) + (CLOCK_FREQ >> 5)) / (CLOCK_FREQ >> 4);

    // Baud rate generator logic
    always @ (posedge clock) begin
        if (enable) begin
            baud_acc <= (baud_acc + baud_inc) & ((1 << BAUD_ACC_WIDTH) - 1);
            if (baud_acc == 0) begin
                baud_pulse <= HIGH;
            end else begin
                baud_pulse <= LOW;
            end
        end else begin
            baud_pulse <= LOW;
        end
    end
endmodule