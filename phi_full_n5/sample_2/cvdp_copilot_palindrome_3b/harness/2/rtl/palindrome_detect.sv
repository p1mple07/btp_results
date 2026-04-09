module palindrome_detect #(
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output reg palindrome_detected
);

reg [N-1:0] buffer [0:N-1];
reg [N-1:0] expected_palindrome;
integer index;

always @(posedge clk) begin
    if (reset) begin
        buffer <= {N{1'b0}};
        palindrome_detected <= 0;
    end else begin
        buffer[N-1] <= bit_stream;
        expected_palindrome <= buffer;
        
        for (index = 0; index < N-1; index = index + 1) begin
            if (buffer[index] !== buffer[N-2-index]) begin
                palindrome_detected <= 0;
                break;
            end
        end
        
        if (index == N-1) begin
            palindrome_detected <= 1;
        end
    end
end

endmodule
