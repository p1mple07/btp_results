module palindrome_detect #( 
    parameter N=3
) (
    input clk,
    input reset,
    input bit_stream,
    output palindrome_detected
);

    reg [N-1:0] data;
    reg state;
    reg found;
    reg bit_received;

    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            found <= 0;
            bit_received <= 0;
            return;
        end else if (!reset) begin
            state <= 1;
        end

        case (state)
            0: begin
                if (bit_received == 0 && bit_stream) begin
                    bit_received <= 1;
                    data <= {data[N-1:0], bit_stream};
                end else begin
                    bit_received <= 0;
                    data <= 0;
                end
            end

            1: begin
                if (bit_received == 1) begin
                    bit_received <= 0;
                    data <= {data[N-1:0], bit_stream};
                    state <= 2;
                end else begin
                    bit_received <= 1;
                end
            end

            2: begin
                if (bit_received == 0) begin
                    bit_received <= 1;
                    data <= {data[N-1:0], bit_stream};
                    state <= 3;
                end else begin
                    bit_received <= 0;
                    data <= 0;
                end
            end

            3: begin
                found <= (data[0] == data[2]);
                palindrome_detected = found;
            end

        endcase
    end

endmodule
