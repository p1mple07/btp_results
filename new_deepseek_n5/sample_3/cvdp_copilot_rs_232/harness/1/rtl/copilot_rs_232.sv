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
    reg [4:0] state;
    reg [7:0] current_bit;
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

    // State Machine Implementation
    always @ (posedge clock or negedge reset_neg) begin
        if (reset_neg == LOW) begin
            state = Idle;
            current_bit = -1;
        elsif (Present_Processing_Completed == HIGH) begin
            state = Idle;
            current_bit = -1;
        else if (tx_datain_ready == HIGH && current_bit == -1) begin
            state = Start;
            current_bit = 0;
        else if (state == Start) begin
            tx_transmitter <= LOW;
            state = Data;
            current_bit = 0;
        else if (current_bit < 7) begin
            current_bit = current_bit + 1;
            tx_transmitter <= (current_bit == 0) ? HIGH : LOW;
            state = Data;
        else if (state == Data) begin
            tx_transmitter <= HIGH;
            state = Stop;
            current_bit = -1;
        else if (state == Stop) begin
            tx_transmitter <= HIGH;
            state = Idle;
            current_bit = -1;
        end
    end

    // Output Multiplexer Implementation
    always @ (posedge clock or negedge reset_neg) begin
        if (reset_neg == LOW) begin
            tx_transmitter_valid = HIGH;
        elsif (Present_Processing_Completed == HIGH) begin
            tx_transmitter_valid = HIGH;
        else begin
            tx_transmitter_valid = (state < 4) ? (current_bit >= 0) : LOW;
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
    always @ (posedge clock) begin
        if (enable) begin
            baud_acc = (baud_acc + baud_inc) & (1 << BAUD_ACC_WIDTH);
            if (baud_acc >= (1 << BAUD_ACC_WIDTH)) begin
                baud_pulse = 1;
                baud_acc = 0;
            end else begin
                baud_pulse = 0;
            end
        end else begin
            baud_pulse = 0;
        end
    end
endmodule