module fifo_async #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 16
)(
    input wire w_clk,
    input wire w_rst,
    input wire w_inc,
    input wire [DATA_WIDTH-1:0] w_data,
    input wire r_clk,
    input wire r_rst,
    input wire r_inc,
    output reg w_full,
    output reg r_empty,
    output reg [DATA_WIDTH-1:0] r_data
);

    reg [DATA_WIDTH-1:0] write_ptr, read_ptr;
    reg [DATA_WIDTH-1:0] write_ptr_sync, read_ptr_sync;

    // Cross-clock synchronizers
    always @(posedge w_clk) begin
        write_ptr_sync <= write_ptr;
    end
    always @(posedge r_clk) begin
        read_ptr_sync <= read_ptr;
    end

    // Gray counter for pointer synchronization
    localparam Gray_Inc = 2'b10;
    reg [DATA_WIDTH-1:0] gray_counter_write, gray_counter_read;

    // Initialize pointers and counters
    initial begin
        write_ptr_sync = 0;
        read_ptr_sync = 0;
        gray_counter_write = 0;
        gray_counter_read = 0;
    end

    // Write operations
    always @(posedge w_clk or posedge w_rst) begin
        if (w_rst) begin
            write_ptr_sync <= 0;
            gray_counter_write <= Gray_Inc;
        end else if (w_inc) begin
            write_ptr_sync <= gray_counter_write;
            gray_counter_write <= Gray_Inc;
        end
    end

    // Read operations
    always @(posedge r_clk or posedge r_rst) begin
        if (r_rst) begin
            read_ptr_sync <= 0;
            gray_counter_read <= Gray_Inc;
        end else if (r_inc) begin
            read_ptr_sync <= gray_counter_read;
            gray_counter_read <= Gray_Inc;
        end
    end

    // Check if FIFO is empty or full
    always @(*) begin
        r_empty = (read_ptr_sync == write_ptr_sync);
        w_full = (write_ptr_sync[DATA_WIDTH-1] != read_ptr_sync[DATA_WIDTH-1]) &&
                 (write_ptr_sync == read_ptr_sync) &&
                 (write_ptr_sync == DEPTH - 1);
    end

    // Read data from FIFO
    always @(posedge r_clk) begin
        if (!r_empty) begin
            r_data = fifo_memory[read_ptr_sync];
            read_ptr_sync <= read_ptr_sync + 1;
        end
    end

    // Write data to FIFO
    always @(posedge w_clk) begin
        if (!w_full) begin
            fifo_memory[write_ptr_sync] = w_data;
            write_ptr_sync <= write_ptr_sync + 1;
        end
    end

    // FIFO memory array
    reg [DATA_WIDTH-1:0] fifo_memory [DEPTH-1:0];

endmodule
