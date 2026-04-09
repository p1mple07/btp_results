module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 8
) (
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

    logic [$clog2(DEPTH):0] w_ptr, r_ptr;  
    logic [$clog2(DEPTH):0] w_count_bin, r_count_bin;  
    logic [$clog2(DEPTH):0] wq2_rptr, rq2_wptr;  

    // Write operation on rising edge of w_clk
    always_ff @(posedge w_clk) begin
        if (w_rst) begin
            w_count_bin <= 0;
            w_ptr <= 0;
        end else begin
            if (push) begin
                if (!w_full) begin
                    w_ptr <= w_ptr + 1;
                    w_count_bin <= w_count_bin + 1;
                end
            end
        end
    end

    // Read operation on rising edge of r_clk
    always_ff @(posedge r_clk) begin
        if (r_rst) begin
            r_count_bin <= 0;
            r_ptr <= 0;
        end else begin
            if (!pop) begin
                r_ptr <= r_ptr - 1;
            end
        end
    end

    // Synchronisation between clock domains
    always_ff @(posedge r_clk or posedge r_rst) begin
        if (r_rst) begin
            r_empty <= 1;
        end else begin
            if (r_ptr == wq2_rptr) begin
                r_empty <= 1;
            end else
                r_empty <= 0;
        end
    end

    // Full flag on reaching buffer capacity
    always_ff @(posedge w_clk or posedge w_rst) begin
        if (w_rst) begin
            w_full <= 0;
        end else begin
            if (w_count_bin == DEPTH) begin
                w_full <= 1;
            end else
                w_full <= 0;
        end
    end

    // Empty flag when write pointer matches the read pointer
    assign r_empty = r_ptr == wq2_rptr;

    // Output the data from the most recently pushed element
    assign r_data = mem[r_ptr];

endmodule
