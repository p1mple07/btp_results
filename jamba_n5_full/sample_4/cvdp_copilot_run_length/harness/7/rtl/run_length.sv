module parallel_run_length (
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable,
    output reg [NUM_STREAMS-1:0] data_out,
    output reg [NUM_STREAMS * ($clog2(DATA_WIDTH)+1) - 1 : 0] run_value,
    output reg [NUM_STREAMS-1:0] valid
);

parameter DATA_WIDTH = 8;
parameter NUM_STREAMS = 4;

reg [$clog2(DATA_WIDTH):0] run_length;
reg prev_data_in;
reg [NUM_STREAMS-1:0] data_out_temp;
reg [NUM_STREAMS * ($clog2(DATA_WIDTH)+1) - 1 : 0] run_value_temp;
reg [NUM_STREAMS-1:0] valid_temp;

initial begin
    data_out_temp <= {NUM_STREAMS{1'b0}};
    run_value_temp <= {NUM_STREAMS{1'b0}};
    valid_temp <= {NUM_STREAMS{1'b0}};
    prev_data_in <= 1'b0;
end

always @(posedge clk or negedge reset_n) begin
    if (reset_n) begin
        // Reset all outputs
        data_out_temp <= {NUM_STREAMS{1'b0}};
        run_value_temp <= {NUM_STREAMS{1'b0}};
        valid_temp <= {NUM_STREAMS{1'b0}};
        prev_data_in <= 1'b0;
    end
    else begin
        // Process each stream
        for (int i = 0; i < NUM_STREAMS; i++) begin
            if (stream_enable[i]) begin
                if (data_in[i] == prev_data_in[i]) begin
                    if (run_length[i] == (DATA_WIDTH)) begin
                        run_value_temp[i] = run_length[i];
                    end
                    if (run_length[i] < (DATA_WIDTH)) begin
                        run_length[i] <= run_length[i] + 1'b1;
                    end
                    else begin
                        run_length[i] <= 1'b1;
                    end
                end else begin
                    run_value_temp[i] <= run_length[i];
                    run_length[i] <= 1'b1;
                end
                prev_data_in[i] <= data_in[i];
            end
        end
    end
end

assign data_out = data_out_temp;
assign run_value = run_value_temp;
assign valid = valid_temp;

initial begin
    #5 reset;
end

endmodule
