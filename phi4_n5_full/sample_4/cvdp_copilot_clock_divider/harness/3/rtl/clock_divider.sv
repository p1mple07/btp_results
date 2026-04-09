module clock_divider(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [1:0]   sel,
    output logic         clk_out
);

    // 2-bit counter is sufficient for division factors up to 8.
    reg [1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_out <= 1'b0;
            counter <= 2'b0;
        end else begin
            if (sel == 2'b00) begin
                // Divide by 2: Toggle clk_out on every clock cycle.
                if (counter == 1'b0) begin
                    counter <= 1'b1;
                    clk_out <= ~clk_out;
                end else begin
                    counter <= 1'b0;
                end
            end else if (sel == 2'b01) begin
                // Divide by 4: Toggle clk_out every 2 cycles.
                if (counter == 2'd1) begin
                    counter <= 2'd0;
                    clk_out <= ~clk_out;
                end else begin
                    counter <= counter + 1;
                end
            end else if (sel == 2'b10) begin
                // Divide by 8: Toggle clk_out every 4 cycles.
                if (counter == 2'd3) begin
                    counter <= 2'd0;
                    clk_out <= ~clk_out;
                end else begin
                    counter <= counter + 1;
                end
            end else begin
                // Out-of-range sel: hold clk_out at 0 and reset the counter.
                clk_out <= 1'b0;
                counter <= 2'b0;
            end
        end
    end

endmodule