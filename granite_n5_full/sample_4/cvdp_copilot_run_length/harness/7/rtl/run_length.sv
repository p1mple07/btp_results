module parallel_run_length #(
    parameter DATA_WIDTH = 8,      // Max run length for each stream
    parameter NUM_STREAMS = 4     // Number of parallel input streams
) (
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable,
    output wire [NUM_STREAMS-1:0] data_out,
    output wire [NUM_STREAMS*($clog2(DATA_WIDTH)+1)-1:0] run_value,
    output wire [NUM_STREAMS-1:0] valid
);

    //... (same as original code)

endmodule