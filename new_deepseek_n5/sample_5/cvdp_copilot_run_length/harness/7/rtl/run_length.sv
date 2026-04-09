module parallel_run_length
#(
    parameter DATA_WIDTH = 8,
    parameter NUM_STREAMS = 4
)
(
    input wire clk,
    input wire reset_n,
    input wire data_in[NUM_STREAMS-1:0],
    input wire stream_enable[NUM_STREAMS-1:0],
    output reg data_out[NUM_STREAMS-1:0],
    output reg run_value[((NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1):0],
    output reg valid[NUM_STREAMS-1:0]
);

    reg data_out_reg[NUM_STREAMS-1:0];
    reg run_value_reg[NUM_STREAMS-1:0];
    reg valid_reg[NUM_STREAMS-1:0];
    reg prev_data_in[NUM_STREAMS-1:0];
    reg run_length[NUM_STREAMS-1:0];

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                data_out_reg[i] = 0;
                run_value_reg[i] = 0;
                valid_reg[i] = 0;
                prev_data_in[i] = 0;
                run_length[i] = 0;
            end
            valid <= valid_reg;
            data_out <= data_out_reg;
        end
        else begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (data_in[i] == prev_data_in[i]) begin
                        if (run_length[i] == DATA_WIDTH) begin
                            run_value_reg[i] = run_length[i];
                        else if (run_length[i] < DATA_WIDTH) begin
                            run_length[i] = run_length[i] + 1;
                        else begin
                            run_length[i] = 1;
                        end
                    end
                    else begin
                        run_value_reg[i] = run_length[i];
                        run_length[i] = 1;
                    end
                    prev_data_in[i] = data_in[i];
                end
            end
            valid <= valid_reg;
            data_out <= data_out_reg;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            valid_reg <= (all(valid_reg));
            data_out_reg <= (all(data_out_reg));
        end
        else begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (run_length[i] == DATA_WIDTH || data_in[i] != prev_data_in[i]) begin
                        valid_reg[i] = 1;
                    end
                    else begin
                        valid_reg[i] = 0;
                    end
                end
            end
        end
    end
endmodule