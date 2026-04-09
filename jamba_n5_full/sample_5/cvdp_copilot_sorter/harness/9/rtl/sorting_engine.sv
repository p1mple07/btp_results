module sorting_engine #(
    parameter N = 8,     
    parameter WIDTH = 8  
)(
    input  wire                clk,
    input  wire                rst,
    input  wire                start,
    input  wire [N*WIDTH-1:0]  in_data,
    output reg                 done,
    output reg [N*WIDTH-1:0]   out_data
);
    localparam IDLE = 2'd0,
               LOAD = 2'd1,
               SORT = 2'd2,
               DONE = 2'd3;

    reg [1:0]  state, next_state;
    reg [WIDTH-1:0] data_array [0:N-1];
    reg [$clog2(N+1)-1:0] pass_cnt;
    reg [$clog2(N/2+1)-1:0] pair_idx;

    wire [$clog2(N/2+1)-1:0] pairs_in_this_pass;
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0) ? (N/2) : ( (N/2) > 0 ? (N/2) - 1 : 0 );

   //Insert code here to implement the Brick Sort Algorithm

endmodule
