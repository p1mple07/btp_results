
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
    output reg [NUM_STREAMS-1:0] data_out,           // Outputs the last value of each data stream when a valid run length is computed
    output reg [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0] run_value, // Outputs the run length for each stream
    output reg [NUM_STREAMS-1:0] valid               // Indicates when a new run length is available for each stream

);

    reg [DATA_WIDTH-1:0] run_lengths [NUM_STREAMS-1:0]; // Run length counters for each stream
    reg [DATA_WIDTH-1:0] prev_data_in [NUM_STREAMS-1:0]; // Previous data values for each stream

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_lengths <= 'b0;
            valid    <= 'b0;
            data_out <= 'b0;
        end
        else begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (data_in[i] == prev_data_in[i]) begin
                        run_lengths[i] <= run_lengths[i] + 1'b1;
                        if (run_lengths[i] == DATA_WIDTH) begin
                            valid[i] <= 1'b1;
                            data_out[i] <= prev_data_in[i];
                            run_value[i * ($clog2(DATA_WIDTH)+1) + DATA_WIDTH - 1:0] <= run_lengths[i];
                        end
                    end
                    else begin
                        valid[i] <= 1'b1;
                        data_out[i] <= prev_data_in[i];
                        run_value[i * ($clog2(DATA_WIDTH)+1) + DATA_WIDTH - 1:0] <= run_lengths[i];
                        run_lengths[i] <= 1'b1;
                    end
                    prev_data_in[i] <= data_in[i];
                end
                else begin
                    valid[i] <= 'b0;
                    data_out[i] <= 'b0;
                    run_lengths[i] <= 'b0;
                end
            end
        end
    end

endmodule
