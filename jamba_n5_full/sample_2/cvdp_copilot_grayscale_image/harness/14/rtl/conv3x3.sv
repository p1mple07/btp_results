always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pipeline_sum_stage10 <= 0;
        pipeline_sum_stage11 <= 0;
        pipeline_sum_stage12 <= 0;
    end else begin
        pipeline_sum_stage10 <= mult_result0 + mult_result1 + mult_result2;
        pipeline_sum_stage11 <= mult_result3 + mult_result4; 
        pipeline_sum_stage12 <= mult_result6 + mult_result7 + mult_result8;
    end
end
