module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr",
    parameter MSHR_SIZE                     = 32,
    parameter CS_LINE_ADDR_WIDTH            = 10,
    parameter WORD_SEL_WIDTH                = 4,
    parameter WORD_SIZE                     = 4,
    // Derived parameters
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE),     // default = 5
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH + $clog2(WORD_SIZE) + WORD_SEL_WIDTH), // default = 16
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8,          // default = 32 
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH  // default = 4 + 4 + 32 + 16 = 56
)(
    input  wire                           clk,
    input  wire                           reset,

    // allocate
    input  wire                           allocate_valid,
    output wire                           allocate_ready,
    input  wire [CS_LINE_ADDR_WIDTH-1:0]  allocate_addr,
    input  wire                           allocate_rw,
    input  wire [DATA_WIDTH-1:0]          allocate_data,
    output wire [MSHR_ADDR_WIDTH-1:0]     allocate_id,
    output wire                           allocate_pending,
    output wire [MSHR_ADDR_WIDTH-1:0]     allocate_previd,

    // finalize
    input  wire                           finalize_valid,
    input  wire [MSHR_ADDR_WIDTH-1:0]     finalize_id
);

   //-------------------------------------------------------------------------
   // MSHR entry structure: Only meta-data is stored here.
   //-------------------------------------------------------------------------
   typedef struct packed {
       bit valid;
       logic [CS_LINE_ADDR_WIDTH-1:0] cache_line_addr;
       bit write;
       bit next;
       logic [MSHR_ADDR_WIDTH-1:0] next_idx;
   } mshr_entry_t;

   //-------------------------------------------------------------------------
   // MSHR entry array and valid table.
   //-------------------------------------------------------------------------
   mshr_entry_t mshr_entry [0:MSHR_SIZE-1];
   reg [MSHR_SIZE-1:0] entry_valid_table_q;

   //-------------------------------------------------------------------------
   // Wires for allocation logic.
   //-------------------------------------------------------------------------
   wire [MSHR_ADDR_WIDTH-1:0] allocate_id_d;
   wire full_d;
   wire [MSHR_SIZE-1:0] match_with_no_next;
   wire [MSHR_ADDR_WIDTH-1:0] prev_idx;

   //-------------------------------------------------------------------------
   // Instantiate leading zero counter for allocation index.
   // It finds the first available slot by counting leading zeros in ~entry_valid_table_q.
   //-------------------------------------------------------------------------
   leading_zero_cnt #(
       .DATA_WIDTH(MSHR_SIZE),
       .REVERSE(0)
   ) allocate_idx (
       .data(~entry_valid_table_q),
       .leading_zeros(allocate_id_d),
       .all_zeros(full_d)
   );

   //-------------------------------------------------------------------------
   // Compute match_with_no_next: For each entry, if valid, its cache line address 
   // matches the incoming allocate_addr, and it has no next pointer, then assert the bit.
   //-------------------------------------------------------------------------
   genvar i;
   generate
       for (i = 0; i < MSHR_SIZE; i = i + 1) begin : gen_match
           assign match_with_no_next[i] = (mshr_entry[i].valid &&
                                            (mshr_entry[i].cache_line_addr == allocate_addr) &&
                                            (!mshr_entry[i].next));
       end
   endgenerate

   //-------------------------------------------------------------------------
   // Instantiate leading zero counter for previous index.
   // It returns the index of the first MSHR entry (with no next pointer) that matches 
   // the incoming cache line address.
   //-------------------------------------------------------------------------
   leading_zero_cnt #(
       .DATA_WIDTH(MSHR_SIZE),
       .REVERSE(1)
   ) allocate_prev_idx (
       .data(match_with_no_next),
       .leading_zeros(prev_idx),
       .all_zeros() // not connected
   );

   //-------------------------------------------------------------------------
   // Output assignments.
   //-------------------------------------------------------------------------
   assign allocate_ready = ~full_d;         // Ready when there is at least one free slot.
   assign allocate_id    = allocate_id_d;     // Allocated entry index.
   assign allocate_pending = (prev_idx != {MSHR_ADDR_WIDTH{1'b0}}); // Assert if a pending request exists.
   assign allocate_previd  = prev_idx;        // ID of the previous entry for the same cache line.

   //-------------------------------------------------------------------------
   // Sequential logic: Allocation and Finalize.
   // Allocation: On a valid allocation request (and when not full), allocate the first free slot.
   // If the cache line is already pending (i.e. a previous entry exists), link the new entry.
   // Finalize: On finalize, invalidate the entry and update any chain pointers.
   //-------------------------------------------------------------------------
   integer j;
   always_ff @(posedge clk or posedge reset) begin
       if (reset) begin
           // Clear all MSHR entries.
           for (j = 0; j < MSHR_SIZE; j = j + 1) begin
               mshr_entry[j].valid      <= 1'b0;
               mshr_entry[j].cache_line_addr <= {CS_LINE_ADDR_WIDTH{1'b0}};
               mshr_entry[j].write      <= 1'b0;
               mshr_entry[j].next       <= 1'b0;
               mshr_entry[j].next_idx   <= {MSHR_ADDR_WIDTH{1'b0}};
           end
           entry_valid_table_q <= {MSHR_SIZE{1'b0}};
       end
       else begin
           //-------------------------------------------------------------------------
           // Allocation Logic.
           //-------------------------------------------------------------------------
           if (allocate_valid && allocate_ready) begin
               // Allocate new entry at index allocate_id_d.
               mshr_entry[allocate_id_d].valid         <= 1'b1;
               mshr_entry[allocate_id_d].cache_line_addr <= allocate_addr;
               mshr_entry[allocate_id_d].write         <= allocate_rw;
               mshr_entry[allocate_id_d].next          <= 1'b0;
               mshr_entry[allocate_id_d].next_idx      <= {MSHR_ADDR_WIDTH{1'b0}};
               entry_valid_table_q[allocate_id_d]       <= 1'b1;
               
               // If there is an existing pending request for the same cache line,
               // link the new entry as the next entry.
               if (prev_idx != {MSHR_ADDR_WIDTH{1'b0}}) begin
                   mshr_entry[prev_idx].next      <= 1'b1;
                   mshr_entry[prev_idx].next_idx  <= allocate_id_d;
               end
           end

           //-------------------------------------------------------------------------
           // Finalize Logic.
           // On finalize, invalidate the entry and, if it is part of a chain, update the 
           // previous entry's next pointer to skip the finalized entry.
           //-------------------------------------------------------------------------
           if (finalize_valid) begin
               // Invalidate the finalized entry.
               mshr_entry[finalize_id].valid      <= 1'b0;
               mshr_entry[finalize_id].next       <= 1'b0;
               mshr_entry[finalize_id].next_idx   <= {MSHR_ADDR_WIDTH{1'b0}};
               entry_valid_table_q[finalize_id]      <= 1'b0;
               
               // If the finalized entry was linked in a chain, update the previous entry.
               if (mshr_entry[finalize_id].next) begin
                   for (j = 0; j < MSHR_SIZE; j = j + 1) begin
                       if (mshr_entry[j].next && (mshr_entry[j].next_idx == finalize_id)) begin
                           mshr_entry[j].next_idx <= mshr_entry[finalize_id].next_idx;
                           mshr_entry[j].next     <= (mshr_entry[finalize_id].next_idx != {MSHR_ADDR_WIDTH{1'b0}});
                       end
                   end
               end
           end
       end
   end

endmodule

//--------------------------------------------------------------------------
// The following is the leading_zero_cnt module used for computing the 
// index of the first available slot and the previous pending request.
//--------------------------------------------------------------------------
module leading_zero_cnt #(
    parameter DATA_WIDTH = 32,
    parameter REVERSE = 0 
)(
    input  [DATA_WIDTH-1:0] data,
    output [$clog2(DATA_WIDTH)-1:0] leading_zeros,
    output all_zeros
);
    localparam NIBBLES_NUM = DATA_WIDTH/4; 
    reg [NIBBLES_NUM-1:0] all_zeros_flag;
    reg [1:0] zeros_cnt_per_nibble [NIBBLES_NUM-1:0];

    genvar i;
    integer k;
    // Break data into nibbles.
    reg [3:0] data_per_nibble [NIBBLES_NUM-1:0];
    generate
        for (i = 0; i < NIBBLES_NUM; i = i + 1) begin
            always @* begin
                data_per_nibble[i] = data[(i*4)+3:(i*4)];
            end
        end
    endgenerate

    generate
        for (i = 0; i < NIBBLES_NUM; i = i + 1) begin : g_nibble
            if (REVERSE) begin : g_trailing
                always @* begin
                    zeros_cnt_per_nibble[i][1] = ~(data_per_nibble[i][1] | data_per_nibble[i][0]); 
                    zeros_cnt_per_nibble[i][0] = (~data_per_nibble[i][0]) &
                                                   ((~data_per_nibble[i][2]) | data_per_nibble[i][1]);
                    all_zeros_flag[i] = (data_per_nibble[i] == 4'b0000);
                end
            end else begin : g_leading
                always @* begin
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][1] = ~(data_per_nibble[i][3] | data_per_nibble[i][2]); 
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][0] = (~data_per_nibble[i][3]) &
                                                                ((~data_per_nibble[i][1]) | data_per_nibble[i][2]);
                    all_zeros_flag[NIBBLES_NUM-1-i] = (data_per_nibble[i] == 4'b0000);
                end
            end
        end
    endgenerate

    reg [$clog2(NIBBLES_NUM)-1:0] index; 
    reg [1:0] choosen_nibbles_zeros_count;
    reg [$clog2(NIBBLES_NUM*4)-1:0] zeros_count_result;
    wire [NIBBLES_NUM-1:0] all_zeros_flag_decoded;
    
    assign all_zeros_flag_decoded[0] = all_zeros_flag[0];
    genvar j;
    generate
        for (j = 1; j < NIBBLES_NUM; j = j + 1) begin
            assign all_zeros_flag_decoded[j] = all_zeros_flag_decoded[j-1] & all_zeros_flag[j];
        end
    endgenerate

    always @* begin
        index = 0;
        for (k = 0; k < NIBBLES_NUM; k = k + 1) begin
            index = index + all_zeros_flag_decoded[k];
        end
    end
    
    always @* begin
        choosen_nibbles_zeros_count = zeros_cnt_per_nibble[index];
        zeros_count_result = choosen_nibbles_zeros_count + (index << 2);
    end
    
    assign leading_zeros = zeros_count_result;
    assign all_zeros = (data == 0);

endmodule