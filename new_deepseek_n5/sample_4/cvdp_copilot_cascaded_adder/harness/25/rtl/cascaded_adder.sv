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
    // Internal signals
    logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] i_data_ff;
    logic [IN_DATA_WIDTH-1:0] in_data_2d [IN_DATA_NS-1:0];
    logic [(IN_DATA_WIDTH+$clog2(IN_DATA_NS))-1:0] stage_output [NUM_STAGES-1:0][IN_DATA_NS>>1-1:0];
    logic valid_ff;
    logic valid_pipeline [NUM_STAGES-1:0];
    
    // Register the input data on valid signal
    always_ff @(posedge clk or negedge rst_n) begin : reg_indata
        if(!rst_n)
            i_data_ff <= 0;
        else begin
            if(i_valid) begin
                i_data_ff <= i_data;
            end
        end
    end
    
    // Convert flattened input to 2D array
    always_comb begin
        for (int i = 0; i < IN_DATA_NS; i++) begin : conv_1d_to_2d
            in_data_2d[i] = i_data_ff[(i+1)*IN_DATA_WIDTH-1:IN_DATA_WIDTH];
        end
    end
    
    // Adder logic
    always_ff @(posedge clk or negedge rst_n) begin : adder_logic
        if(!rst_n)
            valid_ff <= 1'b0;
        else
            valid_ff <= i_valid;
    end
    
    // Compute adder outputs
    always_comb begin
        for (int stage = 0; stage < NUM_STAGES; stage++) begin
            for (int i = 0; i < (IN_DATA_NS >> (stage+1)); i++) begin
                logic [IN_DATA_WIDTH-1:0] a = in_data_2d[2*i];
                logic [IN_DATA_WIDTH-1:0] b = in_data_2d[2*i+1];
                
                if(REG[stage]) begin
                    stage_output[stage][i] <= a + b + 1'b0;
                else begin
                    stage_output[stage][i] <= a + b;
                end
            end
        end
    end
    
    // Valid signal propagation
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            valid_pipeline <= 1'b0;
        else 
            valid_pipeline[0] <= valid_ff;
            for (int stage = 0; stage < NUM_STAGES-1; stage++) begin
                valid_pipeline[stage+1] <= valid_pipeline[stage] & valid_pipeline[stage];
            end
    end
    
    // Assign final valid and output
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            o_valid <= 1'b0;
        else
            o_valid <= valid_pipeline[NUM_STAGES-1];
    end
    
    always_ff @(posedge clk or negedge rst_n) begin : reg_outdata
        if (!rst_n) begin
            o_data <= 0;
        end else if (valid_pipeline[NUM_STAGES-1]) begin
            o_data <= stage_output[NUM_STAGES-1][0];
        end
    end
endmodule