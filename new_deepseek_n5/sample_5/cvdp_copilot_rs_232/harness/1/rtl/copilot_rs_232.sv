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
    reg [4:0] state; // 4-bit state machine
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

    // Instantiate the Output Multiplexer
    always @ (posedge clock or negedge reset_neg) begin
        if (reset_neg == LOW) begin
            tx_transmitter <= HIGH;
            state <= 0;
        end else if (Present_Processing_Completed == HIGH) begin
            tx_transmitter <= HIGH;
            state <= 0;
        end else begin
            case (state)
                0: tx_transmitter <= HIGH;
                1: tx_transmitter <= tx_datain[0];
                2: tx_transmitter <= tx_datain[1];
                3: tx_transmitter <= tx_datain[2];
                4: tx_transmitter <= tx_datain[3];
                5: tx_transmitter <= tx_datain[4];
                6: tx_transmitter <= tx_datain[5];
                7: tx_transmitter <= tx_datain[6];
                8: tx_transmitter <= tx_datain[7];
                9: tx_transmitter <= LOW;
                default: tx_transmitter <= HIGH;
            endcase
            state <= (state + 1) % 10;
        end
    end

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
    wire [BAUD_ACC_WIDTH:0] baud_acc;
    reg [BAUD_ACC_WIDTH:0] baud_inc;

    // Calculate the baud increment value
    assign baud_inc = ((BAUD_RATE << (BAUD_ACC_WIDTH - 4)) + (CLOCK_FREQ >> 5)) / (CLOCK_FREQ >> 4);

    // Baud rate increment and accumulation
    always @ (posedge clock) begin
        if (enable) begin
            baud_acc = (baud_acc + baud_inc) % (1 << BAUD_ACC_WIDTH);
            if (baud_acc >= (1 << BAUD_ACC_WIDTH)) begin
                baud_pulse = 1;
                baud_acc = 0;
            end else begin
                baud_pulse = 0;
            end
        end else begin
            baud_acc = 0;
            baud_pulse = 0;
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
    wire [BAUD_ACC_WIDTH:0] baud_acc;
    reg [BAUD_ACC_WIDTH:0] baud_inc;

    // Calculate the baud increment value
    assign baud_inc = ((BAUD_RATE << (BAUD_ACC_WIDTH - 4)) + (CLOCK_FREQ >> 5)) / (CLOCK_FREQ >> 4);

    // Baud rate increment and accumulation
    always @ (posedge clock) begin
        if (enable) begin
            baud_acc = (baud_acc + baud_inc) % (1 << BAUD_ACC_WIDTH);
            if (baud_acc >= (1 << BAUD_ACC_WIDTH)) begin
                baud_pulse = 1;
                baud_acc = 0;
            end else begin
                baud_pulse = 0;
            end
        end else begin
            baud_acc = 0;
            baud_pulse = 0;
        end
    end
endmodule