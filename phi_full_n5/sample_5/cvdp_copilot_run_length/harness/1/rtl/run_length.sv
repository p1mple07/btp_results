always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        run_length   <= 'b0;           
        run_value    <= 'b0;	       
        prev_data_in <= 1'b0;			               
    end
    else begin
        if (prev_data_in != data_in) begin
            run_length <= 0;
            data_out <= data_in;
        end
        else begin
            if (run_length == (1 << (DATA_WIDTH - 1))) begin
                run_length <= 0;
                valid <= 1'b0;
            end
            else begin
                run_length <= run_length + 1;
            end
        end
    end
end
