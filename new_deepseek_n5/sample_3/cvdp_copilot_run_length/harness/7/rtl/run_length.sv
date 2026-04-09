module parallel_run_length
#(
    parameter DATA_WIDTH = 8,
    parameter NUM_STREAMS = 4
)
(
    input wire clk,
    input wire reset_n,
    input wire data_in [NUM_STREAMS-1:0],
    input wire stream_enable [NUM_STREAMS-1:0],
    output reg data_out [NUM_STREAMS-1:0],
    output reg data_out [NUM_STREAMS-1:0],
    output reg run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0],
    output reg valid [NUM_STREAMS-1:0]
)
    // Module initialization code
    reg [NUM_STREAMS-1:0] run_length [0:$(clog2(DATA_WIDTH)-1)];
    reg [NUM_STREAMS-1:0] prev_data_in [0:NUM_STREAMS-1];
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Initialize all outputs and registers to default values
            data_out <= (NUM_STREAMS-1:0) {1'b0};
            run_value <= (NUM_STREAMS * ($clog2(DATA_WIDTH)+1)-1:0) {1'b0};
            valid <= (NUM_STREAMS-1:0) {1'b0};
            // Initialize run_length for all streams
            run_length <= (NUM_STREAMS-1:0) {1'b0};
            prev_data_in <= (NUM_STREAMS-1:0) {1'b0};
        end
        else begin
            for (i = 0; i < NUM_STREAMS; i = i + 1) begin
                if (stream_enable[i]) begin
                    if (data_in[i] == prev_data_in[i]) begin
                        if (run_length[i] == DATA_WIDTH) begin
                            // Output the run length and reset counter
                            run_value[i * ($clog2(DATA_WIDTH)+1)] <= run_length[i];
                            data_out[i] <= prev_data_in[i];
                            run_length[i] <= 1'b1;
                        end else if (run_length[i] < DATA_WIDTH) begin
                            run_length[i] <= run_length[i] + 1'b1;
                        end else begin
                            // New value encountered, output current run length and reset counter
                            run_value[i * ($clog2(DATA_WIDTH)+1)] <= run_length[i];
                            data_out[i] <= data_in[i];
                            run_length[i] <= 1'b1;
                        end
                    end else begin
                        // Value changed, output current run length and reset counter
                        run_value[i * ($clog2(DATA_WIDTH)+1)] <= run_length[i];
                        data_out[i] <= prev_data_in[i];
                        run_length[i] <= 1'b1;
                    end
                    prev_data_in[i] <= data_in[i];
                end
            end
        end
    end
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            valid <= (NUM_STREAMS-1:0) {1'b0};
        end else begin
            valid <= (NUM_STREAMS-1:0) {1'b0};
            for (i = 0; i < NUM_STREAMS; i = i + 1) begin
                if (stream_enable[i]) begin
                    if (run_length[i] == DATA_WIDTH || data_in[i] != prev_data_in[i]) begin
                        // Valid run length available
                        valid[i] <= 1'b1;
                    end else begin
                        valid[i] <= 1'b0;
                    end
                end
            end
        end
    end
endmodule