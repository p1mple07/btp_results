module piso_8bit (
    input clk,
    input rst,
    output reg serial_out
);
    reg [7:0] tmp;

    initial begin
        tmp = 8'b0000_0001; // Initialize tmp to the first pattern
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            serial_out <= 1'b0; // Asynchronous active LOW reset
            tmp <= 8'b0000_0001; // Reset tmp to the first pattern
        end else if (tmp == 8'b1111_1111) begin
            serial_out <= 1'b0; // Shift out the last bit
            tmp <= tmp + 1'b1; // Increment tmp
        end else begin
            serial_out <= tmp[7]; // Output the MSB
            tmp <= {tmp[6:0], 1'b0}; // Shift tmp left, dropping the LSB
        end
    end
endmodule
