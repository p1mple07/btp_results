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
    output reg [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0] run_value,
    output reg [NUM_STREAMS-1:0] valid
)

    reg [NUM_STREAMS-1:0] run_length;
    reg [NUM_STREAMS-1:0] prev_data_in;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_length <= ( replicate({$clog2(DATA_WIDTH)+1} 0) );
            prev_data_in <= ( replicate({$clog2(DATA_WIDTH)+1} 0) );
            valid <= ( replicate({$clog2(DATA_WIDTH)+1} 0) );
        end
        else begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (data_in[i] == prev_data_in[i]) begin
                        if (run_length[i] == DATA_WIDTH) begin
                            run_value[i] <= run_length[i];
                            run_length[i] <= 1;
                        end else if (run_length[i] < DATA_WIDTH) begin
                            run_length[i] <= run_length[i] + 1;
                        end else begin
                            run_length[i] <= 1;
                        end
                    end else begin
                        run_value[i] <= run_length[i];
                        run_length[i] <= 1;
                    end
                    prev_data_in[i] <= data_in[i];
                end
            end
            valid <= ( replicate({$clog2(DATA_WIDTH)+1} 0) );
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (run_length[i] == DATA_WIDTH || data_in[i] != prev_data_in[i]) begin
                        valid[i] <= 1;
                    end else begin
                        valid[i] <= 0;
                    end
                end
            end
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= ( replicate({$clog2(DATA_WIDTH)+1} 0) );
            valid <= ( replicate({$clog2(DATA_WIDTH)+1} 0) );
        end
        else begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (run_length[i] == DATA_WIDTH || data_in[i] != prev_data_in[i]) begin
                        data_out[i] <= prev_data_in[i];
                        run_value[i] <= run_length[i];
                    end else begin
                        data_out[i] <= 0;
                        run_value[i] <= 0;
                    end
                end
            end
        end
    end
endmodule