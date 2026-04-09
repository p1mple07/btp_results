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

    // Implement leading zero counter
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_idx (
            .data   (~entry_valid_table_q), // bit-wise invert for available slots
            .leading_zeros  (allocate_id_d),
            .all_zeros (full_d)
    );

    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_prev_idx (
            .data   (match_with_no_next), // allocate address matches that doesn't have next address pointer
            .leading_zeros  (prev_idx),
            `NOTCONNECTED_PIN(all_zeros) // not connected
    );

    // MSHR implementation
    reg [MSHR_ADDR_WIDTH-1:0] entry_valid_table_q; // Validity of each slot
    reg [MSHR_ADDR_WIDTH-1:0] entry_addr;          // Cached address
    reg [MSHR_ADDR_WIDTH-1:0] entry_write;         // Request type (RD/RW)
    reg [MSHR_ADDR_WIDTH-1:0] entry_next_idx;      // Next index in linked list
    reg [MSHR_ADDR_WIDTH-1:0] entry_next_addr;      // Next entry address

    // Double port RAM for MSHR data
    double-port RAM [MSHR_ADDR_WIDTH-1:0][MSHR_SIZE] mshr_data;
    input wire [MSHR_ADDR_WIDTH-1:0] write_valid;
    input wire [MSHR_ADDR_WIDTH-1:0] read_valid;

    // Module ports
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_id;
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_pending;
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_previd;

    // Finalize logic
    always @* begin
        if (finalize_valid) begin
            // Release allocated slot
            entry_valid_table_q[allocate_id] = 0;
            // Set next pointers to maintain linked list structure
            entry_next_idx[allocate_id] = allocate_previd;
            entry_next_addr[allocate_id] = allocate_addr;
        end
    end

    // Allocation logic
    always @* begin
        if (allocate_valid && !entry_valid_table_q[allocate_id]) begin
            // Allocate first available slot
            entry_valid_table_q[allocate_id] = 1;
            entry_addr[allocate_id] = allocate_addr;
            entry_write[allocate_id] = allocate_rw;
            entry_next_idx[allocate_id] = allocate_previd;
            entry_next_addr[allocate_id] = 0; // Default value
        end
    end

    // Finalization
    always @* begin
        if (finalize_valid) begin
            // Release slot if it's not allocated
            if (!entry_valid_table_q[allocate_id]) begin
                entry_valid_table_q[allocate_id] = 0;
                entry_next_idx[allocate_id] = -1;
                entry_next_addr[allocate_id] = 0;
            end
        end
    end

    wire [MSHR_ADDR_WIDTH-1:0] next_idx;
    wire [MSHR_ADDR_WIDTH-1:0] next_addr;

endmodule