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
    output reg [NUM_STREAMS-1:0] valid,               // Output valid flag for run length for each stream
    output reg [NUM_STREAMS-1:0] data_out              // Output the last value of each data stream when a valid run length is computed

);

    reg [$clog2(DATA_WIDTH):0] run_lengths [NUM_STREAMS-1:0];

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_lengths <= (NUM_STREAMS-1:0) {DATA_WIDTH{1'b0}};
            data_out <= (NUM_STREAMS-1:0) {1'b0};
            valid <= (NUM_STREAMS-1:0) {1'b0};
        end
        else begin
            if (stream_enable == (NUM_STREAMS-1:0)) begin
                for (int i=0; i<NUM_STREAMS; i=i+1) begin
                    if (data_in[i] == run_lengths[i]) begin
                        if (run_lengths[i] == DATA_WIDTH) begin
                            run_value[i] <= run_lengths[i];
                            data_out[i] <= data_in[i];
                            valid[i] <= 1'b1;
                        end
                        else begin
                            run_lengths[i] <= run_lengths[i] + 1'b1;
                            valid[i] <= 1'b1;
                        end
                    end
                    else begin
                        run_value[i] <= run_lengths[i];
                        data_out[i] <= data_in[i];
                        valid[i] <= 1'b0;
                    end
                end
            end
            else begin
                run_lengths <= (NUM_STREAMS-1:0) {DATA_WIDTH{1'b0}};
                data_out <= (NUM_STREAMS-1:0) {1'b0};
                valid <= (NUM_STREAMS-1:0) {1'b0};
            end
        end
    end

endmodule