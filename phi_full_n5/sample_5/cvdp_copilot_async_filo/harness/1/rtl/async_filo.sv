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
    input [DATA_WIDTH-1:0] w_data,   // Data input for push
    output logic [DATA_WIDTH-1:0] r_data,   // Data output for pop
    output logic                  r_empty,  // Empty flag
    output logic                  w_full    // Full flag
);

    logic [DATA_WIDTH-1:0] mem[0:DEPTH-1];

    logic [$clog2(DEPTH):0] w_ptr, r_ptr;  
    logic [$clog2(DEPTH):0] w_count_bin, r_count_bin;  
    logic [$clog2(DEPTH):0] wq2_rptr, rq2_wptr;  

    always_ff @(posedge w_clk or posedge w_rst) begin
        if (w_rst) begin
            w_count_bin <= 0;
            w_ptr       <= 0;
        end else begin 
            if (push && !w_full) begin
                mem[w_ptr] <= w_data;
                w_ptr <= w_ptr + 1;
                w_count_bin <= w_count_bin + 1;
            end
            if (w_count_bin == DEPTH - 1) begin
                w_full <= 1;
            end
        end
    end

    always_ff @(posedge r_clk or posedge r_rst) begin
        if (r_rst) begin
            r_count_bin <= 0;
            r_ptr       <= 0;
        end else begin
            if (pop && !r_empty) begin
                r_data <= mem[r_ptr];
                r_ptr <= r_ptr - 1;
                r_count_bin <= r_count_bin + 1;
            end
            if (r_count_bin == 0) begin
                r_empty <= 1;
            end
        end
    end

    always_ff @(posedge r_clk or posedge r_rst) begin
        if (r_rst) begin
            r_empty <= 1;
        end else begin
            r_empty <= (rq2_wptr == w_ptr);
        end
    end

    always_ff @(posedge w_clk or posedge w_rst) begin
        if (w_rst) begin
            w_full <= 0;
        end else begin
            w_full <= (w_count_bin == DEPTH - 1);
        end
    end

    // Synchronization logic for w_ptr and r_ptr
    always_ff @(posedge w_clk) begin
        wq2_rptr = w_ptr + ~w_ptr;
        rq2_wptr = r_ptr + ~r_ptr;
    end

endmodule
