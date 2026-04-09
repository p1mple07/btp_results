module nbit_swizzling(
    parameter DATA_WIDTH,
    input [DATA_WIDTH-1:0] data_in,
    input [1:0] sel,
    output [DATA_WIDTH-1:0] data_out
)  

    integer num_segments;
    integer segment_size;

    case(sel)
        0: num_segments = 1; segment_size = DATA_WIDTH;
        1: num_segments = 2; segment_size = DATA_WIDTH / 2;
        2: num_segments = 4; segment_size = DATA_WIDTH / 4;
        3: num_segments = 8; segment_size = DATA_WIDTH / 8;
        default: num_segments = 1; segment_size = DATA_WIDTH;
    endcase

    for (integer i = 0; i < DATA_WIDTH; i++) begin
        integer segment_index = i / segment_size;
        integer local_pos = i % segment_size;
        integer reversed_local_pos = segment_size - 1 - local_pos;
        integer data_pos = segment_index * segment_size + reversed_local_pos;
        data_out[i] = data_in[data_pos];
    endfor

endmodule