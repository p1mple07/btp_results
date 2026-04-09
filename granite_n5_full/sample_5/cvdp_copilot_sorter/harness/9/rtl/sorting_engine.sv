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
    assign pairs_in_this_pass = (pass_cnt[0] == 1'b0)? (N/2) : ( (N/2) > 0? (N/2) - 1 : 0 );

   always @(posedge clk or posedge rst)
   begin
       if(rst)
           state <= IDLE;
       else
           state <= next_state;
   end

   always @(*)
   begin
       case(state)
           IDLE:
           begin
               next_state = LOAD;
           end
           
           LOAD:
           begin
               for(int i=0;i<N;i++)
                   data_array[i] <= in_data[i*WIDTH +: WIDTH];
               
               next_state = SORT;
           end
           
           SORT:
           begin
               // Implement the sorting logic here using the provided data_array.
               // Remember to handle the loading of new data into the data_array.
               // Use the provided parameters and constants.
               
               // Update the next_state based on the current state.
               
               next_state = DONE;
           end
           
           DONE: 
           begin
               // Implement the logic to copy the sorted array into the out_data port.
               // Make sure to properly handle the size of the output data.
               
               // Set the output data based on the currently loaded data_array.
               
               next_state = IDLE;
           end
       endcase
   end
endmodule