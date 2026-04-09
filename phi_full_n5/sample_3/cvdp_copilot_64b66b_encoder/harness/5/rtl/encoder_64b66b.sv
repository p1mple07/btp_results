always_ff @(posedge clk_in or negedge rst_in) begin
    if (~rst_in) begin
        sync_word <= 2'b00;
        encoded_data <= 64'b0; // Clear encoded_data when reset
    end 
    else begin
        if (encoder_control_in == 8'b00000000) begin
            sync_word <= 2'b01;
        end 
        else begin
            sync_word <= 2'b10;
        end
        if (encoder_control_in == 8'b00000000) begin
            encoded_data <= encoder_data_in; 
        end
        else begin
            encoded_data <= 64'b0; // Clear encoded_data when not in data mode
        end
    end
end
