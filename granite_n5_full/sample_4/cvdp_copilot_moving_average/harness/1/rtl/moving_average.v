module moving_average(
    input wire clk,
    input wire reset,
    input wire [11:0] data_in,
    output reg [11:0] data_out
);

reg [11:0] sum;
integer count = 0;

always @(posedge clk) begin
    if (reset) begin
        sum <= 0;
        count <= 0;
    end else begin
        sum <= {sum[10:0], data_in}; // shift left by 1 bit
        count <= count + 1;
        
        if (count == 8) begin
            data_out <= sum / 8; // divide the sum by 8
            count <= 0;
        end
    end
end

endmodule