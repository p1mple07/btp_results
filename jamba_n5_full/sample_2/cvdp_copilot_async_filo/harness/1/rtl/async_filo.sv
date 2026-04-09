module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 8
)(
    input         w_clk,    // Write clock
    input         w_rst,    // Write reset
    input         push,     // Push signal
    input         r_rst,    // Read reset
    input         r_clk,    // Read clock
    input        [DATA_WIDTH-1:0] w_data,   // Data input for push
    output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
    output logic                  r_empty,  // Empty flag
    output logic                  w_full    // Full flag
);

    logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];

    logic [$clog2(DEPTH):0] w_ptr, r_ptr;   // Word pointers
    logic [$clog2(DEPTH):0] w_count_bin, r_count_bin;
    logic [$clog2(DEPTH):0] wq2_rptr, rq2_wptr;

    always_ff @(posedge w_clk, posedge w_rst) begin
        if (w_rst) begin
            w_count_bin <= 0;
            w_ptr       <= 0;
        end else begin
            // Push logic
            if (push && !w_full) begin
                mem[w_ptr] = w_data;
                w_ptr = w_ptr + 1;
                wq2_rptr = w_ptr ^ (1'b1 << w_cnt);
            end
        end
    end

    always_ff @(posedge r_clk, posedge r_rst) begin
        if (r_rst) begin
            r_count_bin <= 0;
            r_ptr       <= 0;
        end else begin
            // Pop logic
            if (pop && !w_empty) begin
                r_data = mem[r_ptr];
                r_ptr = r_ptr - 1;
                rq2_wptr = r_ptr ^ (1'b1 << r_cnt);
            end
        end
    end

    always_ff @(posedge r_clk or posedge r_rst) begin
        if (r_rst) begin
            r_empty <= 1;
        end else begin
            r_empty <= w_ptr == r_ptr;
        end
    end

    always_ff @(posedge w_clk or posedge w_rst) begin
        if (w_rst) begin
            w_full <= 0;
        end else begin
            w_full <= w_ptr == DEPTH - 1;
        end
    end

    always_ff @(posedge r_clk or posedge r_rst) begin
        if (r_rst) begin
            r_full <= 0;
        end else begin
            r_full <= r_ptr == 0;
        end
    end

endmodule
