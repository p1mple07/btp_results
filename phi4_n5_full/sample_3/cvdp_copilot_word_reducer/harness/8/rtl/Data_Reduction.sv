module Bitwise_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b000, // Default operation: AND
    parameter BIT_COUNT          = 4,       // Number of bits to reduce
    parameter USE_SUM             = 0        // When 1, perform popcount (sum) reduction
)
(
    input  wire [BIT_COUNT-1:0] input_bits,
    // When USE_SUM is 1, output width is enough to hold the sum (popcount)
    // Otherwise, output is 1 bit.
    output reg [((USE_SUM) ? $clog2(BIT_COUNT+1) : 1)-1:0] reduced_bit
);

    // Determine output width based on mode
    localparam RESULT_WIDTH = (USE_SUM) ? $clog2(BIT_COUNT+1) : 1;

    // Reduction Operation Codes
    localparam [2:0] AND_OP  = 3'b000;
    localparam [2:0] OR_OP   = 3'b001;
    localparam [2:0] XOR_OP  = 3'b010;
    localparam [2:0] NAND_OP = 3'b011;
    localparam [2:0] NOR_OP  = 3'b100;
    localparam [2:0] XNOR_OP = 3'b101;
    localparam [2:0] SUM_OP  = 3'b110; // New operation code for popcount (sum)

    integer i;
    // For non-sum operations, we use a temporary result of 1 bit.
    reg temp_result;