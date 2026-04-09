module parallel_run_length #(
    parameter DATA_WIDTH = 8,          // Width of the output run-length counter
    parameter NUM_STREAMS = 4         // Number of parallel input streams
)(
    input  wire                   clk,           // Clock signal
    input  wire                   reset_n,       // Active-low asynchronous reset signal
    input  wire [NUM_STREAMS-1:0] data_in,       // Parallel input data streams
    input  wire [NUM_STREAMS-1:0] stream_enable, // Enables run-length tracking for individual streams
    output reg  [NUM_STREAMS-1:0] data_out,      // Outputs the last value of each data stream when a valid run length is computed
    output reg  [NUM_STREAMS*($clog2(DATA_WIDTH)+1)-1:0] run_value,  // Outputs the run length for each stream
    output reg  [NUM_STREAMS-1:0] valid          // Indicates when a new run length is available for each stream
);

    localparam RUN_LENGTH_WIDTH = $clog2(DATA_WIDTH);

    reg  [RUN_LENGTH_WIDTH-1:0] run_length [NUM_STREAMS];
    reg                              run_started [NUM_STREAMS];
    reg                              stream_running [NUM_STREAMS];

    assign valid = |(stream_running & run_started);

    always @* begin

        for (int i=0; i<NUM_STREAMS; i++) begin

            stream_running[i] = stream_enable[i] && valid[i];
            run_started[i]     = stream_enable[i] &&!valid[i];

            if (stream_running[i]) begin

                if (data_in[i] === run_length[i][RUN_LENGTH_WIDTH-1:0]) begin

                    if (run_length[i] == (DATA_WIDTH-1)) begin
                        run_value[i] <= run_length[i];
                    end
                    if (run_length[i] < (DATA_WIDTH-1)) begin
                        run_length[i] <= run_length[i] + 1'b1;
                    end
                    
                    else begin
                        run_length[i] <= 1'b1;			            
                    end
                }
                else begin
                    run_value[i]  <= run_length[i];		            
                    run_length[i] <= 1'b1;			                
                end
            end
            
            else begin
                run_value[i]  <= run_length[i];		            
                run_length[i] <= 1'b1;			                
            end

        end

    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 'b0;                           
            run_value <= 'b0;	       
            stream_running <= 'b0;			             
        end
        else begin
             if (|stream_enable) begin
                
                for (int i=0; i<NUM_STREAMS; i++) begin
                
                    if (stream_enable[i]) begin

                        if (stream_running[i]) begin

                            if (data_in[i] === run_length[i][RUN_LENGTH_WIDTH-1:0]) begin

                                if (run_length[i] == (DATA_WIDTH-1)) begin
                                    run_value[i] <= run_length[i];
                                end
                                if (run_length[i] < (DATA_WIDTH-1)) begin
                                    run_length[i] <= run_length[i] + 1'b1;
                                end
                                
                                else begin
                                    run_length[i] <= 1'b1;			            
                                end
                            end
                            else begin
                                run_value[i]  <= run_length[i];		            
                                run_length[i] <= 1'b1;			                
                            end
                        end
                        else begin
                            run_value[i] <= run_length[i];	           
                            run_length[i] <= 1'b0;
                        end
                        
                    end
                    
                    
                    
                end
                
            end
            
        end 

    endmodule