module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr",
    parameter MSHR_SIZE                     = 32,
    parameter CS_LINE_ADDR_WIDTH            = 10,
    parameter WORD_SEL_WIDTH                = 4,
    parameter WORD_SIZE                     = 4,
    // Derived parameters
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE),     // default = 5 for 32 entries
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH + $clog2(WORD_SIZE) + WORD_SEL_WIDTH), // default = 16
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8,         // default = 32
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH // default = 4+4+32+16 = 56
)(
    input  wire clk,
    input  wire reset,

    // allocate ports
    input  wire                          allocate_valid,
    output wire                         allocate_ready,
    input  wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
    input  wire                          allocate_rw,
    input  wire [DATA_WIDTH-1:0]         allocate_data,
    output wire [MSHR_ADDR_WIDTH-1:0]    allocate_id,
    output wire                         allocate_pending,
    output wire [MSHR_ADDR_WIDTH-1:0]    allocate_previd,

    // finalize ports
    input  wire                          finalize_valid,
    input  wire [MSHR_ADDR_WIDTH-1:0]    finalize_id
);

    //-------------------------------------------------------------------------
    // Internal signals for allocation index and pending detection
    //-------------------------------------------------------------------------
    wire [MSHR_ADDR_WIDTH-1:0] allocate_id_d;
    wire full_d;
    wire [MSHR_ADDR_WIDTH-1:0] prev_idx;

    //-------------------------------------------------------------------------
    // MSHR Entry Register Array: Each entry holds meta-data for a cache miss.
    // Fields:
    //   valid       : 1-bit flag indicating if the entry is in use.
    //   cache_line  : Cache line address (CS_LINE_ADDR_WIDTH bits).
    //   write       : Request type (1 = write, 0 = read).
    //   next        : Flag indicating if this entry is linked (1 if yes).
    //   next_index  : Index of the next entry in the chain (if any).
    //-------------------------------------------------------------------------
    reg [MSHR_ADDR_WIDTH-1:0] mshr_valid       [0:MSHR_SIZE-1];
    reg [CS_LINE_ADDR_WIDTH-1:0] mshr_addr       [0:MSHR_SIZE-1];
    reg mshr_write                   [0:MSHR_SIZE-1];
    reg mshr_next                    [0:MSHR_SIZE-1];
    reg [MSHR_ADDR_WIDTH-1:0] mshr_next_index  [0:MSHR_SIZE-1];

    //-------------------------------------------------------------------------
    // Combinational signals for the leading zero counter inputs.
    // entry_valid_table_q: a bit-vector indicating which MSHR entries are valid.
    // match_with_no_next: a bit-vector where bit[i] is 1 if entry i is valid,
    //                     its cache_line equals the incoming allocate_addr, and
    //                     it is not the head of a chain (i.e. no next pointer set).
    //-------------------------------------------------------------------------
    reg [MSHR_SIZE-1:0] entry_valid_table_q;
    reg [MSHR_SIZE-1:0] match_with_no_next;
    // pending_found is high if any entry matches (i.e. a pending request exists)
    wire pending_found = |match_with_no_next;

    //-------------------------------------------------------------------------
    // Drive allocation outputs.
    // allocate_ready is high when the MSHR is not full.
    // allocate_pending asserts if a pending (already allocated) entry exists for
    // the same cache line. In that case, allocate_previd outputs the index of the
    // previous entry in the chain.
    //-------------------------------------------------------------------------
    assign allocate_ready = ~full_d;
    assign allocate_pending = pending_found;
    assign allocate_previd  = pending_found ? prev_idx : {MSHR_ADDR_WIDTH{1'b0}};
    assign allocate_id      = allocate_id_d;

    //-------------------------------------------------------------------------
    // Combinational block: Build the bit-vectors for the leading zero counters.
    //-------------------------------------------------------------------------
    integer i;
    always_comb begin
        for (i = 0; i < MSHR_SIZE; i = i + 1) begin
            entry_valid_table_q[i] = mshr_valid[i];
            if (mshr_valid[i] && (mshr_addr[i] == allocate_addr) && (!mshr_next[i])) begin
                match_with_no_next[i] = 1;
            end else begin
                match_with_no_next[i] = 0;
            end
        end
    end

    //-------------------------------------------------------------------------
    // Sequential block: Handle allocation and finalize (release) requests.
    // Allocation (1-cycle latency):
    //   - On a valid allocate request (when allocate_ready is high),
    //     allocate a new entry at the index given by allocate_id_d.
    //   - If a pending request exists (pending_found is high), update the previous
    //     entry's next pointer to chain the new entry.
    //
    // Finalize (1-cycle latency):
    //   - On a finalize request, mark the entry as invalid.
    //   - If the entry being finalized is part of a chain (mshr_next is set),
    //     update its predecessor's next pointer to skip over it.
    //-------------------------------------------------------------------------
    integer j;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < MSHR_SIZE; i = i + 1) begin
                mshr_valid[i]         <= 1'b0;
                mshr_addr[i]          <= {CS_LINE_ADDR_WIDTH{1'b0}};
                mshr_write[i]         <= 1'b0;
                mshr_next[i]          <= 1'b0;
                mshr_next_index[i]    <= {MSHR_ADDR_WIDTH{1'b0}};
            end
        end else begin
            // Allocation process
            if (allocate_valid && allocate_ready) begin
                // Use the allocated index from the leading zero counter
                mshr_valid[allocate_id_d]         <= 1'b1;
                mshr_addr[allocate_id_d]          <= allocate_addr;
                mshr_write[allocate_id_d]         <= allocate_rw;
                // If there is already a pending request for this cache line,
                // update the previous entry to chain to the new entry.
                if (pending_found) begin
                    mshr_next[prev_idx]           <= 1'b1;
                    mshr_next_index[prev_idx]     <= allocate_id_d;
                end
                // New entry is the last in the chain.
                mshr_next[allocate_id_d]         <= 1'b0;
                mshr_next_index[allocate_id_d]   <= {MSHR_ADDR_WIDTH{1'b0}};
            end

            // Finalize process: release an entry.
            if (finalize_valid) begin
                // Invalidate the entry being finalized.
                mshr_valid[finalize_id] <= 1'b0;
                // If this entry is part of a chain, update its predecessor's pointer.
                if (mshr_next[finalize_id]) begin
                    for (j = 0; j < MSHR_SIZE; j = j + 1) begin
                        if (mshr_valid[j] && (mshr_next_index[j] == finalize_id)) begin
                            mshr_next_index[j] <= mshr_next_index[finalize_id];
                            mshr_next[j]       <= (mshr_next_index[finalize_id] != {MSHR_ADDR_WIDTH{1'b0}});
                        end
                    end
                end
            end
        end
    end

    //-------------------------------------------------------------------------
    // Instantiate the leading zero counter modules.
    // The first counter finds the first available (invalid) entry.
    // The second counter finds the first entry (with no next pointer) matching
    // the incoming cache line address.
    //-------------------------------------------------------------------------
    leading_zero_cnt #(
        .DATA_WIDTH (MSHR_SIZE),
        .REVERSE (1)
    ) allocate_idx (
        .data   (~entry_valid_table_q),
        .leading_zeros  (allocate_id_d),
        .all_zeros (full_d)
    );

    leading_zero_cnt #(
        .DATA_WIDTH (MSHR_SIZE),
        .REVERSE (1)
    ) allocate_prev_idx (
        .data   (match_with_no_next),
        .leading_zeros  (prev_idx),
        `NOTCONNECTED_PIN(all_zeros)
    );

endmodule