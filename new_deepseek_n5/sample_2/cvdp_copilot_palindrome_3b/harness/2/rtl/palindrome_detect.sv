module palindrome_detect #( 
parameter N=3
) (
input clk,
input reset,
input bit_stream,
output palindrome_detected
);
    reg first_bit, second_bit, third_bit;
    reg [1] state = 0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            first_bit = 0;
            second_bit = 0;
            third_bit = 0;
            state = 0;
        end else begin
            state = state + 1;
            case (state)
                0: first_bit = 0; second_bit = 0; third_bit = bit_stream;
                1: second_bit = first_bit; third_bit = bit_stream;
                2: first_bit = second_bit; third_bit = bit_stream;
                3: if (first_bit == third_bit) palindrome_detected = 1;
                default: first_bit = second_bit = third_bit = 0;
            endcase
        end
    end
endmodule