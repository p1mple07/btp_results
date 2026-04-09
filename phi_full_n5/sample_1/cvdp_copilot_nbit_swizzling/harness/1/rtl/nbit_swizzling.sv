module nbit_swizzling #(parameter DATA_WIDTH = 64) (
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output reg [DATA_WIDTH-1:0] data_out
);

    always_comb begin
        case (sel)
            0: data_out = {DATA_WIDTH{data_in[DATA_WIDTH-1:0]}};
            1: begin
                int half_width = DATA_WIDTH / 2;
                data_out = {{(1'b1 << (half_width-1)) | {data_in[DATA_WIDTH-half_width]}}:1'b0,
                            {{(1'b0 << (half_width-1)) | {data_in[0]}}:{(half_width{data_in[half_width-1]})}}};
            end
            2: begin
                int quarter_width = DATA_WIDTH / 4;
                data_out = {{(1'b1 << (quarter_width-1)) | {data_in[DATA_WIDTH-quarter_width]}}:1'b0,
                            {{(1'b0 << (quarter_width-1)) | {data_in[2*quarter_width-2]}}:{(quarter_width{data_in[quarter_width-1]})}}:
                            {{(1'b1 << (quarter_width-1)) | {data_in[2*quarter_width-1]}}:{(quarter_width{data_in[quarter_width-1]})}}};
            end
            3: begin
                int eighth_width = DATA_WIDTH / 8;
                data_out = {{(1'b1 << (eighth_width-1)) | {data_in[DATA_WIDTH-eighth_width]}}:1'b0,
                            {{(1'b0 << (eighth_width-1)) | {data_in[2*eighth_width-2]}}:{(eighth_width{data_in[eighth_width-1]})}}:
                            {{(1'b1 << (eighth_width-1)) | {data_in[2*eighth_width-1]}}:{(eighth_width{data_in[eighth_width-1]})}}:
                            {{(1'b1 << (eighth_width-1)) | {data_in[3*eighth_width-2]}}:{(eighth_width{data_in[eighth_width-1]})}}};
            end
            default: data_out = data_in;
        endcase
    end

endmodule
