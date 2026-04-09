module Bit_Difference_Counter (
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg bit_difference_count [COUNT_WIDTH-1:0]
);

    wire [BIT_WIDTH-1:0] xor_result = input_A ^ input_B;

    integer cnt;
    always @(*) begin
        cnt = 0;
        for (int i = 0; i < BIT_WIDTH; i = i + 1) begin
            if (xor_result[i] == 1'b1) begin
                cnt += 1;
            end
        end
    end

    assign bit_difference_count = {cnt};

endmodule
