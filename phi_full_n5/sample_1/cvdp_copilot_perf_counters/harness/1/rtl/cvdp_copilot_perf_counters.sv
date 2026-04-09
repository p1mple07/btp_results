module performance_counter #(parameter W = 8) (
    input clk,
    input reset,
    input sw_req_i,
    input cpu_trig_i,
    output reg signed [W-1:0] p_count_o
);

    reg [W-1:0] count_q;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_q <= 0;
        end else begin
            if (cpu_trig_i) begin
                count_q <= count_q + 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (sw_req_i) begin
            p_count_o <= count_q;
            count_q <= 0;
        end
    end

endmodule
