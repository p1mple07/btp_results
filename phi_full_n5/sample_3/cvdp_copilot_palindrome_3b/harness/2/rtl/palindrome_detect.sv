module palindrome_detect #(
parameter N=3
) (
input clk,
input reset,
input [N-1:0] bit_stream,
output reg palindrome_detected
);

reg [N-1:0] buffer[0:N-1];
reg [N-1:0] palindrome;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        buffer <= {N{1'b0}};
        palindrome <= 0;
        palindrome_detected <= 0;
    end else begin
        buffer <= {buffer[N-2:0], bit_stream};
        palindrome <= buffer[N-1:0];
        if (buffer[0] == palindrome) begin
            palindrome_detected <= 1;
        end else begin
            palindrome_detected <= 0;
        end
    end
end

endmodule
