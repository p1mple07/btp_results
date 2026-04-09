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

    // Transmitter state machine
    reg state;
    always @(*) begin
        case (state)
            0: // Idle
                if (tx_datain_ready) begin
                    state <= 1;
                end else begin
                    state <= 0;
                end
            end
            1: // Start
                tx_transmitter <= LOW;
                state <= 2;
            end
            2: // Data
                for (int i = 0; i < 8; i++) begin
                    tx_transmitter <= {DATA_BITS[i]};
                end
                state <= 3;
            end
            3: // Stop
                tx_transmitter <= HIGH;
                state <= 0;
            end
        endcase
    end

endmodule

// Baud Rate Generator Module
module baud_rate_generator #(
    parameter CLOCK_FREQ = 100000000, // 100MHz
    parameter BAUD_RATE = 115200, // Default baud rate
    parameter BAUD_ACC_WIDTH = 16
) (
    input clock,
    input reset_neg,
    input enable,
    output reg baud_pulse
);

    // Internal signals
    wire [BAUD_ACC_WIDTH:0] baud_inc;
    reg [BAUD_ACC_WIDTH:0] baud_acc;

    assign baud_inc = ((BAUD_RATE << (BAUD_ACC_WIDTH - 4)) + (CLOCK_FREQ >> 5)) / (CLOCK_FREQ >> 4);

    assign baud_pulse = (baud_acc == baud_inc);

endmodule
