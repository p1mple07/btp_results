module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 8
)(
    input w_clk,
    input w_rst,
    input push,
    input r_rst,
    input r_clk,
    input r_clk_deasserted,  // maybe not needed? but spec uses r_rst
    input pop,
    input w_data,
    output reg [DATA_WIDTH-1:0] r_data,
    output reg w_full,
    output reg r_empty
);

    // Internal signals
    reg [DATA_WIDTH-1:0] mem[DEPTH-1:0];
    reg [DATA_WIDTH-1:0] w_ptr;
    reg [DATA_WIDTH-1:0] r_ptr;
    reg wq1_rptr;
    reg wq2_rptr;
    reg rq1_wptr;
    reg rq2_wptr;
    reg [DATA_WIDTH-1:0] prev_w_ptr;
    reg [DATA_WIDTH-1:0] prev_r_ptr;

    // Counters
    integer counter;
    logic empty, full;

    // Initialization
    initial begin
        counter = 0;
        empty = 1;
        full = 0;

        w_rst = 1;
        r_rst = 1;
        push = 0;
        pop = 0;
        w_data = 0;

        // Reset behavior
        w_rst <= 1; // default reset
        r_rst <= 1;

        always @(posedge w_clk or posedge r_clk) begin
            if (w_rst) begin
                w_ptr <= 0;
                w_full <= 0;
                r_ptr <= 0;
                r_empty <= 1;
                full <= 0;
                counter = 0;
            end else if (r_rst) begin
                r_ptr <= 0;
                r_full <= 0;
                w_ptr <= 0;
                w_full <= 0;
                prev_w_ptr <= 0;
                prev_r_ptr <= 0;
            end
        end
    end

    // Push operation
    always @(posedge w_clk or negedge r_clk) begin
        if (w_rst || r_rst) begin
            // Both domains reset: ignore
        end else begin
            if (push && !full) begin
                // Write operation
                if (w_full) begin
                    w_full <= 0;
                    w_ptr <= w_ptr ^ 1;
                    mem[w_ptr] <= w_data;
                end else begin
                    w_ptr <= w_ptr + 1 mod DEPTH;
                    mem[w_ptr] <= w_data;
                end
                counter++;
                full = (counter == DEPTH);
                empty = 0;
            end
        end
    end

    // Pop operation
    always @(posedge r_clk or negedge w_clk) begin
        if (r_rst || w_rst) begin
            // Both domains reset: ignore
        end else begin
            if (pop && !empty) begin
                // Read operation
                if (r_full) begin
                    r_ptr <= r_ptr ^ 1;
                    mem[r_ptr] <= r_data;
                    r_data <= mem[r_ptr];
                end else begin
                    r_ptr <= r_ptr + 1 mod DEPTH;
                    r_data <= mem[r_ptr];
                end
                counter--;
                r_empty = (counter == 0);
                full = 0;
            end
        end
    end

    // Output
    assign r_data = mem[r_ptr];
    assign w_full = w_full;
    assign r_empty = r_empty;

endmodule
