always_ff @(posedge clk_in or negedge rst_in) begin
    if (~rst_in) begin
        sync_word <= 2'b00;            
    end 
    else begin
        if (encoder_control_in == 8'b00000000) begin
            sync_word <= 2'b01;         
        end 
        else begin
            sync_word <= 2'b10;         
        end
    end
end

always_ff @(posedge clk_in or negedge rst_in) begin
    if (~rst_in) begin
        encoded_data <= 64'b0;         
    end 
    else begin
        if (encoder_control_in == 8'b00000000) begin
            encoded_data <= encoder_data_in; 
        end
    end
end

assign encoder_data_out = {sync_word, encoded_data};

initial begin
    encoded_data <= 64'hA5A5A5A5A5A5A5A5;
end