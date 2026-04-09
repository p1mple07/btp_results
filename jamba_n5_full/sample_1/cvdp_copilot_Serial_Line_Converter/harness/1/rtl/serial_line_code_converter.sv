
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        prev_value <= 0;
        prev_serial_in <= 0;
    end else begin
        prev_value <= serial_in;
        prev_serial_in <= prev_value;
    end
end
