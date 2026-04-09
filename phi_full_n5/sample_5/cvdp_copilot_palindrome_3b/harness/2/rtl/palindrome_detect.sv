module palindrome_detect #(
    parameter N=3
) (
    input clk,
    input reset,
    input bit_stream,
    output reg palindrome_detected
);

reg [N-1:0] buffer [0:2**N-1];
reg [N-1:0] read_index;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        palindrome_detected <= 0;
        read_index <= 0;
        buffer <= {N{1'b0}};
    end else begin
        if (reset) begin
            buffer <= {N{1'b0}};
            read_index <= 0;
        end else begin
            buffer <= {buffer[read_index-1], bit_stream} & {N{1'b0}};
            read_index <= read_index + 1;
        end
    end
end

always @(buffer[N-1]) begin
    if (buffer[N-1] == buffer[0]) begin
        palindrome_detected <= 1;
    end else begin
        palindrome_detected <= 0;
    end
end

endmodule
