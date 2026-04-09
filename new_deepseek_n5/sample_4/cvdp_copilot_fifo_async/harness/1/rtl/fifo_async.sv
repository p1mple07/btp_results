module rtl/fifo_async (
    parameter integer DATA_WIDTH,
    parameter integer DEPTH,
    input wire w_clk,
    input wire w_rst,
    input wire w_inc,
    input wire w_data,
    input wire r_clk,
    input wire r_rst,
    input wire r_inc,
    output wire w_full,
    output wire r_empty,
    output wire r_data
);

    integer w_ptr, r_ptr;
    integer w_ptr_sync, r_ptr_sync;
    integer w_ptr_sync_1, r_ptr_sync_1;

    // FIFO size is depth + 1 to handle overflow
    integer FIFO_SIZE = DEPTH + 1;

    // State machine to handle full/empty states
    integer state = 0;

    // Always block for write operation
    always @(w_data, w_inc, w_rst, w_clk) begin
        if (w_rst) w_ptr = 0;
        else if (w_inc && !w_full) begin
            w_ptr = (w_ptr + 1) % FIFO_SIZE;
            // Check for overflow
            if (w_ptr == 0 && w_ptr == r_ptr) w_full = 1;
            w_ptr_sync = w_ptr;
            w_data;
        end
    end

    // Always block for read operation
    always @(r_data, r_inc, r_rst, r_clk) begin
        if (r_rst) r_ptr = 0;
        else if (r_inc && !r_empty) begin
            r_ptr = (r_ptr + 1) % FIFO_SIZE;
            // Check for underflow
            if (r_ptr == w_ptr) r_empty = 1;
            r_ptr_sync = r_ptr;
            r_data = w_data;
        end
    end

    // Synchronization between write and read pointers
    always w_ptr_sync_1 = w_ptr_sync;
    always r_ptr_sync_1 = r_ptr_sync;

    // Cross-clock synchronizers
    integer w_ptr_sync_reg, r_ptr_sync_reg;
    integer r_ptr_sync_reg, w_ptr_sync_reg;

    initial begin
        $display("Testing FIFO...");
        // Test bench code here
    end

endmodule