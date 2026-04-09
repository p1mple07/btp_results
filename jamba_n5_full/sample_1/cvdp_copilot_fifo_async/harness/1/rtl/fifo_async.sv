module async_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 32
) (
    input w_clk,
    input w_rst,
    input w_inc,
    input w_data,
    input r_clk,
    input r_rst,
    input r_inc,

    output reg w_full,
    output reg r_empty,
    output reg [DATA_WIDTH-1:0] r_data,

    input [DATA_WIDTH-1:0] wr_en, // maybe unused, but we can ignore
    // Instead, we can use w_inc and w_data.
);

// Cross-clock synchronizers
module gray_sync #(
    parameter N = 2
) (
    input wire clk,
    input wire rst,
    input wire new_value,
    output reg gray
);

    always @(*) begin
        if (rst) gray <= 0;
        else if (new_value) gray <= 0;
        else gray <= new_value ^ 1'b0;
    end
endmodule

// Synchronize write pointer from write domain to read domain
assign rd_ptr_sync = gray_sync.inst(.clk(w_clk), .rst(r_rst), .new_value(w_inc), .gray(rd_ptr));

// Synchronize read pointer from read domain to write domain
assign wr_ptr_sync = gray_sync.inst(.clk(r_clk), .rst(r_rst), .new_value(r_inc), .gray(wr_ptr));

// Now we need to check if FIFO is empty or full.

// Empty flag: WRITE_POINTER == READ_POINTER plus one bit overflow.
reg empty;
always @(*) begin
    empty = (wr_ptr == rd_ptr + 1'b1);
end

// Full flag: if read and write pointers cross but all other bits same.
reg full;
always @(*) begin
    full = (wr_ptr == rd_ptr);
end

// Outputs
wire w_full_out = full;
wire r_empty_out = empty;
wire r_data_out = ... ; // need to read data.

// We need to output data when reading.
assign r_data = ... ;

endmodule
