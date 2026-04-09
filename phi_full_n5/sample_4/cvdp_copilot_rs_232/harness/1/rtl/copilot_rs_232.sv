// Copilot RS232 Transmitter Module
module copilot_rs_232 (
    input clock,
    input reset_neg,
    input tx_datain_ready,
    input Present_Processing_Completed,
    input [7:0] tx_datain,
    output reg tx_transmitter,
    output tx_transmitter_valid
);

    // Parameters
    parameter HIGH = 1'b1;
    parameter LOW = 1'b0;
    parameter CLOCK_FREQ = 100000000; // 100MHz
    parameter BAUD_RATE = 115200;     // Default baud rate
    parameter REG_INPUT = 1;
    parameter BAUD_ACC_WIDTH = 16;

    // Baud Rate Generator
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

    // Transmitter State Machine
    reg [3:0] State;
    reg MuxBit;

    // Transmitter Output
    assign tx_transmitter = (State == 4'b00) | (State[3] & MuxBit);

    // Output Multiplexer
    always @ (posedge clock or negedge reset_neg) begin
        if (reset_neg == LOW) begin
            State <= 4'b00;
            MuxBit <= LOW;
        end else if (tx_datain_ready) begin
            State <= State + 1;
        end else if (Present_Processing_Completed) begin
            State <= 4'b00;
        end else if (tx_transmitter_valid) begin
            State <= (State + 1) % 4;
            MuxBit <= State[3];
        end
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
    always @ (posedge clock or negedge reset_neg) begin
        if (!reset_neg) begin
            baud_acc <= 0;
        end else begin
            baud_acc <= (baud_acc + baud_inc) & ((1 << BAUD_ACC_WIDTH) - 1);
        end
    end

    // Generate baud pulse
    always @ (posedge clock) begin
        if (enable && baud_acc == (BAUD_RATE - 1)) begin
            baud_pulse <= HIGH;
        end else begin
            baud_pulse <= LOW;
        end
    end

endmodule
