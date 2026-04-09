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
    output reg [NUM_STREAMS-1:0] data_out,          // Outputs the last value of each data stream
    output reg [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0] run_value, // Outputs the run length for each stream
    output reg [NUM_STREAMS-1:0] valid               // Indicates when a new run length is available for each stream
);

    integer stream_index;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (stream_index = 0; stream_index < NUM_STREAMS; stream_index++) begin
                data_out[stream_index] <= 1'b0;
                run_value[stream_index * ($clog2(DATA_WIDTH)+1) - 1 : stream_index * ($clog2(DATA_WIDTH)+1) - 1] <= 1'b0;
                valid[stream_index] <= 1'b0;
            end
        end
        else begin
            for (stream_index = 0; stream_index < NUM_STREAMS; stream_index++) begin
                if (stream_enable[stream_index]) begin
                    if (data_in[stream_index] == data_in[stream_index - 1]) begin
                        if (run_value[stream_index * ($clog2(DATA_WIDTH)+1) - 1] == (DATA_WIDTH - 1)) begin
                            run_value[stream_index * ($clog2(DATA_WIDTH)+1) - 1] <= 0;
                            data_out[stream_index] <= data_in[stream_index];
                            valid[stream_index] <= 1'b1;
                        end
                        else begin
                            run_value[stream_index * ($clog2(DATA_WIDTH)+1) - 1] <= run_value[stream_index * ($clog2(DATA_WIDTH)+1) - 1] + 1'b1;
                        end
                    end
                    else begin
                        run_value[stream_index * ($clog2(DATA_WIDTH)+1) - 1] <= 1'b1;
                        data_out[stream_index] <= data_in[stream_index];
                        valid[stream_index] <= 1'b1;
                    end
                end
                else begin
                    data_out[stream_index] <= 1'b0;
                    run_value[stream_index * ($clog2(DATA_WIDTH)+1) - 1 : stream_index * ($clog2(DATA_WIDTH)+1) - 1] <= 1'b0;
                    valid[stream_index] <= 1'b0;
                end
            end
        end
    end
endmodule