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
    always @(posedge clock or negedge reset_neg) begin
        case (State)
            Idle: begin
                if (tx_datain_ready)
                    State <= Start;
                tx_transmitter = 1'b1;
                baud_pulse <= 0;
            end
            Start: begin
                tx_transmitter = 1'b0;
                State <= Data;
            end
            Data: begin
                tx_transmitter = 1'b1;
                State <= Stop;
            end
            Stop: begin
                tx_transmitter = 1'b1;
                State <= Idle;
            end
        endcase
    end

    // Output multiplexer
    assign tx_transmitter = (State < 4) | (State[3] & MuxBit);
    assign tx_transmitter_valid = tx_transmitter;

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

    // Generate baud_pulse on rising edge of clock
    always @(posedge clock) begin
        if (reset_neg) begin
            baud_pulse = 0;
        end else
            baud_pulse = 1;
    end

endmodule
