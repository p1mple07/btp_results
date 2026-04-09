
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
         sample_delay1 <= 0;
         sample_delay2 <= 0;
         sample_delay3 <= 0;
         accumulator <= 0;
         // pipeline registers for output
         pipeline_reg0 <= 0;
         pipeline_reg1 <= 0;
         pipeline_reg2 <= 0;
         output_sample <= 0;
    end else begin
         // shift delays: sample_delay1 <= sample_delay2, sample_delay2 <= sample_delay3, sample_delay3 <= input_sample;
         // update accumulator: accumulator <= coeff0*input_sample + coeff1*sample_delay1 + coeff2*sample_delay2 + coeff3*sample_delay3;
         // pipeline registers: pipeline_reg0 <= accumulator; pipeline_reg1 <= pipeline_reg0; pipeline_reg2 <= pipeline_reg1; output_sample <= pipeline_reg2;
    end
end
