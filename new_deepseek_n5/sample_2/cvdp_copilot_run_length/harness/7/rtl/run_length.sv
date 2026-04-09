module parallel_run_length
#(
    parameter DATA_WIDTH = 8,
    parameter NUM_STREAMS = 4
)
(
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable,
    output reg [NUM_STREAMS-1:0] data_out,
    output reg [NUM_STREAMS-1:0] valid,
    output reg [NUM_STREAMS-1:0] run_value
);

    reg [NUM_STREAMS-1:0] prev_data_in;
    reg [NUM_STREAMS-1:0] run_length;
    reg [NUM_STREAMS-1:0] run_value_out;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_data_in <= (NUM_STREAMS-1:0) {1'b0};
            run_length <= (NUM_STREAMS-1:0) {1'b0};
            run_value_out <= (NUM_STREAMS-1:0) {1'b0};
        end else begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (data_in[i] == prev_data_in[i]) begin
                        if (run_length[i] == DATA_WIDTH) begin
                            run_value_out[i] = run_length[i];
                            run_length[i] = 1'b1;
                        else if (run_length[i] < DATA_WIDTH) begin
                            run_length[i] = run_length[i] + 1'b1;
                        else begin
                            run_length[i] = 1'b1;
                        end
                    end else begin
                        run_value_out[i] = run_length[i];
                        run_length[i] = 1'b1;
                    end
                    prev_data_in[i] = data_in[i];
                end else begin
                    run_length[i] = 1'b0;
                    prev_data_in[i] = 1'b0;
                end
            end
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            valid <= (NUM_STREAMS-1:0) {1'b0};
            data_out <= (NUM_STREAMS-1:0) {1'b0};
        end else begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (run_length[i] == DATA_WIDTH || data_in[i] != prev_data_in[i]) begin
                        valid[i] = 1'b1;
                        data_out[i] = prev_data_in[i];
                    else begin
                        valid[i] = 1'b0;
                        data_out[i] = 1'b0;
                    end
                else begin
                    valid[i] = 1'b0;
                    data_out[i] = 1'b0;
                end
            end
        end
    end
endmodule