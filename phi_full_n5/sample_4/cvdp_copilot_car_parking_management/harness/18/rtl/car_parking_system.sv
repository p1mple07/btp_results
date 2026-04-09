// Inside the car_parking_system module, after the existing code

// Define maximum daily fee
parameter MAX_DAILY_FEE = 1000; // Example value, adjust as needed

// Declare dynamic parking fee register
reg [15:0] dynamic_parking_fee;

// Declare input signal for the hour of the day
input [3:0] hour_of_day;

// Declare fee calculation logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        dynamic_parking_fee <= 0;
    end else begin
        // Calculate fee based on peak hours (8 AM to 6 PM)
        // For simplicity, assume fee_per_hour is a constant defined elsewhere
        case (hour_of_day)
            8'h10: begin // 8 AM
                dynamic_parking_fee <= calculate_fee(time_spent, fee_per_hour * 2); // Double fee during peak hours
            end
            8'h16: begin // 6 PM
                dynamic_parking_fee <= calculate_fee(time_spent, fee_per_hour); // Normal fee after peak hours
            end
            default: begin
                dynamic_parking_fee <= calculate_fee(time_spent, fee_per_hour); // Normal fee outside peak hours
            end
        endcase
    end
end

// Ensure fee does not exceed maximum daily fee
always @(*) begin
    if (dynamic_parking_fee > MAX_DAILY_FEE) begin
        dynamic_parking_fee <= MAX_DAILY_FEE;
    end
end

// QR code generation logic
always @(*) begin
    if (state == EXIT_PROCESSING) begin
        // Calculate time spent parked
        int time_spent = current_time - entry_time[current_slot];
        // Generate QR code with fee, slot, and time spent
        generate_qr_code = generate_qr_code({current_slot, dynamic_parking_fee, time_spent});
    end
end

// Update outputs to use dynamic_parking_fee
assign parking_fee = dynamic_parking_fee;
assign fee_ready = 1'b1; // Assuming fee is always ready after calculation
