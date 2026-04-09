module performance_counter #(parameter W = 8) (
    input clk,
    input reset,
    input sw_req_i,
    input cpu_trig_i,
    output reg signed [W-1:0] p_count_o
);

    // Counter storage
    reg signed [W-1:0] count_q;

    // Internal signals
    reg counter_increment_enable;
    reg counter_increment;

    // Internal logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_q <= 0;
            counter_increment_enable <= 0;
        end else begin
            if (counter_increment_enable) begin
                if (cpu_trig_i) begin
                    counter_increment <= 1;
                end else begin
                    counter_increment <= 0;
                end
            end
            count_q <= count_q + counter_increment;
        end
    end

    // Software read logic
    always @(posedge clk) begin
        if (sw_req_i) begin
            p_count_o <= count_q;
            counter_increment_enable <= 0;
        end
    end

endmodule
