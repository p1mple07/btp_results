module Data_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b000,
    parameter DATA_WIDTH         = 4,
    parameter DATA_COUNT         = 4
)
(
    input  wire [DATA_WIDTH * DATA_COUNT -1:0] data_in,
    output reg  [DATA_WIDTH-1:0]        reduced_data_out
);

    generate
        genvar bit_index;

        for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin : bit_processing
            wire [DATA_COUNT-1:0] extracted_bits;

            for (i = 0; i < DATA_COUNT; i = i + 1) begin
                extracted_bits[i] = data_in[bit_index + i * DATA_WIDTH];
            end

            Bitwise_Reduction#(REDUCTION_OP, DATA_COUNT) bit_reduced;
            extracted_bits -> bit_reduced.input_bits;

            wire bit_reduced.reduced_bit [DATA_WIDTH-1:0];

            reduced_data_out[bit_index] = bit_reduced.reduced_bit;
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

    reg temp_result;

    always @(*) begin
        temp_result = input_bits[0];

        for (i = 1; i < BIT_COUNT; i = i + 1) begin
            case (REDUCTION_OP)
                3'b000 : temp_result = temp_result & input_bits[i];
                3'b001 : temp_result = temp_result | input_bits[i];
                3'b010 : temp_result = temp_result ^ input_bits[i];
                3'b011 : temp_result = ~ (temp_result & input_bits[i]);
                3'b100 : temp_result = ~ (temp_result | input_bits[i]);
                3'b101 : temp_result = ~ (temp_result ^ input_bits[i]);
                default : temp_result = temp_result & input_bits[i];
            endcase
        end
    end
endmodule