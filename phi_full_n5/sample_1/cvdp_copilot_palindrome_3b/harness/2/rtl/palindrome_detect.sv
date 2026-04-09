module palindrome_detect #(
    parameter N=3
) (
    input clk,
    input reset,
    input bit_stream,
    output reg palindrome_detected
);

    reg [N-1:0] buffer [0:2**N-1]; // Buffer to store N bits
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            palindrome_detected <= 0;
            for (i = 0; i < 2**N; i = i + 1) begin
                buffer[i] <= 0;
            end
        end else if (reset == 0) begin
            palindrome_detected <= 0;
            for (i = 0; i < 2**N; i = i + 1) begin
                buffer[i] <= bit_stream;
            end
        end

        if (buffer[2**N-1] == buffer[2**N-N-1]) begin
            palindrome_detected <= 1;
        end else begin
            palindrome_detected <= 0;
        end
    end

endmodule
