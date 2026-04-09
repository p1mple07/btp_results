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

    // Transmitter State Machine
    localparam STATE_IDLE = 1'b0;
    localparam STATE_START = 1'b1;
    localparam STATE_DATA = 1'b2;
    localparam STATE_STOP = 1'b3;

    reg [3:0] state;

    always @(posedge clock or negedge reset_neg) begin
        if (reset_neg == LOW) begin
            state <= STATE_IDLE;
        end else if (Present_Processing_Completed == HIGH) begin
            state <= STATE_IDLE;
        end else begin
            case (state)
                1'b0: begin
                    state <= STATE_START;
                end
                1'b1: begin
                    state <= STATE_DATA;
                end
                1'b2: begin
                    state <= STATE_STOP;
                end
                1'b3: begin
                    // After stop, go to idle
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

    // Assemble the output signals
    always @(state) begin
        case (state)
            1'b0: begin
                // Idle: wait for tx_datain_ready
                // Do nothing
            end
            1'b1: begin
                // Start: send start bit
                tx_transmitter <= LOW;
            end
            1'b2: begin
                // Data bit 0
                tx_transmitter <= '0;
                // Shift out data
            end
            1'b3: begin
                // Stop: send stop bit (high)
                tx_transmitter <= HIGH;
            end
        endcase
    end

endmodule

