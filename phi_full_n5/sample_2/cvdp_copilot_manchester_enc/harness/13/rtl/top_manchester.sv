   always_ff @(posedge clk_in) begin
       if (rst_in) begin
           enc_data_out <= '0; 
           enc_valid_out <= 1'b0; 
       end else if (enc_valid_in) begin
           for (int i = 0; i < N; i++) begin
               if (enc_data_in[i] == 1'b1) begin
                   enc_data_out[2*i]   <= 1'b1;
                   enc_data_out[2*i+1] <= 1'b0;
               end else begin
                   enc_data_out[2*i]   <= 1'b0;
                   enc_data_out[2*i+1] <= 1'b1;
               end
           end
           enc_valid_out <= 1'b1;
       end else begin
           enc_data_out <= 'd0;
           enc_valid_out <= 1'b0;
       end
   end
   