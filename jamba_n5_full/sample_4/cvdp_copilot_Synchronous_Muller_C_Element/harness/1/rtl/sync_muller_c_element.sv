genvar i;
for (i = 0; i < PIPE_DEPTH; i++) begin : pipeline
    always @(posedge clk) begin
        if (clk_en) begin
            // Shift register: we want to shift the data
            pipeline[i] <= pipeline[(i+1)*NUM_INPUT];
        end
    end
endfor
