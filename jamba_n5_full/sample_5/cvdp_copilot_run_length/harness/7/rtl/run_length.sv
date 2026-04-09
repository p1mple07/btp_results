module parallel_run_length(
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable,
    output reg [NUM_STREAMS-1:0] data_out,
    output reg [$clog2(DATA_WIDTH):0] run_value,
    output reg [NUM_STREAMS-1:0] valid
);

    reg [$clog2(DATA_WIDTH):0] run_length_per_stream;
    reg prev_data_per_stream;
    reg valid_per_stream;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for i in 0 to NUM_STREAMS-1 begin
                run_length_per_stream[i] <= 'b0;
                prev_data_per_stream[i] <= 1'b0;
                valid_per_stream[i] <= 1'b0;
            end
        end else begin
            for i in 0 to NUM_STREAMS-1 begin
                if (stream_enable[i] == 1'b1) begin
                    if (data_in[i] == prev_data_per_stream[i]) begin
                        if (run_length_per_stream[i] == (DATA_WIDTH)) begin
                            run_value[i] <= run_length_per_stream[i];
                        end
                        if (run_length_per_stream[i] < (DATA_WIDTH)) begin
                            run_length_per_stream[i] <= run_length_per_stream[i] + 1'b1;
                        end
                        else begin
                            run_length_per_stream[i] <= 1'b1;
                        end
                    end
                    else begin
                        run_value[i] <= run_length_per_stream[i];
                        run_length_per_stream[i] <= 1'b1;
                    end
                    prev_data_per_stream[i] <= data_in[i];
                end
                else begin
                    run_length_per_stream[i] <= 'b0;
                    prev_data_per_stream[i] <= 1'b0;
                    valid_per_stream[i] <= 1'b0;
                end
            end

            // Determine valid outputs
            for i in 0 to NUM_STREAMS-1 begin
                if (stream_enable[i] == 1'b1 && valid_per_stream[i] == 1'b1) begin
                    valid[i] <= 1'b1;
                    data_out[i] <= prev_data_per_stream[i];
                end else begin
                    valid[i] <= 1'b0;
                    data_out[i] <= 1'b0;
                end
            end
        end
    end

endmodule
