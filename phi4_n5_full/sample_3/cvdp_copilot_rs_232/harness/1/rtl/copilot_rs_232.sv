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
    parameter LOW  = 1'b0;
    parameter CLOCK_FREQ = 100000000; // 100MHz
    parameter BAUD_RATE    = 115200;     // Default baud rate
    parameter REG_INPUT    = 1;
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
    reg [3:0] State;
    reg [7:0] data_reg;

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

    //--------------------------------------------------------------------------
    // Transmitter State Machine
    //
    // The state machine has 11 states:
    //  0000: IDLE          - Waiting for new data.
    //  0001: START         - Transmit start bit (LOW).
    //  0010: DATA0         - Transmit bit 0.
    //  0011: DATA1         - Transmit bit 1.
    //  0100: DATA2         - Transmit bit 2.
    //  0101: DATA3         - Transmit bit 3.
    //  0110: DATA4         - Transmit bit 4.
    //  0111: DATA5         - Transmit bit 5.
    //  1000: DATA6         - Transmit bit 6.
    //  1001: DATA7         - Transmit bit 7.
    //  1010: STOP          - Transmit stop bit (HIGH).
    //--------------------------------------------------------------------------

    always @(posedge clock or negedge reset_neg) begin
        if (!reset_neg) begin
            State      <= 4'b0000; // IDLE
            data_reg   <= 8'b0;
        end 
        else if (Present_Processing_Completed) begin
            // When processing is complete, return to IDLE.
            State <= 4'b0000;
        end 
        else if (baud_pulse) begin
            case (State)
                4'b0000: begin
                    // IDLE: Wait for new data.
                    if (tx_datain_ready) begin
                        data_reg <= tx_datain; // Load new data.
                        State    <= 4'b0001;    // Transition to START state.
                    end
                end
                4'b0001: begin
                    // START state: Transmit start bit (LOW).
                    State <= 4'b0010; // Move to DATA0 state.
                end
                4'b0010: begin
                    // DATA0 state: Transmit bit 0.
                    State <= 4'b0011;
                end
                4'b0011: begin
                    // DATA1 state: Transmit bit 1.
                    State <= 4'b0100;
                end
                4'b0100: begin
                    // DATA2 state: Transmit bit 2.
                    State <= 4'b0101;
                end
                4'b0101: begin
                    // DATA3 state: Transmit bit 3.
                    State <= 4'b0110;
                end
                4'b0110: begin
                    // DATA4 state: Transmit bit 4.
                    State <= 4'b0111;
                end
                4'b0111: begin
                    // DATA5 state: Transmit bit 5.
                    State <= 4'b1000;
                end
                4'b1000: begin
                    // DATA6 state: Transmit bit 6.
                    State <= 4'b1001;
                end
                4'b1001: begin
                    // DATA7 state: Transmit bit 7.
                    State <= 4'b1010; // Transition to STOP state.
                end
                4'b1010: begin
                    // STOP state: Transmit stop bit (HIGH).
                    State <= 4'b0000; // Return to IDLE.
                end
                default: State <= 4'b0000;
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // Output Multiplexer for tx_transmitter
    //
    // Depending on the current state, the transmitter output is assigned as:
    //   IDLE and STOP: HIGH
    //   START: LOW
    //   DATA states: the corresponding bit from data_reg.
    //--------------------------------------------------------------------------
    always @(*) begin
        case (State)
            4'b0000, 4'b1010: tx_transmitter = HIGH; // IDLE and STOP: High
            4'b0001:           tx_transmitter = LOW;  // START: Low
            4'b0010:           tx_transmitter = data_reg[0];
            4'b0011:           tx_transmitter = data_reg[1];
            4'b0100:           tx_transmitter = data_reg[2];
            4'b0101:           tx_transmitter = data_reg[3];
            4'b0110:           tx_transmitter = data_reg[4];
            4'b0111:           tx_transmitter = data_reg[5];
            4'b1000:           tx_transmitter = data_reg[6];
            4'b1001:           tx_transmitter = data_reg[7];
            default:           tx_transmitter = HIGH;
        endcase
    end

    // Drive the transmitter valid signal.
    // It is asserted whenever the state machine is not in IDLE.
    assign tx_transmitter_valid = (State != 4'b0000);

endmodule

//--------------------------------------------------------------------------
// Baud Rate Generator Module
//
// This submodule generates a baud pulse synchronized with the desired
// baud rate. The accumulator is scaled by BAUD_ACC_WIDTH bits to allow
// fine resolution.
//--------------------------------------------------------------------------
module baud_rate_generator #(
    parameter CLOCK_FREQ   = 100000000, // 100MHz
    parameter BAUD_RATE    = 115200,     // Default baud rate
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
    reg  [BAUD_ACC_WIDTH:0] baud_acc;

    // Calculate the baud increment value.
    // This expression scales the divider to the desired accumulator width.
    assign baud_inc = ((BAUD_RATE << (BAUD_ACC_WIDTH - 4)) + (CLOCK_FREQ >> 5)) / (CLOCK_FREQ >> 4);

    always @(posedge clock or negedge reset_neg) begin
        if (!reset_neg) begin
            baud_acc   <= {BAUD_ACC_WIDTH+1{1'b0}};
            baud_pulse <= 1'b0;
        end 
        else if (enable) begin
            baud_acc <= baud_acc + baud_inc;
            if (baud_acc >= baud_inc - 1) begin
                baud_acc   <= {BAUD_ACC_WIDTH+1{1'b0}};
                baud_pulse <= 1'b1;
            end 
            else begin
                baud_pulse <= 1'b0;
            end
        end 
        else begin
            baud_acc   <= {BAUD_ACC_WIDTH+1{1'b0}};
            baud_pulse <= 1'b0;
        end
    end

endmodule