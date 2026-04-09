module palindrome_detect #( 
    parameter N=3
) (
    input clk,
    input reset,
    input bit_stream,
    output palindrome_detected
);

    wire prev_prev;
    wire prev;
    wire curr;

    always @(posedge clk or posedge reset) begin
        if (reset)
            prev_prev <= 0;
            prev <= 0;
            curr <= 0;
        else
            prev_prev <= prev;
            prev <= curr;
            curr <= bit_stream;
        end
    end

    assign palindrome_detected = (curr == prev_prev);

endmodule
