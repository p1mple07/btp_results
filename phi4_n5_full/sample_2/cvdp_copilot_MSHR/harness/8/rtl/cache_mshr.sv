rtl/cache_mshr.sv
------------------------------------------------------------
`timescale 1ns/1ps

`define NOTCONNECTED_PIN(x)   /* verilator lint_off PINCONNECTEMPTY */ \
                        .x () \
                        /* verilator lint_on PINCONNECTEMPTY */

module cache_mshr #(
    parameter INSTANCE_ID            = "mo_mshr"             ,
    parameter MSHR_SIZE                     = 32                    ,
    parameter CS_LINE_ADDR_WIDTH            = 10                    ,
    parameter WORD_SEL_WIDTH                = 4                     ,
    parameter WORD_SIZE                     = 4                     ,
    // Derived parameters
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE)     , // default = 5
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH+ $clog2(WORD_SIZE) + WORD_SEL_WIDTH), // default = 16
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8 ,// default = 32 
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH // default =  4 + 4 + 32 + 16 = 56
)(
    input wire clk,
    input wire reset,

     // memory fill
    input wire                           fill_valid,
    input wire [MSHR_ADDR_WIDTH-1:0]     fill_id,
    output wire [CS_LINE_ADDR_WIDTH-1:0] fill_addr,

    // dequeue
    output wire                          dequeue_valid,
    output wire [CS_LINE_ADDR_WIDTH-1:0] dequeue_addr,
    output wire                          dequeue_rw,
    output wire [DATA_WIDTH-1:0]         dequeue_data,
    output wire [MSHR_ADDR_WIDTH-1:0]    dequeue_id,
    input wire                           dequeue_ready,

    // allocate
    input wire                          allocate_valid,
    output wire                         allocate_ready,
    input wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
    input wire                          allocate_rw,
    input wire [DATA_WIDTH-1:0]         allocate_data,
    output wire [MSHR_ADDR_WIDTH-1:0]   allocate_id,
    output wire                         allocate_pending,
    output wire [MSHR_ADDR_WIDTH-1:0]   allocate_previd,

    // finalize
    input wire                          finalize_valid,
    input wire [MSHR_ADDR_WIDTH-1:0]    finalize_id
);

    // Internal storage for MSHR entries
    reg [CS_LINE_ADDR_WIDTH-1:0] cs_line_addr_table [0:MSHR_SIZE-1];
    reg [MSHR_SIZE-1:0] entry_valid_table_q, entry_valid_table_d;
    reg [MSHR_SIZE-1:0] is_write_table;
    reg [MSHR_SIZE-2:0] next_ptr_valid_table_q, next_ptr_valid_table_d;
    reg [MSHR_ADDR_WIDTH-1:0] next_index_ptr [0:MSHR_SIZE-1]; // pointer to the next MSHR entry

    reg allocate_pending_q, allocate_pending_d;
    reg [MSHR_ADDR_WIDTH-1:0] allocate_id_q, allocate_id_d;
    wire [MSHR_ADDR_WIDTH-1:0] prev_idx;
    reg [MSHR_ADDR_WIDTH-1:0]  prev_idx_q;

    // Dequeue state registers
    reg dequeue_valid_q, dequeue_valid_d;
    reg [MSHR_ADDR_WIDTH-1:0] dequeue_id_q, dequeue_id_d;
    reg [MSHR_ADDR_WIDTH-1:0] dequeue_ptr_q; // current dequeue pointer

    // Compute allocation fire condition
    wire allocate_fire = allocate_valid && allocate_ready;

    // Address lookup: find any existing entry with the same cache line address
    wire [MSHR_SIZE-1:0] addr_matches;
    genvar i;
    generate
        for (i = 0; i < MSHR_SIZE; i = i+1) begin : g_addr_matches
            assign addr_matches[i] = entry_valid_table_q[i] && (cs_line_addr_table[i] == allocate_addr) && allocate_fire;
        end
    endgenerate

    wire [MSHR_SIZE-1:0] match_with_no_next = addr_matches & ~next_ptr_valid_table_q;
    wire full_d;

    // Compute an index for a free entry using leading zero count
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_idx (
            .data   (~entry_valid_table_q),
            .leading_zeros  (allocate_id_d),
            .all_zeros (full_d)
    );

    // Compute the previous entry index for linking new request to an existing chain
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_prev_idx (
            .data   (match_with_no_next),
            .leading_zeros  (prev_idx),
            `NOTCONNECTED_PIN(all_zeros)
    );
    
    // Combinational always block to update MSHR entry valid flags and next pointer flags.
    // Also, when a dequeue operation is active, mark the current entry as invalid.
    always @(*) begin
        entry_valid_table_d     = entry_valid_table_q;
        next_ptr_valid_table_d  = next_ptr_valid_table_q;
       
        // If a dequeue is in progress, invalidate the current entry.
        if (dequeue_ready && dequeue_valid_q) begin
            entry_valid_table_d[dequeue_ptr_q] = 0;
        end

        // Finalize operation: mark the finalized entry as invalid.
        if (finalize_valid) begin
            entry_valid_table_d[finalize_id] = 0;
        end

        if (allocate_fire) begin
            entry_valid_table_d[allocate_id_d] = 1;
            next_ptr_valid_table_d[allocate_id_d] = 0;
        end

        if (allocate_pending_d) begin
            next_ptr_valid_table_d[prev_idx] = 1;
        end
    end
    
    // Sequential always block: update MSHR tables and dequeue pointer.
    always @(posedge clk) begin
        if (reset) begin
            entry_valid_table_q  <= '0;
            next_ptr_valid_table_q  <=  0;
            allocate_pending_q <= 0 ;
            dequeue_valid_q <= 0;
            dequeue_id_q <= 0;
            dequeue_ptr_q <= 0;
        end else begin
            entry_valid_table_q  <= entry_valid_table_d;
            next_ptr_valid_table_q  <= next_ptr_valid_table_d;
            allocate_pending_q <= allocate_pending_d; 
        end

        if (allocate_fire) begin
            cs_line_addr_table[allocate_id_d]   <= allocate_addr;
            is_write_table[allocate_id_d]       <= allocate_rw;
        end

        if (allocate_pending_d) begin
            next_index_ptr[prev_idx] <= allocate_id_d;
        end

        // Dequeue sequential logic:
        // When a fill request is active, latch the fill_id as the current dequeue pointer.
        if (fill_valid) begin
            dequeue_ptr_q <= fill_id;
            dequeue_valid_q <= 1;
            dequeue_id_q <= fill_id;
        end 
        // When the downstream is ready to accept a dequeue, move to the next linked entry if available.
        else if (dequeue_ready && dequeue_valid_q) begin
            if (next_ptr_valid_table_q[dequeue_ptr_q]) begin
                dequeue_ptr_q <= next_index_ptr[dequeue_ptr_q];
                dequeue_id_q <= next_index_ptr[dequeue_ptr_q];
            end else begin
                dequeue_valid_q <= 0;
            end
        end 
        // If no fill is active, clear the dequeue valid signal.
        else if (!fill_valid) begin
            dequeue_valid_q <= 0;
        end
    end

    // Update allocate_id_q