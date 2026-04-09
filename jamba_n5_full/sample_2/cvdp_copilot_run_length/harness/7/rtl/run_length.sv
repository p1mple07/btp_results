module parallel_run_length #(
    parameter DATA_WIDTH = 8,
    parameter NUM_STREAMS = 4
)(
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable,
    output reg [NUM_STREAMS-1:0] data_out,
    output reg [NUM_STREAMS*($clog2(DATA_WIDTH)+1)-1:0] run_value,
    output reg [NUM_STREAMS-1:0] valid
);

    reg [$clog2(DATA_WIDTH):0] run_length_arr[NUM_STREAMS];
    reg prev_data_in_arr[NUM_STREAMS];
    reg valid_arr[NUM_STREAMS];
    reg [$clog2(DATA_WIDTH):0] run_value_arr[NUM_STREAMS];

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_length_arr <= {$ones{num_streams}, $zeros{num_streams}};
            prev_data_in_arr <= {$ones{num_streams}, $zeros{num_streams}};
            valid_arr <= {$ones{num_streams}, $zeros{num_streams}};
            run_value_arr <= {$ones{num_streams}, $zeros{num_streams}};
        end else begin

            for (int i = 0; i < num_streams; i++) begin
                if (stream_enable[i]) begin
                    if (data_in[i] == prev_data_in_arr[i]) begin
                        if (run_length_arr[i] == (DATA_WIDTH)) begin
                            run_value_arr[i] = run_length_arr[i];
                        end
                        if (run_length_arr[i] < (DATA_WIDTH)) begin
                            run_length_arr[i] <= run_length_arr[i] + 1'b1;
                        end else begin
                            run_length_arr[i] <= 1'b1;
                        end
                    end else begin
                        run_value_arr[i] = run_length_arr[i];
                        run_length_arr[i] <= 1'b1;
                    end
                    prev_data_in_arr[i] <= data_in[i];
                end
            }

            for (int i = 0; i < num_streams; i++) begin
                if (stream_enable[i] && run_length_arr[i] == (DATA_WIDTH) || data_in[i] != prev_data_in_arr[i]) begin
                    valid[i] = 1'b1;
                    data_out[i] = prev_data_in_arr[i];
                } else begin
                    valid[i] = 1'b0;
                    data_out[i] = 1'b0;
                end
            }
        end
    end

endmodule
