module async_fifo (
    input wire w_clk,
    input wire w_rst,
    input wire w_inc,
    input wire w_data,
    input wire r_clk,
    input wire r_rst,
    input wire r_inc,

    output reg w_full,
    output reg r_empty,
    output reg [DATA_WIDTH-1:0] r_data,
    output reg [DEPTH-1:0] w_ptr,
    output reg [DEPTH-1:0] r_ptr
);

    // Internal state variables
    reg [DEPTH-1:0] w_ptr_gray;
    reg [DEPTH-1:0] r_ptr_gray;

    // Cross-clock synchronizers
    module sync_reg (input wire clk, input wire rst, input wire en, input wire value, output reg out);
        always @(posedge clk or posedge rst) begin
            if (rst)
                out <= 32'd0;
            else if (en)
                out <= value;
            else
                out <= value ^ 1;
        end
    endmodule

    // Write pointer
    assign w_ptr_next = w_ptr_gray ^ 1;
    assign w_ptr_gray <= w_ptr_next.shift_by(1);
    assign w_ptr_gray <= w_ptr_gray.invert();

    // Read pointer
    assign r_ptr_next = r_ptr_gray ^ 1;
    assign r_ptr_gray <= r_ptr_next.shift_by(1);
    assign r_ptr_gray <= r_ptr_gray.invert();

    // Compare pointers with cross-clock synchronizers
    assign w_ptr_compare = (w_ptr_gray == r_ptr_gray);
    assign r_ptr_compare = (r_ptr_gray == w_ptr_gray);

    // Full and empty flags
    assign w_full = !w_ptr_compare && w_ptr_current == r_ptr_current;
    assign r_empty = !r_ptr_compare && w_ptr_current == r_ptr_current;

    // Data outputs
    assign r_data = w_ptr_gray ^ r_ptr_gray;
    assign w_ptr = w_ptr_next;
    assign r_ptr = r_ptr_next;

    // Registers for Gray counters
    reg [DEPTH-1:0] w_ptr_current;
    reg [DEPTH-1:0] r_ptr_current;

    initial begin
        w_ptr_current = 32'd0;
        r_ptr_current = 32'd0;
        forever #5 w_clk;
    end

endmodule
