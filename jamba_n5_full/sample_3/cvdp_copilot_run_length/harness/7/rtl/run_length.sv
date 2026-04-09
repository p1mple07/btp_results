module parallel_run_length #(
    parameter DATA_WIDTH = 8
)
(
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable,
    output reg [NUM_STREAMS*($clog2(DATA_WIDTH)+1)-1:0] data_out,
    output reg [(NUM_STREAMS*($clog2(DATA_WIDTH)+1)-1:0]) run_value,
    output reg [NUM_STREAMS*($clog2(DATA_WIDTH)+1)-1:0] valid
);

    localparam num_streams = NUM_STREAMS;
    localparam max_run = DATA_WIDTH;

    reg [$clog2(DATA_WIDTH):0] run_length_per_stream;
    reg [NUM_STREAMS-1:0] prev_data;
    reg [NUM_STREAMS-1:0] stream_prev_run_length;
    reg [NUM_STREAMS-1:0] stream_valid;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_length_per_stream <= {num_streams{1'b0}};
            prev_data <= {num_streams{1'b0}};
            stream_prev_run_length <= {num_streams{1'b0}};
            stream_valid <= {num_streams{1'b0}};
            data_out <= {num_streams{1'b0}};
            run_value <= {num_streams{1'b0}};
            valid <= {num_streams{1'b0}};
        end else begin
            if (!stream_enable[i]) begin
                // Skip this stream
            end else begin
                // Update for this stream
                if (data_in[i] == prev_data[i]) begin
                    if (run_length_per_stream[i] == max_run) begin
                        run_length_per_stream[i] <= 1;
                        run_value[i] <= 1'b1;
                        valid[i] <= 1'b1;
                        data_out[i] <= prev_data[i];
                    end else begin
                        run_length_per_stream[i] <= run_length_per_stream[i] + 1'b1;
                        run_value[i] <= run_length_per_stream[i];
                        valid[i] <= 1'b1;
                        data_out[i] <= prev_data[i];
                    end
                end else begin
                    run_length_per_stream[i] <= 1'b1;
                    run_value[i] <= 1'b1;
                    valid[i] <= 1'b0;
                    data_out[i] <= 1'b0;
                end
            end
        end
    end

    assign data_out = data_out;
    assign run_value = run_value;
    assign valid = valid;

endmodule
