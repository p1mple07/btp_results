module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 8
  ) (
    input                         w_clk,    // Write clock
    input                         w_rst,    // Write reset
    input                         push,     // Push signal
    input                         r_rst,    // Read reset
    input                         r_clk,    // Read clock
    input                         pop,      // Pop signal
    input        [DATA_WIDTH-1:0] w_data,   // Data input for push
    output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
    output logic                  r_empty,  // Empty flag
    output logic                  w_full    // Full flag
  );

    logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];
    logic [$clog2(DEPTH):0] w_ptr, r_ptr;  
    logic [$clog2(DEPTH):0] w_count_bin, r_count_bin;  
    logic [$clog2(DEPTH):0] wq2_rptr, rq2_wptr;  

    always_ff @(posedge w_clk, posedge w_rst) begin
        if (w_rst) begin
            w_count_bin <= 0;
            w_ptr       <= 0;
        end else begin
            if (push) begin
                if (w_count_bin < DEPTH) begin
                    mem[w_ptr] <= w_data;
                    w_ptr       <= w_ptr + 1;
                    w_count_bin <= w_count_bin + 1;
                end
            end
        end
    end

    always_ff @(posedge r_clk, posedge r_rst) begin
        if (r_rst) begin
            r_count_bin <= 0;
            r_ptr       <= 0;
        end else begin
            if (pop) begin
                if (r_count_bin > 0) begin
                    r_data <= mem[r_ptr];
                    r_ptr       <= r_ptr - 1;
                    r_count_bin <= r_count_bin - 1;
                end
            end
        end
    end

    always_ff @(posedge r_clk or posedge r_rst) begin
        if (r_rst) begin
            r_empty <= 1;
        else begin
            r_empty <= (r_count_bin == rq2_wptr);
        end
    end

    always_ff @(posedge w_clk or posedge w_rst) begin
        if (w_rst) begin
            w_full <= 0;
        else begin
            w_full <= (w_count_bin == DEPTH);
        end
    end

    // Synchronization code
    always_ff @* begin
        wq2_rptr <= w_ptr ^ (w_ptr >> 1);
        rq2_wptr <= r_ptr ^ (r_ptr >> 1);
    end