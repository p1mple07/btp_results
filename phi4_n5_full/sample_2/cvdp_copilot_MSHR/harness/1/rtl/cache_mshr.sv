module dynamically allocates MSHR entries on a cache miss request,
  and if the requested cache line is already pending, it links the new entry
  to the previous one (i.e. appends it to the chain).
  
  The module instantiates two leading zero counter modules:
    - One to find the first available (free) slot.
    - One to find the “previous” entry (the tail of the chain) for the same cache line.
  
  Note: Finalize operations free an entry and update the chain if necessary.
        Allocation and finalize requests are assumed not to conflict.
*/

module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr",
    parameter MSHR_SIZE                     = 32,
    parameter CS_LINE_ADDR_WIDTH            = 10,
    parameter WORD_SEL_WIDTH                = 4,
    parameter WORD_SIZE                     = 4,
    // Derived parameters
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE),
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH + $clog2(WORD_SIZE) + WORD_SEL_WIDTH),
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8,
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH
)(
    input  wire                         clk,
    input  wire                         reset,
    // allocate
    input  wire                         allocate_valid,
    output wire                         allocate_ready,
    input  wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
    input  wire                         allocate_rw,
    input  wire [DATA_WIDTH-1:0]         allocate_data,
    output wire [MSHR_ADDR_WIDTH-1:0]     allocate_id,
    output wire                         allocate_pending,
    output wire [MSHR_ADDR_WIDTH-1:0]     allocate_previd,
    // finalize
    input  wire                         finalize_valid,
    input  wire [MSHR_ADDR_WIDTH-1:0]     finalize_id
);

  //-------------------------------------------------------------------------
  // MSHR Entry Definition
  //-------------------------------------------------------------------------
  typedef struct packed {
    bit                   valid;            // 1 if entry is in use
    logic [CS_LINE_ADDR_WIDTH-1:0] cache_line_addr; // cache line address
    bit                   write;            // 1 = write, 0 = read
    bit                   next;             // 1 if this entry points to another for the same cache line
    logic [MSHR_ADDR_WIDTH-1:0] next_index;    // index of the next entry in the chain
  } mshr_entry_t;

  // Array of MSHR entries
  mshr_entry_t entry [0:MSHR_SIZE-1];

  //-------------------------------------------------------------------------
  // Generate Bit-Vector for Valid Entries (for allocation index search)
  //-------------------------------------------------------------------------
  logic [MSHR_SIZE-1:0] entry_valid_table_q;
  integer i;
  always_comb begin
    for (i = 0; i < MSHR_SIZE; i = i + 1) begin
      entry_valid_table_q[i] = entry[i].valid;
    end
  end

  //-------------------------------------------------------------------------
  // Compute Match Signal: For each entry, if it is valid, its cache line address
  // equals the incoming allocate_addr, and its 'next' flag is 0 (i.e. not yet chained),
  // then set the corresponding bit to 1.
  //-------------------------------------------------------------------------
  logic [MSHR_SIZE-1:0] match_with_no_next;
  always_comb begin
    for (i = 0; i < MSHR_SIZE; i = i + 1) begin
      if ( entry[i].valid && (entry[i].cache_line_addr == allocate_addr) && (!entry[i].next) )
        match_with_no_next[i] = 1'b1;
      else
        match_with_no_next[i] = 1'b0;
    end
  end

  //-------------------------------------------------------------------------
  // Leading Zero Counter Instances
  //-------------------------------------------------------------------------
  // Instance to find the first available (free) MSHR entry.
  wire [MSHR_ADDR_WIDTH-1:0] allocate_id_d;
  wire                       full_d;
  leading_zero_cnt #(
      .DATA_WIDTH(MSHR_SIZE),
      .REVERSE (1)
  ) allocate_idx (
      .data       (~entry_valid_table_q), // invert valid bits: 0 => free
      .leading_zeros(allocate_id_d),
      .all_zeros  (full_d)
  );

  // Instance to find the previous (tail) entry for the same cache line.
  wire [MSHR_ADDR_WIDTH-1:0] prev_idx;
  leading_zero_cnt #(
      .DATA_WIDTH(MSHR_SIZE),
      .REVERSE (1)
  ) allocate_prev_idx (
      .data       (match_with_no_next),
      .leading_zeros(prev_idx)
      // all_zeros not connected
  );

  //-------------------------------------------------------------------------
  // Internal Registers for Allocation Outputs
  //-------------------------------------------------------------------------
  reg allocate_pending_int;
  reg [MSHR_ADDR_WIDTH-1:0] allocate_previd_int;

  // Drive the module outputs
  assign allocate_id      = allocate_id_d;
  assign allocate_ready   = ~full_d;
  assign allocate_pending = allocate_pending_int;
  assign allocate_previd  = allocate_previd_int;

  //-------------------------------------------------------------------------
  // Sequential Logic: Allocation and Finalize Operations
  //-------------------------------------------------------------------------
  integer j;
  always_ff @(posedge clk) begin
    if (reset) begin
      // Clear all MSHR entries on reset
      for (i = 0; i < MSHR_SIZE; i = i + 1) begin
        entry[i].valid         <= 1'b0;
        entry[i].cache_line_addr <= '0;
        entry[i].write         <= 1'b0;
        entry[i].next          <= 1'b0;
        entry[i].next_index    <= '0;
      end
      allocate_pending_int <= 1'b0;
      allocate_previd_int  <= '0;
    end
    else begin
      // Finalize operation: Free the entry and update the chain if necessary.
      if (finalize_valid) begin
        int freed = finalize_id;  // index to be freed
        entry[freed].valid <= 1'b0;
        // Search for the previous entry in the chain that points to 'freed'
        for (j = 0; j < MSHR_SIZE; j = j + 1) begin
          if ( entry[j].valid &&
               (entry[j].cache_line_addr == entry[freed].cache_line_addr) &&
               (entry[j].next) &&
               (entry[j].next_index == freed) )
          begin
            entry[j].next_index <= entry[freed].next_index;
            entry[j].next       <= (entry[freed].next_index != 0);
          end
        end
      end

      // Allocation operation: Allocate a new MSHR entry if valid and if MSHR is not full.
      if (allocate_valid && allocate_ready) begin
        int new_index = allocate_id_d;  // allocated index from leading zero counter

        // Check if there is already a pending request for the same cache line.
        // If so, update the previous (tail) entry to chain to the new entry.
        if (prev_idx != 0) begin
          entry[prev_idx].next          <= 1'b1;
          entry[prev_idx].next_index    <= new_index;
          allocate_pending_int          <= 1'b1;
          allocate_previd_int           <= prev_idx;
        end
        else begin
          allocate_pending_int <= 1'b0;
          allocate_previd_int  <= '0;
        end

        // Update the new allocated entry.
        entry[new_index].valid         <= 1'b1;
        entry[new_index].cache_line_addr <= allocate_addr;
        entry[new_index].write         <= allocate_rw;
        entry[new_index].next          <= 1'b0;
        entry[new_index].next_index    <= '0;
      end
    end
  end

endmodule