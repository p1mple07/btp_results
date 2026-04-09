module performance_counter #(
    parameter CNT_W = 8
) (
    input wire clk,
    input wire reset,
    input wire sw_req_i,
    input wire cpu_trig_i,
    output reg [CNT_W-1:0] p_count_o
);

reg current_count;
reg temp_count;
reg temp_temp;
reg counter_started;

always @(posedge clk) begin
    if (!reset) begin
        current_count <= 0;
        counter_started <= 0;
        p_count_o <= 0;
    end else begin
        if (cpu_trig_i) begin
            current_count <= current_count + 1;
        end
    end
end

always @(*) begin
    if (sw_req_i) begin
        p_count_o = current_count;
        current_count <= 0;
        counter_started <= 0;
    end
end

endmodule
