module cache_mshr #(
    parameter_INSTANCE_ID                   = "mo_mshr"             ,
    parameter MSHR_SIZE                     = 32                    ,
    parameter CS_LINE_ADDR_WIDTH            = 10                    ,
    parameter WORD_SEL_WIDTH                = 4                     ,
    parameter WORD_SIZE                     = 4                     ,
    // Derived parameters
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE)     , // default = 5
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH+ $clog2(WORD_SIZE) + WORD_SEL_WIDTH), // default = 16
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8 ,// default = 32 
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH // default =  4 + 4 + 32 + 16 = 56

    ) (
    input wire clk,
    input wire reset,

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

    // Leading zero counter for allocation
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_idx (
            .data   (~entry_valid_table_q), // bit-wise invert for available slots
            .leading_zeros  (allocate_id_d),
            .all_zeros (full_d)
    );

    // Leading zero counter for previous index
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (0)
    ) allocate_prev_idx (
            .data   (match_with_no_next), // address matches that doesn't have next address pointer
            .leading_zeros  (prev_idx),
            `NOTCONNECTED_PIN(all_zeros) // not connected
    );

    // Module-level state variables
    reg [MSHR_ADDR_WIDTH-1:0] entry_valid_table_q;
    reg [MSHR_ADDR_WIDTH-1:0] prev_idx;
    reg allocate_id;
    reg allocate_pending;
    reg allocate_previd;
    reg allocate_ready;
    reg [MSHR_ADDR_WIDTH-1:0] next_idx;
    reg [MSHR_ADDR_WIDTH-1:0] next_valid;

    // Internal state variables
    reg [MSHR_ADDR_WIDTH-1:0] next_ptr;
    reg [MSHR_ADDR_WIDTH-1:0] next_valid_ptr;
    reg [MSHR_ADDR_WIDTH-1:0] next_next_idx;
    reg [MSHR_ADDR_WIDTH-1:0] next_next_valid;

    // Module-level ports
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_id;
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_pending;
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_previd;
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_ready;

    // Finalize ports
    output wire [MSHR_ADDR_WIDTH-1:0] finalize_id;

    // Module functions
    always@* begin
        // Initialize entry_valid_table
        entry_valid_table_q = 0;
    end

    always@* begin
        // Allocate logic
        if (allocate_valid && !entry_valid_table_q) begin
            allocate_id = 0;
            allocate_pending = 1;
            allocate_previd = 0;
            allocate_ready = 0;
            next_ptr = 0;
            next_valid_ptr = 0;
            next_next_idx = 0;
            next_next_valid = 0;
        end
    end

    always@* begin
        // Finalize logic
        if (finalize_valid && !next_valid_ptr) begin
            next_valid_ptr = 1;
            finalize_id = next_ptr;
        end
    end

    // Manage the linked list structure
    always@* begin
        if (allocate_pending) begin
            // Find first available slot
            allocate_id = allocate_idx();
            allocate_previd = allocate_prev_idx();
            // Update previous index
            next_ptr = allocate_previd;
            next_valid_ptr = 1;
        end
    end

    always@* begin
        // Update next index and valid pointer
        next_next_idx = next_ptr;
        next_next_valid = next_valid_ptr;
    end

    endmodule