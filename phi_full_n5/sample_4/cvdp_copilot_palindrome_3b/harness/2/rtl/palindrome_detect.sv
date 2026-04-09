module palindrome_detect #(
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output reg palindrome_detected
);

reg [N-1:0] buffer [0:N-1]; // Buffer to store the incoming bit stream
reg [N-1:0] palindrome;     // Register to store the current palindrome

always @(posedge clk or posedge reset) begin
    if (reset) begin
        palindrome <= {N{1'b0}}; // Reset the palindrome register
        buffer <= {N{1'b0}};     // Reset the buffer
        palindrome_detected <= 0; // Reset the output
    end else begin
        buffer <= {buffer[N-2:0], bit_stream}; // Shift buffer and add new bit
        palindrome <= buffer[N-1:0]; // Update palindrome register
        // Check if the current buffer forms a palindrome
        if (buffer[N-1] == buffer[0]) begin
            palindrome_detected <= 1; // Palindrome detected
        end else begin
            palindrome_detected <= 0; // No palindrome detected
        end
    end
end

endmodule
