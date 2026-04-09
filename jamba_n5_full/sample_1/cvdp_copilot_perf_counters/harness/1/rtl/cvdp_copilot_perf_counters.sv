module perf_counter #(parameter CNT_W = 32) (
    input wire clk,
    input wire reset,
    input wire sw_req_i,
    input wire cpu_trig_i,
    output reg p_count_o
);

reg async_reset;
reg [CNT_W-1:0] counter;

always @(posedge clk) begin
    async_reset <= reset;
end

always @(*) begin
    if (async_reset) begin
        counter <= 0;
    end
end

always @(posedge clk) begin
    if (sw_req_i) begin
        p_count_o = counter;
        counter <= 0;
    end
end

always @(posedge clk) begin
    if (cpu_trig_i) counter <= counter + 1;
end

endmodule
