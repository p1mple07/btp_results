module cascaded_adder #(
    parameter int IN_DATA_WIDTH = 16,
    parameter int IN_DATA_NS = 4,
    parameter int NUM_STAGES = $clog2(IN_DATA_NS),
    parameter logic [NUM_STAGES-1:0] REG = {NUM_STAGES{1'b1}}
) (
    input logic clk,
    input logic rst_n,
    input logic i_valid,
    input logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data,
    output logic o_valid,
    output logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] o_data
)
    // Adder logic
    generate #0
        for (int i = 0; i < NUM_STAGES; i++) begin
            logic [IN_DATA_WIDTH-1:0] sum [IN_DATA_NS >> (i+1)-1:0];
            logic [IN_DATA_WIDTH-1:0] in_a [IN_DATA_NS >> (i+1)-1:0];
            logic [IN_DATA_WIDTH-1:0] in_b [IN_DATA_NS >> (i+1)-1:0];
            
            always comb begin
                in_a[0] = in_data_2d[i*2];
                in_b[0] = in_data_2d[i*2+1];
                sum[0] = in_a[0] + in_b[0];
            end
        end
    endgenerate
    // Valid signal propagation
    logic [NUM_STAGES-1:0] valid_pipeline;
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            valid_pipeline <= 0;
        else
            valid_pipeline = valid_pipeline + (REG >> i);
    end
    // Final output
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            o_valid <= 0;
        else
            o_valid <= valid_pipeline[NUM_STAGES-1];
        end
    // Output data
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) o_data <= 0;
        else if(valid_pipeline[NUM_STAGES-1]) o_data <= stage_output[NUM_STAGES-1][0];
    end
endmodule