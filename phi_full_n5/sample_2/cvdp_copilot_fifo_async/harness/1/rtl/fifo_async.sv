module async_fifo #(parameter DATA_WIDTH = 8, parameter DEPTH = 16) (
    input w_clk, w_rst, w_inc,
    input [DATA_WIDTH-1:0] w_data,
    input r_clk, r_rst, r_inc,
    output reg w_full,
    output reg r_empty,
    output [DATA_WIDTH-1:0] r_data
);

    // Local variables
    logic [DEPTH-1:0] write_ptr, read_ptr;
    logic [DEPTH-1:0] sync_write_ptr, sync_read_ptr;
    logic sync_w, sync_r;

    // Cross-clock synchronizers
    always @(posedge r_clk) begin
        sync_write_ptr <= write_ptr;
        sync_r <= read_ptr;
    end
    always @(posedge w_clk) begin
        sync_read_ptr <= read_ptr;
        sync_w <= sync_r;
    end

    // Gray counter for pointers
    always @(posedge w_clk or posedge r_clk) begin
        if (w_inc) begin
            write_ptr <= write_ptr + 1;
            if (write_ptr >= DEPTH) begin
                write_ptr <= 0;
                w_full <= 1;
            end else begin
                w_full <= 0;
            end
        end
        if (r_inc) begin
            read_ptr <= read_ptr + 1;
            if (read_ptr >= DEPTH) begin
                read_ptr <= 0;
                r_empty <= 1;
            end else begin
                r_empty <= 0;
            end
        end
    end

    // Compare pointers and assert flags
    always @(sync_write_ptr, sync_read_ptr) begin
        if (sync_write_ptr == sync_read_ptr) begin
            r_empty <= 1;
        end else begin
            r_empty <= 0;
        end
        if ((sync_write_ptr[DEPTH-1] == sync_read_ptr[DEPTH-1]) &&
            (sync_write_ptr == sync_read_ptr)) begin
            w_full <= 1;
        end else begin
            w_full <= 0;
        end
    end

    // Read operation
    assign r_data = (sync_read_ptr <= DEPTH) ? sync_write_ptr[DATA_WIDTH-1:0] : 1'bz;

endmodule
