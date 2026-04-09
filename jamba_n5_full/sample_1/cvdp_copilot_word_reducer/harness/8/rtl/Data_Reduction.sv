module Bit_Difference_Counter #(
    parameter BIT_WIDTH = 4,
    parameter COUNT_WIDTH = 8
) (
    input wire [BIT_WIDTH-1:0] input_A,
    input wire [BIT_WIDTH-1:0] input_B,
    output reg [COUNT_WIDTH-1:0] bit_difference_count
);

(* synthesize *)
    assign xor_result = {BIT_WIDTH{input_A}} ^ {BIT_WIDTH{input_B}};

    bit_difference_count = xor_result.ones();

endmodule
