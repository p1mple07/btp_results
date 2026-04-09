// Insert Code here for parallel logic of the adder tree using generate statements
generate
    for (genvar g = 0; g < NUM_STAGES; g++) begin : gen_adder_tree
        // Create a new stage of adders for each level of the tree
        if (REG[g]) begin
            // Registered stage with latency
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    stage_output[g][:0] <= 0;
                end else begin
                    stage_output[g][:0] <= stage_output[g-1][:];
                end
            end

            // Perform parallel addition for the current stage
            always_comb begin
                for (int i = 0; i < IN_DATA_NS; i = i+2) begin : gen_pair_add
                    wire [IN_DATA_WIDTH-1:0] pair_sum = in_data_2d[i] + in_data_2d[i+1];
                    stage_output[g][i] = pair_sum;
                end
            end
        end
    end
endgenerate

// Insert Code here for Valid signal propagation with latency based on REG
genvar valid_gen;
generate
    for (valid_gen = 0; valid_gen < NUM_STAGES; valid_gen++) begin : gen_valid_propagation
        // Calculate the latency for the valid signal at each stage
        logic [NUM_STAGES-1:0] valid_latency;
        if (REG[valid_gen]) begin
            valid_latency = valid_pipeline[valid_gen-1] + 1;
        end else begin
            valid_latency = valid_pipeline[valid_gen-1];
        end

        // Propagate the valid signal with the calculated latency
        always_ff @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                valid_pipeline[valid_gen] <= 1'b0;
            end else begin
                valid_pipeline[valid_gen] <= valid_pipeline[valid_gen-1] & valid_latency;
            end
        end
    end
endgenerate

// Assign the final stage of valid_pipeline to o_valid
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        o_valid <= 1'b0;
    else
        o_valid <= valid_pipeline[NUM_STAGES-1];
end

// Output data assignment
always_ff @(posedge clk or negedge rst_n) begin : reg_outdata
    if ( !rst_n) begin
        o_data <= 0 ;
    end else if (valid_pipeline[NUM_STAGES-1]) begin
        o_data <= stage_output[NUM_STAGES-1][0];
    end
end
