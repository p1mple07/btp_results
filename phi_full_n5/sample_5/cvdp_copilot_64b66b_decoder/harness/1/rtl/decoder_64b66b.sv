always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
        decoder_data_out <= 64'b0; 
        sync_error <= 1'b0;        
    end 
    else begin
        case (sync_header)
            2'b01: begin
                decoder_data_out <= data_in;
                sync_error <= 1'b0;
            end
            2'b10: begin
                decoder_data_out <= 64'b0;
                sync_error <= 1'b1;
            end
            2'b00: begin
                decoder_data_out <= 64'b0;
                sync_error <= 1'b1;
            end
            2'b11: begin
                decoder_data_out <= 64'b0;
                sync_error <= 1'b1;
            end
            default: begin
                decoder_data_out <= 64'b0;
                sync_error <= 1'b1;
            end
        endcase
    end
endmodule
