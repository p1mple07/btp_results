module Bit_Difference_Counter #(
    parameter BIT_WIDTH = 3,
    parameter COUNT_WIDTH = 4
)(
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg [COUNT_WIDTH-1:0] bit_difference_count
);

    Data_Reduction uut (
        .REDUCTION_OP (3'b000),
        .DATA_WIDTH (DATA_WIDTH),
        .DATA_COUNT (DATA_COUNT)
    );

    assign xor_result = uut.output;

    Bitwise_Reduction ubit (
        .BIT_COUNT (COUNT_WIDTH),
        .REDUCTION_OP (REDUCTION_OP),
        .BIT_COUNT (DATA_COUNT)
    );

    assign bit_difference_count = ubit.get_count();

endmodule
