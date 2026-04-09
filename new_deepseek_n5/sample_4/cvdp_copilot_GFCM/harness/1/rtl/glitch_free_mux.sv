module glitch_free_mux (
    input wire [WIDTH-1:0] sel,
    input wire [WIDTH-1:0] rst_n,
    input wire [WIDTH-1:0] clk1,
    input wire [WIDTH-1:0] clk2,
    output wire [WIDTH-1:0] clkout
);

    // Flip-flops for storing the selected clock
    latch q1 (sel, 0, 1, 0) latched on posedge(clk1);
    latch q2 (sel, 0, 1, 0) latched on posedge(clk2);

    // Flip-flops for enabling the selected clock
    latch en1 (sel, 1, 0, 1) latched on posedge(clk1);
    latch en2 (sel, 1, 0, 1) latched on posedge(clk2);

    // Positive edge detectors for clocks
    edge detector edge1 (clk1);
    edge detector edge2 (clk2);

    // Glitch-free switch logic
    always_posedge(clk1) begin
        if (sel == 1) begin
            // Disable current clock (clk1)
            q1.next = 0;
            // Enable new clock (clk2) on its positive edge
            en2.next = 1;
        end else begin
            // Enable current clock (clk1)
            en1.next = 1;
        end
    end

    always_posedge(clk2) begin
        if (sel == 0) begin
            // Disable current clock (clk2)
            q2.next = 0;
            // Enable new clock (clk1) on its positive edge
            en1.next = 1;
        end else begin
            // Enable current clock (clk2)
            en2.next = 1;
        end
    end

    // Reset condition
    always_comb begin
        if (rst_n) begin
            q1.next = 0;
            q2.next = 0;
            en1.next = 0;
            en2.next = 0;
            // Output is low
            clkout.next = 0;
        end
    end

    // Output is selected clock
    always_comb begin
        if (sel) begin
            if (en1) begin
                clkout.next = q1;
            end else begin
                // Fallback to default clock (not shown)
                // clkout.next = 0;
            end
        else begin
            if (en2) begin
                clkout.next = q2;
            end else begin
                // Fallback to default clock (not shown)
                // clkout.next = 0;
            end
        end
    end
endmodule