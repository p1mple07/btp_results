module nbit_swizzling #(
    parameter DATA_WIDTH = 64
)(
    input [DATA_WIDTH-1:0] data_in,
    input          sel,
    output         [DATA_WIDTH-1:0] data_out
);

localparam HALF = DATA_WIDTH / 2;
localparam QUARTER = HALF / 2;

function int[] reverse(int[] data);
    int len = data.size();
    int rev[len];
    for (int i = 0; i < len; i++) begin
        rev[i] = data[len - 1 - i];
    end
    return rev;
endfunction

always @(*) begin
    case (sel)
        0: data_out = reverse(data_in);
        1: data_out = reverse(reverse(data_in));
        2: data_out = reverse(reverse(reverse(data_in)));
        3: data_out = reverse(reverse(reverse(reverse(data_in))));
        default: data_out = data_in;
    endcase
end

endmodule
