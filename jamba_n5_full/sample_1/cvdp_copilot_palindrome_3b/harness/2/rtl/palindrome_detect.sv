module palindrome_detect #(
    parameter N=3
) (
    input clk,
    input reset,
    input bit_stream,
    output reg palindrome_detected
);

    initial begin
        palindrome_detected = 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            palindrome_detected = 0;
        end else begin
            integer i;
            for (i = 0; i < N - 2; i = i + 1) begin
                if (bit_stream[i] == bit_stream[i + 2]) begin
                    palindrome_detected = 1;
                    break;
                end
            end
        end
    end

endmodule
