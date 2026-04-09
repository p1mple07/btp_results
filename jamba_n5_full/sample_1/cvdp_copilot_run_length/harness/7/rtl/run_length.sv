module parallel_run_length #(
    parameter DATA_WIDTH = 8,
    parameter NUM_STREAMS = 4
)(
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable
);

    reg [$clog2(DATA_WIDTH):0] run_value;
    reg [NUM_STREAMS-1:0] data_out;
    reg [NUM_STREAMS-1:0] valid;

    reg [NUM_STREAMS-1:0] current_data;
    reg [NUM_STREAMS-1:0] current_enable;
    reg [NUM_STREAMS-1:0] run_length_temp;
    reg [NUM_STREAMS-1:0] prev_data;

    initial begin
        run_value = {1'b0};
        data_out = {NUM_STREAMS{1'b0}};
        valid = {NUM_STREAMS{1'b0}};
        for (int i = 0; i < NUM_STREAMS; i++) begin
            current_data = data_in[i];
            current_enable = stream_enable[i];
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_value = {1'b0};
            data_out = {NUM_STREAMS{1'b0}};
            valid = {NUM_STREAMS{1'b0}};
            return;
        end

        if (stream_enable[i] && current_enable) begin
            if (current_data == prev_data) begin
                if (run_length_temp == (DATA_WIDTH)) begin
                    run_value = run_value;
                end
                if (run_length_temp < (DATA_WIDTH)) begin
                    run_length_temp = run_length_temp + 1'b1;
                end
                else begin
                    run_length_temp = 1'b1;
                end
            end
            else begin
                run_value = run_value;
                run_length_temp = 1'b1;
            end

            prev_data = current_data;
        end

        else begin
            run_value = {1'b0};
            data_out[i] = 1'b0;
            valid[i] = 1'b0;
        end
    end

endmodule
