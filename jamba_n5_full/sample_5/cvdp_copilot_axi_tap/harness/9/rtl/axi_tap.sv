localparam TIMEOUT_COUNTER = 32'd1000000; // arbitrary large value
localparam TIMEOUT_THRESHOLD = 1000;        // in cycles
localparam CYCLE_TIME = 5;                   // time unit for simulation

always @(posedge clk_i or negedge rst_i) begin
    if (rst_i) begin
        tx_timeout_timer <= 0;
        timeout_flag <= 1'b0;
    end else
        tx_timeout_timer <= tx_timeout_timer + CYCLE_TIME;
end
