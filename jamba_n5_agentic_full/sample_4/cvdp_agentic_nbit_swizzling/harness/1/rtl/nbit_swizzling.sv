module nbit_swizzling #(
    parameter INT DEFAULT_DATA_WIDTH = 64
)(
    input logic [DATA_WIDTH-1:0] data_in,
    input logic [1:0] sel,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic [DATA_WIDTH-1:0] gray_out
);

    // Determine the reversed data based on sel value
    case (sel)
        2'b00: // Reverse entire data
            data_out = data_in[DATA_WIDTH-1:0] reversed;
            gray_out = data_out;

        2'b01: // Half-swizzle
            logic [DATA_WIDTH/2 - 1:0] low, [DATA_WIDTH/2:DATA_WIDTH - 1] high;
            low = data_in[:DATA_WIDTH/2];
            high = data_in[DATA_WIDTH/2:DATA_WIDTH];
            data_out = high[DATA_WIDTH/2:0] | low[DATA_WIDTH/2:0];
            gray_out = data_out;

        2'b10: // Quarter-swizzle
            logic [DATA_WIDTH/4 - 1:0] q1, [DATA_WIDTH/4:DATA_WIDTH/2 - 1] q2, [DATA_WIDTH/2:3*DATA_WIDTH/4 - 1] q3, [3*DATA_WIDTH/4:DATA_WIDTH - 1] q4;
            data_out = q1[DATA_WIDTH/4:0] | q2[:DATA_WIDTH/2] | q3[DATA_WIDTH/4:DATA_WIDTH/2] | q4[:DATA_WIDTH/2];
            gray_out = data_out;

        2'b11: // Eighth-swizzle
            logic [DATA_WIDTH/8 - 1:0] e1, [DATA_WIDTH/8:DATA_WIDTH/4 - 1] e2, [DATA_WIDTH/4:DATA_WIDTH/8 - 1] e3, [3*DATA_WIDTH/8:7*DATA_WIDTH/8] e4, [7*DATA_WIDTH/8:DATA_WIDTH - 1] e5;
            data_out = e1[DATA_WIDTH/8:0] | e2[:DATA_WIDTH/4] | e3[DATA_WIDTH/8:DATA_WIDTH/4] | e4[:DATA_WIDTH/4] | e5[:DATA_WIDTH/2];
            gray_out = data_out;

        default:
            data_out = data_in;
            gray_out = data_out;
    endcase

endmodule
