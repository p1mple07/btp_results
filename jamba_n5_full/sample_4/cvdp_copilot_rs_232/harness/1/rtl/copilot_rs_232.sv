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

    // Insert code here for Transmitter State Machine
    

    // Insert code here for the Output Multiplexer
  

    // Assemble Start, Data, and Stop Bits
    always @ (posedge clock or negedge reset_neg) begin
        if (reset_neg == LOW) begin
            tx_transmitter <= HIGH;
        end else if (Present_Processing_Completed == HIGH) begin
            tx_transmitter <= HIGH;
        end else begin
            tx_transmitter <= (State < 4) | (State[3] & MuxBit); // Glitch-free output
        end
    end

endmodule
