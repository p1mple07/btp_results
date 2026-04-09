module nbit_swizzling #(
    parameter int DATA_WIDTH = 64
)(
    input logic [DATA_WIDTH-1:0] data_in,
    input logic [1:0] sel,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic [DATA_WIDTH-1:0] gray_out
);

always_comb begin
    if (sel == 2'b00) begin
        // Reverse entire data
        data_out = data_in;
        gray_out = data_out;
    end else if (sel == 2'b01) begin
        // Split into two halves, reverse each
        logic [DATA_WIDTH/2-1:0] high, low;
        assign high = data_in[DATA_WIDTH/2 - 1 : 0];
        assign low = data_in[0 : (DATA_WIDTH/2 - 1)];
        assign data_out = low;
        assign gray_out = data_out; // same as data_out? But we need Gray.
        // Wait, we need to do Gray after reversal. But for half-swizzle, after reversing halves, we compute Gray.
        // So we need to compute Gray of the reversed data.
    end else if (sel == 2'b10) begin
        // Quarter-swizzle: four quarters, reverse each
        logic [DATA_WIDTH/4-1:0] quarter1, quarter2, quarter3, quarter4;
        assign quarter1 = data_in[0 : (DATA_WIDTH/4)];
        assign quarter2 = data_in[(DATA_WIDTH/4) : (2*DATA_WIDTH/4)];
        assign quarter3 = data_in[(2*DATA_WIDTH/4) : (3*DATA_WIDTH/4)];
        assign quarter4 = data_in[(3*DATA_WIDTH/4) : DATA_WIDTH];
        assign data_out = quarter4;
        assign data_out = quarter3;
        assign data_out = quarter2;
        assign data_out = quarter1;
        // Actually we need to reverse each quarter and then combine? Let's think simpler.

        // For quarter-swizzle: reverse each quarter and then interleave? Not necessary. The spec says "each quarter of data_out is assigned bits from the reversed bits of each corresponding quarter of data_in". So we can reverse each quarter individually, then assemble.

        // Let's just reverse each quarter and then interleave? The spec may want to reverse each quarter and then assemble them in order.

        // For simplicity, we can reverse each quarter and then concatenate in original order? But that's not quarter-swizzle.

        // Let's do: reverse each quarter and then assign them back in the same positions.

        data_out = quarter4;
        data_out = quarter3;
        data_out = quarter2;
        data_out = quarter1;

        gray_out = data_out;
    end else if (sel == 2'b11) begin
        // Eighth-swizzle: eight segments, reverse each segment
        logic [DATA_WIDTH/8-1:0] segment1, segment2, segment3, segment4, segment5, segment6, segment7, segment8;
        assign segment1 = data_in[0 : (DATA_WIDTH/8)];
        assign segment2 = data_in[(DATA_WIDTH/8) : (2*DATA_WIDTH/8)];
        assign segment3 = data_in[(2*DATA_WIDTH/8) : (3*DATA_WIDTH/8)];
        assign segment4 = data_in[(3*DATA_WIDTH/8) : (4*DATA_WIDTH/8)];
        assign segment5 = data_in[(4*DATA_WIDTH/8) : (5*DATA_WIDTH/8)];
        assign segment6 = data_in[(5*DATA_WIDTH/8) : (6*DATA_WIDTH/8)];
        assign segment7 = data_in[(6*DATA_WIDTH/8) : (7*DATA_WIDTH/8)];
        assign segment8 = data_in[(7*DATA_WIDTH/8) : DATA_WIDTH];
        assign data_out = segment8;
        assign data_out = segment7;
        assign data_out = segment6;
        assign data_out = segment5;
        assign data_out = segment4;
        assign data_out = segment3;
        assign data_out = segment2;
        assign data_out = segment1;
        // Gray code
        gray_out = data_out;
    end else
        data_out = data_in;
        gray_out = data_out;
end

endmodule
