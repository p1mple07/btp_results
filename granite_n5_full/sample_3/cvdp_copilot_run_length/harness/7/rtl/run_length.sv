module parallel_run_length #(
    parameter DATA_WIDTH = 8,          // Width of the output run-length counter
    parameter NUM_STREAMS = 4         // Number of parallel input streams
)(
    input wire clk,                       // Clock signal (rising edge-triggered)
    input wire reset_n,                  // Active-low asynchronous reset signal
    input wire [NUM_STREAMS-1:0] data_in,   // Parallel input data streams
    input wire [NUM_STREAMS-1:0] stream_enable,  // Enables run-length tracking for individual streams
    output wire [NUM_STREAMS-1:0] data_out,  // Outputs the last value of each data stream when a valid run length is computed
    output wire [NUM_STREAMS*($clog2(DATA_WIDTH)+1)-1:0] run_value,  // Outputs the run length for each stream
    output wire [NUM_STREAMS-1:0] valid       // Indicates when a new run length is available for each stream
);

    localparam RUN_LENGTH_WIDTH = $clog2(DATA_WIDTH+1);

    reg [RUN_LENGTH_WIDTH-1:0] run_length[NUM_STREAMS-1:0];
    reg [NUM_STREAMS-1:0] prev_data_in[NUM_STREAMS-1:0];

    generate
        for (genvar i = 0; i < NUM_STREAMS; i++) begin : gen_run_length
            always @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    run_length[i]   <= 'b0;           
                    prev_data_in[i] <= 1'b0;			               
                end
                else begin
                    
                    if (data_in[i] == prev_data_in[i]) begin
                        
                        if(run_length[i] == (DATA_WIDTH)) begin
                            run_value[i]  <= run_length[i];
                        end
                        if (run_length[i] < (DATA_WIDTH)) begin
                            run_length[i] <= run_length[i] + 1'b1;
                        end
                        
                        else begin
                            run_length[i] <= 1'b1;			            
                        }
                    end
                    else begin
                        run_value[i]  <= run_length[i];		            
                        run_length[i] <= 1'b1;			                
                    end
                    prev_data_in[i]   <= data_in[i];			            
                end
                
            end
            
            always @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    valid[i]    <= 1'b0;				                
                    data_out[i] <= 1'b0;				                
                end 
                else begin
                    if (run_length[i] == (DATA_WIDTH) || data_in[i]!= prev_data_in[i]) begin
                        valid[i]    <= 1'b1;                          				   
                        data_out[i] <= prev_data_in[i];		            
                    }
                    else begin
                        valid[i]    <= 1'b0;			                
                        data_out[i] <= 1'b0;			                
                    end
                end 
            end
            
        end
    endgenerate

endmodule