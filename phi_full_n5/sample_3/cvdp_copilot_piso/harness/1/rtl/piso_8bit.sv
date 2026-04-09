module piso_8bit (
    input clk,
    input rst,
    output reg serial_out
);
    reg [7:0] tmp;
    integer i;

    initial begin
        tmp = 8'h0001; // Initialize tmp to 0000_0001
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            serial_out <= 1'b0; // Reset serial_out to LOW when reset is active LOW
            tmp <= 8'h0001; // Reset tmp to 0000_0001
        end else if (tmp == 8'hFFFF) begin
            serial_out <= 1'b0; // Keep serial_out LOW until tmp is reset
            tmp <= 8'h0001; // Increment tmp after 8 cycles
        end else begin
            serial_out <= tmp[0]; // Output the LSB of tmp
            tmp <= tmp + 1'b1; // Increment tmp for the next cycle
        end
    end
endmodule
