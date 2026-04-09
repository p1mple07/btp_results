always @ (clk_in) begin
    if (rst_in) begin
        encoder_data_out = 64'h0000000000000000;
    else begin
        if (encoder_control_in == 8'b00000000) begin
            encoder_data_out = encoder_data_in;
        else begin
            encoder_data_out = (2'b10) | (64'h0 << 64);
        end
    end
end