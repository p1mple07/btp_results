module counter_module (
    input clk, reset, sw_req_i, cpu_trig_i,
    output p_count_o [CNT_W-1:0]
);

    parameter CNT_W = 8;
    reg [CNT_W-1:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else if (sw_req_i) begin
            counter <= counter + 1;
        end
    end

    assign p_count_o = counter;

endmodule
