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
            .REVERSE (1)
    ) allocate_prev_idx (
            .data   (match_with_no_next), // addresses that don't have next pointer
            .leading_zeros  (prev_idx),
            `NOTCONNECTED_PIN(all_zeros) // not connected
    );

    // Module state variables
    reg [MSHR_ADDR_WIDTH-1:0]   allocated;
    reg [MSHR_ADDR_WIDTH-1:0]   pending;
    reg [MSHR_ADDR_WIDTH-1:0]   prev_address;
    reg [MSHR_ADDR_WIDTH-1:0]   next_address;
    reg [MSHR_ADDR_WIDTH-1:0]   next_index;
    reg [MSHR_ADDR_WIDTH-1:0]   current_index;

    // Initialize leading zero counters
    initial begin
        allocate_idx = 0;
        allocate_prev_idx = 0;
    end

    // Allocation logic
    always @* begin
        if (allocate_valid && !reset) begin
            // Find first available slot
            current_index = allocate_idx();
            if (current_index == 0) begin
                // Allocate to first available slot
                allocated = 1;
                allocate_id = current_index;
                allocate_pending = 1;
                allocate_previd = prev_address;
                allocate_ready = 1;
            else begin
                // Find previous index
                next_index = allocate_prev_idx();
                if (next_index == 0) begin
                    // No available slot
                    allocate_ready = 0;
                else begin
                    // Allocate to next available slot
                    allocated = 1;
                    allocate_id = next_index;
                    allocate_pending = 1;
                    allocate_previd = prev_address;
                    allocate_ready = 1;
                    next_address = next_index - 1;
                end
            end
        end
        // Always assert ready after allocation
        allocate_ready = 1;
    end

    // Finalization logic
    always @* begin
        if (finalizer_valid && !reset) begin
            // Mark allocated entry as invalid
            allocated = 0;
            allocate_valid = 0;
            allocate_id = 0;
            allocate_previd = 0;
            allocate_pending = 0;
        end
    end

    wire [MSHR_ADDR_WIDTH-1:0] next_address;
    wire [MSHR_ADDR_WIDTH-1:0] next_index;
    wire [MSHR_ADDR_WIDTH-1:0] allocated;
    wire [MSHR_ADDR_WIDTH-1:0] pending;
    wire [MSHR_ADDR_WIDTH-1:0] prev_address;
    wire [MSHR_ADDR_WIDTH-1:0] allocate_id;
    wire [MSHR_ADDR_WIDTH-1:0] allocate_previd;
    wire [MSHR_ADDR_WIDTH-1:0] allocate_pending;
    wire [MSHR_ADDR_WIDTH-1:0] allocate_valid;
    wire [DATA_WIDTH-1:0] allocate_data;
    wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr;
    wire [MSHR_ADDR_WIDTH-1:0] finalize_id;
    wire reset;
    wire clk;

endmodule