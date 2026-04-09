// Transmitter State Machine
reg [3:0] State, NextState;
wire MuxBit;

// State Transition Logic
always @ (posedge clock or negedge reset_neg) begin
    if (reset_neg == LOW) begin
        State <= 4'b0000; // Idle State
    end else if (tx_datain_ready) begin
        State <= State + 4'b0001; // Start State
    end else if (tx_transmitter_valid) begin
        NextState = State;
        if (State == 4'b0001) begin
            MuxBit = baud_pulse; // Data Bit 0
        end else if (State == 4'b0010) begin
            MuxBit = baud_pulse; // Data Bit 1
        end else if (State == 4'b0011) begin
            MuxBit = baud_pulse; // Data Bit 2
        end else if (State == 4'b0100) begin
            MuxBit = baud_pulse; // Data Bit 3
        end else if (State == 4'b0101) begin
            MuxBit = baud_pulse; // Data Bit 4
        end else if (State == 4'b0110) begin
            MuxBit = baud_pulse; // Data Bit 5
        end else if (State == 4'b0111) begin
            MuxBit = baud_pulse; // Data Bit 6
        end else if (State == 4'b1000) begin
            MuxBit = baud_pulse; // Data Bit 7
        end else if (State == 4'b1001) begin
            MuxBit = baud_pulse; // Stop Bit
        end
    end
end

// Output Multiplexer
always @ (posedge clock) begin
    case (State)
        4'b0000: tx_transmitter <= LOW;
        4'b0001: tx_transmitter <= baud_pulse;
        4'b0010: tx_transmitter <= baud_pulse;
        4'b0011: tx_transmitter <= baud_pulse;
        4'b0100: tx_transmitter <= baud_pulse;
        4'b0101: tx_transmitter <= baud_pulse;
        4'b0110: tx_transmitter <= baud_pulse;
        4'b0111: tx_transmitter <= baud_pulse;
        4'b1000: tx_transmitter <= baud_pulse;
        4'b1001: tx_transmitter <= HIGH;
        default: tx_transmitter <= LOW;
    endcase
end
