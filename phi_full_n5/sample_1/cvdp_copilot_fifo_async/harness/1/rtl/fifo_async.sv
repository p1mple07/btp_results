module fifo_async #(
    parameter DATA_WIDTH = 8,
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

    reg [DATA_WIDTH-1:0] write_ptr;
    reg [DATA_WIDTH-1:0] read_ptr;
    wire sync_w_rst, sync_r_rst;
    wire sync_w_clk, sync_r_clk;

    // Cross-clock synchronizers
    always @(posedge sync_w_clk) begin
        sync_r_rst <= w_rst;
        write_ptr <= 0;
    end
    always @(posedge sync_r_clk) begin
        sync_w_rst <= r_rst;
        read_ptr <= 0;
    end

    // Gray counter for write pointer
    always @(posedge w_clk) begin
        if (w_inc) begin
            if (write_ptr == DEPTH-1) begin
                write_ptr <= 0;
            end else begin
                write_ptr <= write_ptr + 1;
            end
        end
    end

    // Gray counter for read pointer
    always @(posedge r_clk) begin
        if (r_inc) begin
            if (read_ptr == 0) begin
                read_ptr <= DEPTH-1;
            end else begin
                read_ptr <= read_ptr - 1;
            end
        end
    end

    // Output flags
    assign w_full = (write_ptr == read_ptr);
    assign r_empty = (write_ptr == read_ptr);

    // FIFO read and write logic
    assign r_data = (read_ptr != DEPTH) ? read_mem[read_ptr] : 1'bz;

    // FIFO memory
    reg [DATA_WIDTH-1:0] read_mem [DEPTH-1:0];

    always @(posedge sync_w_clk) begin
        if (sync_r_rst) begin
            read_mem[read_ptr] <= 1'bz;
        end else if (w_inc) begin
            if (write_ptr < DEPTH-1) begin
                read_mem[read_ptr] <= w_data;
                write_ptr <= write_ptr + 1;
            end
        end
    end

    always @(posedge sync_r_clk) begin
        if (sync_w_rst) begin
            read_mem[read_ptr] <= 1'bz;
        end else if (r_inc) begin
            if (read_ptr > 0) begin
                r_data <= read_mem[read_ptr - 1];
                read_ptr <= read_ptr - 1;
            end
        end
    end

endmodule
