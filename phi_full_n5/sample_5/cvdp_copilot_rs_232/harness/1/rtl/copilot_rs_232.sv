// Transmitter State Machine
reg [3:0] State;

// Output Multiplexer
wire MuxBit;
wire [BAUD_ACC_WIDTH:0] baud_acc_muxed;

always @ (posedge clock or negedge reset_neg) begin
    if (reset_neg == LOW) begin
        State <= 4'b0000; // Idle State
        MuxBit <= LOW;
    end else if (tx_datain_ready) begin
        State <= (State + 1'b1) & 4'b1111; // Move to next state
    end else if (Present_Processing_Completed) begin
        State <= 4'b0000; // Return to Idle State
    end else begin
        MuxBit <= baud_acc_muxed[State]; // Select appropriate bit
        if (State == 4'b0000) begin
            tx_transmitter <= LOW; // Start bit
        end else if (State == 4'b0001 || State == 4'b0010 || State == 4'b0011) begin
            tx_transmitter <= tx_datain[State - 4'b0001]; // Data bits
        end else if (State == 4'b0111) begin
            tx_transmitter <= HIGH; // Stop bit
        end
    end
end

// Baud Rate Generator Output Muxing
always @ (posedge clock or negedge reset_neg) begin
    if (reset_neg == LOW) begin
        baud_acc_muxed <= 16'b0;
    end else begin
        baud_acc_muxed <= baud_acc;
    end
end

// Baud Rate Generator
always @ (posedge clock or negedge reset_neg) begin
    if (reset_neg == LOW) begin
        baud_acc <= 16'b0;
    end else begin
        if (enable) begin
            if (baud_inc[BAUD_ACC_WIDTH - 1]) begin
                baud_acc <= baud_acc + 1'b1;
            end else begin
                baud_acc <= 16'b0;
            end
        end
    end
end

// Output Multiplexer Logic
assign MuxBit = baud_acc_muxed[State];
