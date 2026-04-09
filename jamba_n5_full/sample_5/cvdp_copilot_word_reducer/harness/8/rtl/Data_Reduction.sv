module Bit_Difference_Counter
#(
    parameter BIT_WIDTH = 4,
    parameter COUNT_WIDTH = BIT_WIDTH
)
(
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg [COUNT_WIDTH-1:0] bit_difference_count
);

    reg [BIT_WIDTH-1:0] xor_result;

    always @(*) begin
        xor_result = input_A ^ input_B;
    end

    reg [3:0] temp;
    always @(*) begin
        temp = 0;
        for (int i = 0; i < COUNT_WIDTH; i = i + 1) begin
            if (xor_result[i] == 1) temp += 1;
        end
    end

    assign bit_difference_count = temp;
endmodule
