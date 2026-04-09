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
    output reg run_value[(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0],
    output reg valid[NUM_STREAMS-1:0]
);

    reg clock gating : posedge;
    reg prev_data[NUM_STREAMS-1:0];
    reg run_length[NUM_STREAMS-1:0];
    
    always begin
        clock = !reset_n;
        
        if (!reset_n) begin
            run_length<NUM_STREAMS-1:0> <= 0;
            prev_data<NUM_STREAMS-1:0> <= 0;
            data_out<NUM_STREAMS-1:0> <= 0;
        end else begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (data_in[i] == prev_data[i]) begin
                        if (run_length[i] == DATA_WIDTH) begin
                            run_value[(i * ($clog2(DATA_WIDTH)+1)) + 0] <= DATA_WIDTH;
                        else if (run_length[i] < DATA_WIDTH) begin
                            run_value[(i * ($clog2(DATA_WIDTH)+1)) + 0] <= run_length[i] + 1;
                        else begin
                            run_value[(i * ($clog2(DATA_WIDTH)+1)) + 0] <= 1;
                        end
                        run_length[i] <= run_length[i] + (data_in[i] == prev_data[i] ? 1 : 0);
                    end else begin
                        run_value[(i * ($clog2(DATA_WIDTH)+1)) + 0] <= run_length[i];
                        run_length[i] <= 1;
                        data_out[i] <= prev_data[i];
                    end
                    prev_data[i] <= data_in[i];
                end
            end
        end
    end
    
    always begin
        if (!reset_n) begin
            valid<NUM_STREAMS-1:0> <= 0;
        end else begin
            for (int i = 0; i < NUM_STREAMS; i++) begin
                if (stream_enable[i]) begin
                    if (run_length[i] == DATA_WIDTH || data_in[i] != prev_data[i]) begin
                        valid[i] <= 1;
                        data_out[i] <= prev_data[i];
                    end else begin
                        valid[i] <= 0;
                        data_out[i] <= 0;
                    end
                end
            end
        end
    end
endmodule