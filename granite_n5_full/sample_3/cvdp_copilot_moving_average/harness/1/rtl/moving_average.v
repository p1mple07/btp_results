module moving_average(
    input wire clk,
    input wire reset,
    input wire [11:0] data_in,
    output reg [11:0] data_out
);

// Internal variables
reg [11:0] sum;
reg [3:0] count;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        sum <= 0;
        count <= 0;
    end else begin
        sum <= {sum[9:0], data_in};
        count <= count == 7? 0 : count + 1;

        if (count == 8)
            data_out <= sum / 8;
    end
end

endmodule