module palindrome_detect #(
    parameter N=3
) (
    input clk,
    input reset,
    input bit_stream,
    output reg palindrome_detected
);

    reg [N-1:0] first_bit, second_bit, third_bit;
    reg [N-1:0] current_bit;
    reg [N-1:0] temp;

    initial begin
        first_bit <= 0;
        second_bit <= 0;
        third_bit <= 0;
        palindrome_detected <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            first_bit <= 0;
            second_bit <= 0;
            third_bit <= 0;
            palindrome_detected <= 0;
        end else begin
            current_bit <= bit_stream;
            if (current_bit == first_bit) begin
                palindrome_detected <= 1;
            end else begin
                palindrome_detected <= 0;
            end
            second_bit <= first_bit;
            first_bit <= second_bit;
            third_bit <= current_bit;
        end
    end

endmodule
