module fifo_async #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
) (
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

    // Internal signals
    reg [DATA_WIDTH-1:0] fifo_write_data [0:DEPTH-1];
    reg [DATA_WIDTH-1:0] fifo_read_data [0:DEPTH-1];
    reg [DATA_WIDTH-1:0] write_pointer = 0;
    reg [DATA_WIDTH-1:0] read_pointer = 0;
    reg [DATA_WIDTH-1:0] sync_write_pointer = 0;
    reg [DATA_WIDTH-1:0] sync_read_pointer = 0;

    // Cross-clock synchronizers
    always @(posedge r_clk) begin
        sync_write_pointer <= w_write_pointer;
    end
    always @(posedge w_clk) begin
        sync_read_pointer <= r_read_pointer;
    end

    // FIFO logic
    always @(posedge w_clk or posedge w_rst) begin
        if (w_rst) begin
            write_pointer <= 0;
            sync_write_pointer <= 0;
            fifo_write_data <= {DEPTH{1'b0}};
        end else if (w_inc) begin
            if (sync_write_pointer == read_pointer) begin
                w_full <= 1;
                fifo_write_data <= {fifo_write_data[DEPTH-1:0], w_data};
                write_pointer <= write_pointer + 1;
            end else begin
                fifo_write_data <= {fifo_write_data[DEPTH-2:0], w_data};
                write_pointer <= write_pointer + 1;
            end
        end
    end

    always @(posedge r_clk or posedge r_rst) begin
        if (r_rst) begin
            read_pointer <= 0;
            sync_read_pointer <= 0;
            fifo_read_data <= {DEPTH{1'b0}};
        end else if (r_inc) begin
            if (sync_read_pointer == write_pointer) begin
                r_empty <= 1;
                r_data <= fifo_read_data[DEPTH-1:0];
                fifo_read_data <= fifo_read_data {DEPTH-1:0};
                read_pointer <= read_pointer + 1;
            end else if (sync_read_pointer == write_pointer + DEPTH) begin
                r_empty <= 0;
                r_data <= fifo_read_data[DEPTH-1:0];
                fifo_read_data <= {fifo_read_data[DEPTH-2:0], r_data};
                read_pointer <= read_pointer + 1;
            end else begin
                fifo_read_data <= fifo_read_data {DEPTH-1:0};
                read_pointer <= read_pointer + 1;
            end
        end
    end

endmodule
