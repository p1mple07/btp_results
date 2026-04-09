// ... [parameter definitions remain the same] ...

module sorting_engine #(parameter WIDTH = 8)(
    input'clock, 
    input'rest, 
    input'start, 
    input[8*WIDTH-1:0] in_data, 
    outputreg'done, 
    output reg[8*WIDTH-1:0] out_data
);

localparam IDLE = 3'd0,
      LOAD = 3'd1,
      SORT_PAIRS = 3'd2,
      MERGEPhases = 3'd3,
      MERGE_4 = 3'd4,
      DONE = 3'd5;

reg[2:0] state;

// Modified internal architecture...

[Rest of the code adjusted to minimize states and pipeline stages...]

// ... [rest of the code adjusted similarly...] ...

MERGEPhases: begin
   // Merge first two pairs (indices 0-1 and 2-3)
   if ((ptr1 < 2) && (ptr2 < 2)) begin
      if (sorted_pairs[ptr1] <= sorted_pairs[ptr2+2]) begin
         merge4_right[merge_count] <= sorted_pairs[ptr1];
         ptr1 += 1;
      else begin
         merge4_right[merge_count] <= sorted_pairs[ptr2+2];
         ptr2 += 1;
      end
   end else if (ptr1 < 2) begin
      merge4_right[merge_count] <= sorted_pairs[ptr1];
      ptr1 += 1;
   end else if (ptr2 < 2) begin
      merge4_right[merge_count] <= sorted_pairs[ptr2+2];
      ptr2 += 1;
   end
   if (merge_count == 3) begin
      merge_count = 0;
      ptr1 = 0;
      ptr2 = 0;
      state <= MERGE_4;
   end else begin
      merge_count += 1;
   end
end

[Other state transitions adjusted to use MERGEPhases instead of separate MERGE states...]

DONE: begin
   pack final_sorted into out_data...
   done <= 1;
   state <= IDLE;
end

default: state <= IDLE;
[/Verilog code]