module perf_counter #(parameter W = 8) (
    input clk,
    input reset,
    input sw_req_i,
    input cpu_trig_i,
    output reg signed [W-1:0] p_count_o
);

    // Internal register for the counter
    reg [W-1:0] count_reg;

    // Asynchronous reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_reg <= 0;
        end else begin
            if (cpu_trig_i) begin
                count_reg <= count_reg + 1;
            end
        end
    end

    // Software read request
    always @(posedge clk) begin
        if (sw_req_i) begin
            p_count_o <= count_reg;
            count_reg <= 0; // Reset counter after read
        end
    end

endmodule
