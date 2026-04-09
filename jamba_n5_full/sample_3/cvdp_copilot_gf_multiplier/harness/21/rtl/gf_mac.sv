always @(*) begin
    if (WIDTH % 8 != 0) begin
        error_flag = 1;
        valid_result = 0;
    end else begin
        // original code
    end
end
