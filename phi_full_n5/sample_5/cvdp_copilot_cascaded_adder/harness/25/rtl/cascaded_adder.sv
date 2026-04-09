// Insert Code here for parallel logic of the adder tree using generate statements
genvar stage;
generate
    for (stage = 0; stage < NUM_STAGES; stage = stage + 1) begin : adder_stage
        if (REG[stage]) begin
            always_comb begin
                in_data_2d[stage*IN_DATA_NS/2] = in_data_2d[stage*IN_DATA_NS/2] + in_data_2d[stage*IN_DATA_NS/2 + IN_DATA_NS/2];
            end
        end
    end
endgenerate

// Insert Code here for Valid signal propagation with latency based on REG
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        valid_pipeline[NUM_STAGES-1] <= 1'b0;
        for (int i = NUM_STAGES - 2; i >= 0; i = i - 1) begin : valid_propagation
            valid_pipeline[i] <= valid_pipeline[i+1];
        end
    end else begin
        valid_pipeline[NUM_STAGES-1] <= valid_ff;
        for (int i = NUM_STAGES - 2; i >= 0; i = i - 1) begin : valid_propagation
            valid_pipeline[i] <= valid_pipeline[i+1] & valid_ff;
        end
    end
end

// The output data assignment is already correctly placed in the reg_outdata always_ff block
