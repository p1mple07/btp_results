module copilot_rs_232 (
    input  clock,
    input  reset_neg,
    input  tx_datain_ready,
    input  Present_Processing_Completed,
    input  [7:0] tx_datain,
    output tx_transmitter,
    output tx_transmitter_valid
);
    // Parameters
    parameter HIGH = 1'b1;
    parameter LOW  = 1'b0;
    parameter CLOCK_FREQ = 100000000; // 100MHz
    parameter BAUD_RATE = 115200;     // Default baud rate
    parameter REG_INPUT = 1;
    parameter BAUD_ACC_WIDTH = 16;

    // State encoding
    localparam IDLE    = 4'd0;
    localparam START   = 4'd1;
    localparam DATA_0  = 4'd2;
    localparam DATA_1  = 4'd3;
    localparam DATA_2  = 4'd4;
    localparam DATA_3  = 4'd5;
    localparam DATA_4  = 4'd6;
    localparam DATA_5  = 4'd7;
    localparam DATA_6  = 4'd8;
    localparam DATA_7  = 4'd9;
    localparam STOP    = 4'd10;

    // Inputs
    input  reset_neg;
    input  clock;
    input  tx_datain_ready;
    input  Present_Processing_Completed;
    input  [7:0] tx_datain;

    // Outputs
    output tx_transmitter;
    output tx_transmitter_valid;

    // Internal signals
    reg [3:0] state;
    reg [7:0] data_reg;
    wire     tx_transmitter_valid;
    wire     baud_pulse;
    wire [7:0] data_sel;

    // Drive tx_transmitter_valid based on state (busy when not idle)
    assign tx_transmitter_valid = (state != IDLE);

    // Data selection: if REG_INPUT is enabled, use registered data; otherwise, use input directly.
    assign data_sel = (REG_INPUT ? data_reg : tx_datain);

    // Instantiate the Baud Rate Generator
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

    //--------------------------------------------------------------------------
    // Transmitter State Machine
    //--------------------------------------------------------------------------
    // This state machine drives the transmission process. It waits in IDLE until
    // new data is ready, then loads the data (if REG_INPUT is enabled), sends a start
    // bit, transmits 8 data bits, and finally sends a stop bit.
    //--------------------------------------------------------------------------
    always @(posedge clock or negedge reset_neg) begin
        if (!reset_neg) begin
            state <= IDLE;
        end
        else if (Present_Processing_Completed) begin
            state <= IDLE;
        end
        else if (baud_pulse) begin
            case (state)
                IDLE: begin
                    if (tx_datain_ready) begin
                        if (REG_INPUT)
                            data_reg <= tx_datain;
                        state <= START;
                    end
                    else
                        state <= IDLE;
                end
                START: begin
                    state <= DATA_0;
                end
                DATA_0: begin
                    state <= DATA_1;
                end
                DATA_1: begin
                    state <= DATA_2;
                end
                DATA_2: begin
                    state <= DATA_3;
                end
                DATA_3: begin
                    state <= DATA_4;
                end
                DATA_4: begin
                    state <= DATA_5;
                end
                DATA_5: begin
                    state <= DATA_6;
                end
                DATA_6: begin
                    state <= DATA_7;
                end
                DATA_7: begin
                    state <= STOP;
                end
                STOP: begin
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // Output Multiplexer for UART Transmission
    //--------------------------------------------------------------------------
    // Assemble the serial data stream: idle (HIGH), start (LOW), 8 data bits,
    // and stop (HIGH). The appropriate bit is selected based on the current state.
    //--------------------------------------------------------------------------
    always @(posedge clock or negedge reset_neg) begin
        if (!reset_neg) begin
            tx_transmitter <= HIGH;
        end
        else if (Present_Processing_Completed) begin
            tx_transmitter <= HIGH;
        end
        else begin
            case (state)
                IDLE:    tx_transmitter <= HIGH;
                START:   tx_transmitter <= LOW;
                DATA_0:  tx_transmitter <= data_sel[0];
                DATA_1:  tx_transmitter <= data_sel[1];
                DATA_2:  tx_transmitter <= data_sel[2];
                DATA_3:  tx_transmitter <= data_sel[3];
                DATA_4:  tx_transmitter <= data_sel[4];
                DATA_5:  tx_transmitter <= data_sel[5];
                DATA_6:  tx_transmitter <= data_sel[6];
                DATA_7:  tx_transmitter <= data_sel[7];
                STOP:    tx_transmitter <= HIGH;
                default: tx_transmitter <= HIGH;
            endcase
        end
    end

endmodule

//------------------------------------------------------------------------------
// Baud Rate Generator Module
//------------------------------------------------------------------------------
// This module generates a pulse (baud_pulse) at intervals determined by the 
// CLOCK_FREQ and BAUD_RATE parameters. It uses an accumulator (baud_acc) and 
// compares it to a calculated threshold (baud_inc) to produce a pulse.
//------------------------------------------------------------------------------
module baud_rate_generator #(
    parameter CLOCK_FREQ = 100000000, // 100MHz
    parameter BAUD_RATE = 115200,     // Default baud rate
    parameter BAUD_ACC_WIDTH = 16
)
 (
    input  clock,
    input  reset_neg,
    input  enable,
    output reg baud_pulse
);

    // Internal signals
    wire [BAUD_ACC_WIDTH:0] baud_inc;
    reg  [BAUD_ACC_WIDTH:0] baud_acc;

    // Calculate the baud increment value.
    // This formula scales the BAUD_RATE to the accumulator width.
    assign baud_inc = ((BAUD_RATE << (BAUD_ACC_WIDTH - 4)) + (CLOCK_FREQ >> 5)) / (CLOCK_FREQ >> 4);

    // Baud rate generator always block
    always @(posedge clock or negedge reset_neg) begin
        if (!reset_neg) begin
            baud_acc   <= 0;
            baud_pulse <= 0;
        end
        else if (enable) begin
            if (baud_acc >= baud_inc - 1) begin
                baud_acc   <= 0;
                baud_pulse <= 1;
            end
            else begin
                baud_acc   <= baud_acc + 1;
                baud_pulse <= 0;
            end
        end
        else begin
            baud_acc   <= 0;
            baud_pulse <= 0;
        end
    end

endmodule