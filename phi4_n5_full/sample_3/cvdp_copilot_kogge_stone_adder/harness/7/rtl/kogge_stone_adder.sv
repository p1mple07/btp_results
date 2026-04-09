
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        Sum <= 0;
        done <= 0;
        active <= 0;
        stage <= 0;
    end else if (start && !active) begin
        active <= 1;
        stage <= 0;
        done <= 0;
        Sum <= 0;
    end else if (active) begin
        if (stage == 4) begin
            Sum <= sum_comb;    
            done <= 1;
            active <= 0;
        end else begin
            stage <= stage + 1;
        end
    end else if (!start) begin
        done <= 0;
    end
end
