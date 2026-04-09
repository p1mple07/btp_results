module Data_Reduction
    (
        input  wire [TOTAL_INPUT_WIDTH-1:0] data_in,
        output reg  [DATA_WIDTH-1:0]        reduced_data_out
    );

    localparam [2:0] REDUCTION_OP = 3'b000;
    localparam DATA_WIDTH         = 4;
    localparam DATA_COUNT         = 4;
    localparam TOTAL_INPUT_WIDTH  = DATA_WIDTH * DATA_COUNT;

    generate
        genvar bit_index;

        for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin : bit_processing
            wire [DATA_COUNT-1:0] extracted_bits;

            for (bit_idx = 0; bit_idx < DATA_COUNT; bit_idx = bit_idx + 1) begin
                extracted_bits[bit_idx] = data_in[bit_idx][bit_index];
            end

            assign reduced_data_out[bit_index] = bitwise_reduction(extracted_bits, REDUCTION_OP);
        end
    endgenerate

endmodule

module Bitwise_Reduction
    (
        input  wire [BIT_COUNT-1:0] input_bits,
        output reg  reduced_bit
    );

    localparam [2:0] REDUCTION_OP = 3'b000;
    localparam BIT_COUNT          = 4;

    always @(*) begin
        if (REDUCTION_OP == 3'b000) begin // AND
            reduced_bit = input_bits[0];
        end else if (REDUCTION_OP == 3'b001) begin // OR
            reduced_bit = ~~input_bits[0];
        end else if (REDUCTION_OP == 3'b010) begin // XOR
            reduced_bit = input_bits[0] ^ input_bits[1];
        end else if (REDUCTION_OP == 3'b011) begin // NAND
            reduced_bit = ~(input_bits[0] & input_bits[1]);
        end else if (REDUCTION_OP == 3'b100) begin // NOR
            reduced_bit = ~(input_bits[0] | input_bits[1]);
        end else if (REDUCTION_OP == 3'b101) begin // XNOR
            reduced_bit = ~(input_bits[0] ^ input_bits[1]);
        end else begin
            reduced_bit = input_bits[0];
        end
    end
endmodule
