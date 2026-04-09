
module parallel_run_length
#(
    parameter DATA_WIDTH = 8,                        // Width of the output run-length counter
    parameter NUM_STREAMS = 4                        // Number of parallel input streams
)
(
    input wire clk,                                 // Clock signal      
    input wire reset_n,                             // Active-low reset signal     
    input wire [NUM_STREAMS-1:0] data_in,            // Parallel input data streams
    input wire [NUM_STREAMS-1:0] stream_enable,      // Enables run-length tracking for individual streams
    output reg [NUM_STREAMS*(DATA_WIDTH+1)-1:0] run_value,    // Output the run length value for each stream
    output reg [NUM_STREAMS-1:0] valid                // Output valid flag for run length for each stream
);

    reg [DATA_WIDTH-1:0] run_length [NUM_STREAMS-1:0]; // Run length counters for each stream
    reg prev_data_in [NUM_STREAMS-1:0];              // Previous data input for each stream

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i=0; i<NUM_STREAMS; i=i+1) begin
                run_length[i] <= 'b0;
                valid[i] <= 1'b0;
            end
        end
        else begin
            for (int i=0; i<NUM_STREAMS; i=i+1) begin
                if (stream_enable[i]) begin
                    if (data_in[i] == prev_data_in[i]) begin
                        if (run_length[i] == (DATA_WIDTH-1)) begin
                            run_value[i*DATA_WIDTH+(DATA_WIDTH-1)] <= run_length[i];
                            valid[i] <= 1'b1;
                            run_length[i] <= (DATA_WIDTH-1);
                        end
                        else begin
                            run_length[i] <= run_length[i] + 1'b1;
                        end
                    end
                    else begin
                        run_value[i*DATA_WIDTH+(run_length[i]-1)] <= run_length[i];
                        valid[i] <= 1'b1;
                        run_length[i] <= 1'b1;
                    end
                    prev_data_in[i] <= data_in[i];
                end
                else begin
                    run_length[i] <= 'b0;
                    valid[i] <= 1'b0;
                end
            end
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i=0; i<NUM_STREAMS; i=i+1) begin
                data_out[i] <= 1'b0;
            end
        end
        else begin
            for (int i=0; i<NUM_STREAMS; i=i+1) begin
                if (stream_enable[i]) begin
                    if (valid[i]) begin
                        data_out[i] <= prev_data_in[i];
                        valid[i] <= 1'b0;
                    end
                end
                else begin
                    data_out[i] <= 1'b0;
                    valid[i] <= 1'b0;
                end
            end
        end
    end
endmodule
