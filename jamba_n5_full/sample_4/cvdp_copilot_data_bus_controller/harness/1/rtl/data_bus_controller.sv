localparam AFINITY = 0;

...

always @(posedge clk) begin
    if (!rst_n) begin
        m0_ready <= 0;
        m1_ready <= 0;
        m0_valid <= 0;
        m1_valid <= 0;
        s_ready <= 0;
        s_valid <= 0;
        s_data <= 0;
    end else begin
        // read inputs
        m0_ready = ...;
        m1_ready = ...;
        m0_valid = ...;
        m1_valid = ...;
        s_ready = ...;
        s_valid = ...;
        s_data = ...;
    end
end
