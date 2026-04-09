// Transmitter State Machine
reg [3:0] State;

always @ (posedge clock or negedge reset_neg) begin
    if (reset_neg == LOW) begin
        State <= 4'b0000; // Idle State
    end else if (tx_datain_ready) begin
        State <= State + 1; // Transition to next state
    end
end

// Output Multiplexer
wire start_bit, data_bit, stop_bit;

always @ (posedge clock) begin
    case (State)
        4'b0000: start_bit <= LOW;
        4'b0001: data_bit <= tx_datain[0];
        4'b0010: data_bit <= tx_datain[1];
        4'b0011: data_bit <= tx_datain[2];
        4'b0100: data_bit <= tx_datain[3];
        4'b0101: data_bit <= tx_datain[4];
        4'b0110: data_bit <= tx_datain[5];
        4'b0111: data_bit <= tx_datain[6];
        4'b1000: stop_bit <= HIGH;
        default: start_bit <= LOW; data_bit <= LOW; stop_bit <= LOW;
    endcase
end

// Assemble Start, Data, and Stop Bits
assign tx_transmitter = (State < 4) | (State[3] & MuxBit);
assign MuxBit = start_bit | data_bit | stop_bit;
