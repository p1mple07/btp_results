// Transmitter State Machine
reg [3:0] State;

// State Transition Logic
always @ (posedge clock or negedge reset_neg) begin
    if (reset_neg == LOW) begin
        State <= 4'b0000; // Idle State
    end else if (tx_datain_ready) begin
        State <= State + 4'b0001; // Start State
    end else if (State < 4'b1111) begin
        State <= State + 4'b0001; // Data States
    end else begin
        State <= 4'b0000; // Stop State
    end
end

// Data Bit Transmission
always @ (posedge clock or negedge reset_neg) begin
    if (reset_neg == LOW) begin
        tx_transmitter <= HIGH; // Prepare for start bit
    end else if (State == 4'b0001) begin
        tx_transmitter <= LOW; // Start bit
        State <= State + 4'b0002; // Next state
    end else if (State == 4'b0002 && tx_datain[0]) begin
        tx_transmitter <= tx_datain[0]; // Data Bit 0
        State <= State + 4'b0003; // Next state
    end else if (State == 4'b0003 && tx_datain[1]) begin
        tx_transmitter <= tx_datain[1]; // Data Bit 1
        State <= State + 4'b0004; // Next state
    end else if (State == 4'b0004 && tx_datain[2]) begin
        tx_transmitter <= tx_datain[2]; // Data Bit 2
        State <= State + 4'b0005; // Next state
    end else if (State == 4'b0005 && tx_datain[3]) begin
        tx_transmitter <= tx_datain[3]; // Data Bit 3
        State <= State + 4'b0006; // Next state
    end else if (State == 4'b0006) begin
        tx_transmitter <= LOW; // Stop bit
        State <= 4'b0000; // Reset to Idle State
    end
end

// Output Multiplexer
assign tx_transmitter_valid = tx_transmitter & enable;

// Glitch-free signal assignment
assign MuxBit = baud_pulse & tx_transmitter_valid;
