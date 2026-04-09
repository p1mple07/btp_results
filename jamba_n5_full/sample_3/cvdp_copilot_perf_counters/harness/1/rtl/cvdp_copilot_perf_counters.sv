module perf_counter #(
    parameter CNT_W = 8
)(
    input wire clk,
    input wire reset,
    input wire sw_req_i,
    input wire cpu_trig_i,
    output reg [CNT_W-1:0] p_count_o
);

    reg counter;

    always @(posedge clk) begin
        if (reset)
            counter <= 0;
        else
            if (cpu_trig_i)
                counter <= counter + 1;
    end

    always @(posedge clk) begin
        if (sw_req_i) begin
            p_count_o = counter;
            counter <= 0;
        end else begin
            p_count_o = 0;
        end
    end

endmodule
