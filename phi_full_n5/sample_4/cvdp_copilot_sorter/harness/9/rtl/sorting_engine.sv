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
   
   // Load data
   always @(posedge clk) begin
       if (rst) begin
           state <= IDLE;
           data_array <= { {WIDTH{1'b0}}, {WIDTH{1'b0}}, {WIDTH{1'b0}}, {WIDTH{1'b0}} };
           done <= 1'b0;
       end else if (start) begin
           state <= LOAD;
       end
   end

   // Sorting Engine
   always @(posedge clk) begin
       case (state)
           IDLE: begin
               if (start) begin
                   state <= SORT;
                   pass_cnt <= 1;
                   pair_idx <= 0;
               end
           end
           SORT: begin
               if (pair_idx == pairs_in_this_pass) begin
                   case (pass_cnt)
                       1: begin
                           if ((data_array[pair_idx] > data_array[pair_idx + 1]) == 1'b1) begin
                               data_array[pair_idx] <= data_array[pair_idx + 1];
                               data_array[pair_idx + 1] <= data_array[pair_idx];
                           end
                           pass_cnt <= pass_cnt + 1;
                       end
                       2: begin
                           if ((data_array[pair_idx] > data_array[pair_idx + 1]) == 1'b1) begin
                               data_array[pair_idx] <= data_array[pair_idx + 1];
                           end
                           pass_cnt <= pass_cnt + 1;
                       end
                       3: begin
                           if ((data_array[pair_idx + 1] > data_array[pair_idx + 2]) == 1'b1) begin
                               data_array[pair_idx + 1] <= data_array[pair_idx + 2];
                               data_array[pair_idx + 2] <= data_array[pair_idx + 1];
                           end
                           pass_cnt <= 1;
                       end
                       4: begin
                           if ((data_array[pair_idx] > data_array[pair_idx + 2]) == 1'b1) begin
                               data_array[pair_idx] <= data_array[pair_idx + 2];
                               data_array[pair_idx + 2] <= data_array[pair_idx];
                           end
                           pass_cnt <= pass_cnt + 1;
                       end
                       5: begin
                           if ((data_array[pair_idx + 1] > data_array[pair_idx + 2]) == 1'b1) begin
                               data_array[pair_idx + 1] <= data_array[pair_idx + 2];
                           end
                           pass_cnt <= 1;
                       end
                       6: begin
                           if ((data_array[pair_idx] > data_array[pair_idx + 1]) == 1'b1) begin
                               data_array[pair_idx] <= data_array[pair_idx + 1];
                           end
                           pass_cnt <= pass_cnt + 1;
                       end
                       7: begin
                           if ((data_array[pair_idx + 1] > data_array[pair_idx + 2]) == 1'b1) begin
                               data_array[pair_idx + 1] <= data_array[pair_idx + 2];
                           end
                           pass_cnt <= 1;
                       end
                       8: begin
                           done <= 1'b1;
                           state <= DONE;
                       end
                   end
               end else begin
                   state <= SORT;
                   pair_idx <= pair_idx + 1;
               end
           end
           DONE: begin
               out_data <= data_array;
               done <= 1'b0;
           end
       end
   end
endmodule
