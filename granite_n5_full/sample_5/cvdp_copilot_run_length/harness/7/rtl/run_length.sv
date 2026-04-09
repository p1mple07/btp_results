module parallel_run_length #(
    parameter DATA_WIDTH = 8,
    parameter NUM_STREAMS = 4
) (
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable,
    output reg [NUM_STREAMS-1:0] data_out,
    output reg [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0] run_value,
    output reg [NUM_STREAMS-1:0] valid
);

reg [DATA_WIDTH-1:0] run_lengths [NUM_STREAMS-1:0];
reg [DATA_WIDTH-1:0] run_counts [NUM_STREAMS-1:0];
reg [NUM_STREAMS-1:0] enabled_streams;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        for (int i = 0; i < NUM_STREAMS; i++) begin
            run_lengths[i] <= 'b0;
            run_counts[i] <= 'b0;
            enabled_streams[i] <= 1'b0;
        end
    end else begin
        for (int i = 0; i < NUM_STREAMS; i++) begin
            if (enabled_streams[i]) begin
                if (data_in[i]!= run_lengths[i][DATA_WIDTH-1:0]) begin
                    run_counts[i] <= run_counts[i] + 1'b1;
                    if (run_counts[i] == DATA_WIDTH) begin
                        run_value[i] <= run_lengths[i];
                        run_counts[i] <= 'b0;
                    end
                end else begin
                    run_counts[i] <= 'b0;
                end
            end
        end
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        for (int i = 0; i < NUM_STREAMS; i++) begin
            valid[i] <= 1'b0;
            data_out[i] <= 'b0;
        end
    end else begin
        for (int i = 0; i < NUM_STREAMS; i++) begin
            if (enabled_streams[i]) begin
                if (run_counts[i] == DATA_WIDTH) begin
                    valid[i] <= 1'b1;
                    data_out[i] <= run_lengths[i][DATA_WIDTH-1:0];
                end else begin
                    valid[i] <= 1'b0;
                    data_out[i] <= 'b0;
                end
            end
        end
    end
end

always @(posedge clk) begin
    for (int i = 0; i < NUM_STREAMS; i++) begin
        if (stream_enable[i]) begin
            enabled_streams[i] <= 1'b1;
        end else begin
            enabled_streams[i] <= 1'b0;
        end
    end
end

endmodule