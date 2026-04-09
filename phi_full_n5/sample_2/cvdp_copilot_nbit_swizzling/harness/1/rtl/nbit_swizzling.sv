module nbit_swizzling #(parameter DATA_WIDTH = 64) (
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH-1:0] data_out
);

    // Combinational logic to handle different swizzling operations
    always_comb begin
        case (sel)
            0: data_out = {~data_in[DATA_WIDTH-1-:1], data_in[DATA_WIDTH-1]};
            1: begin
                integer half_width = DATA_WIDTH / 2;
                data_out = {~data_in[DATA_WIDTH-1-:half_width], data_in[DATA_WIDTH-1-half_width]};
                data_out = {data_out[DATA_WIDTH-1-:half_width], data_out[DATA_WIDTH-1]};
            end
            2: begin
                integer quarter_width = DATA_WIDTH / 4;
                data_out = {~data_in[DATA_WIDTH-1-:quarter_width], data_in[DATA_WIDTH-1-quarter_width]};
                data_out = {data_out[DATA_WIDTH-1-quarter_width], data_out[DATA_WIDTH-1]};
                data_out = {~data_out[DATA_WIDTH-1-:quarter_width], data_out[DATA_WIDTH-1-quarter_width]};
            end
            3: begin
                integer eighth_width = DATA_WIDTH / 8;
                data_out = {~data_in[DATA_WIDTH-1-:eighth_width], data_in[DATA_WIDTH-1-eighth_width]};
                data_out = {data_out[DATA_WIDTH-1-eighth_width], data_out[DATA_WIDTH-1]};
                data_out = {~data_out[DATA_WIDTH-1-:eighth_width], data_out[DATA_WIDTH-1-eighth_width]};
                data_out = {data_out[DATA_WIDTH-1-eighth_width], data_out[DATA_WIDTH-1]};
                data_out = {~data_out[DATA_WIDTH-1-:eighth_width], data_out[DATA_WIDTH-1-eighth_width]};
            end
            default: data_out = data_in;
        endcase
    end

endmodule
