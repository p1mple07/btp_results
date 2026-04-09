module palindrome_detect #(
    parameter N=3
) (
    input clk,
    input reset,
    input bit_stream,
    output reg palindrome_detected
);

    // Check for palindrome of length 3
    initial begin
        palindrome_detected = 0;
    end

    always @(*) begin
        if (bit_stream.size() >= 3) begin
            for (int i = 0; i < bit_stream.size() - 2; i = i + 1) begin
                if (bit_stream[i] == bit_stream[i + 2]) begin
                    palindrome_detected = 1;
                    break;
                end
            end
        end
    end

endmodule
