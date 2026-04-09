module Data_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b000,
    parameter DATA_WIDTH         = 4,
    parameter DATA_COUNT         = 4,
    localparam TOTAL_INPUT_WIDTH = DATA_WIDTH * DATA_COUNT
)
(
    input  wire [TOTAL_INPUT_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0]        reduced_data_out
);

    generate
        genvar bit_index;

        for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin : bit_processing
            wire [DATA_COUNT-1:0] extracted_bits;

            for (i = 0; i < DATA_COUNT; i = i + 1) begin
                extracted_bits[i] = data_in[bit_index + i * DATA_WIDTH];
            end

            Bitwise_Reduction #(.bit_count(DATA_COUNT), .op(REDUCTION_OP)) (extracted_bits, reduced_data_out[bit_index]);
        end
    endgenerate

endmodule


module Bitwise_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b000,
    parameter BIT_COUNT          = 4
)
(
    input  wire [BIT_COUNT-1:0] input_bits,
    output reg                  reduced_bit
);

    localparam [2:0] AND_OP  = 3'b000;
    localparam [2:0] OR_OP   = 3'b001;
    localparam [2:0] XOR_OP  = 3'b010;
    localparam [2:0] NAND_OP = 3'b011;
    localparam [2:0] NOR_OP  = 3'b100;
    localparam [2:0] XNOR_OP = 3'b101;

    reg temp_result;

    always @(*) begin
        temp_result = input_bits[0];

        for (i = 1; i < BIT_COUNT; i = i + 1) begin
            case (REDUCTION_OP)
                AND_OP, NAND_OP  : temp_result = temp_result & input_bits[i];
                OR_OP,  NOR_OP   : temp_result = temp_result | input_bits[i];
                XOR_OP, XNOR_OP  : temp_result = temp_result ^ input_bits[i];
                default          : temp_result = temp_result & input_bits[i];
            endcase
        end

        reduced_bit = temp_result;
    end
endmodule