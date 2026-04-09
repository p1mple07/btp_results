module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr"             ,
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

    wire valid_mask;
    wire [DATA_WIDTH-1:0] entry_valid_data;
    wire [DATA_WIDTH-1:0] match_with_no_next;
    
    // Entry Table
    reg [DATA_WIDTH-1:0] entry_valid_table [MSHR_SIZE-1:0] ;
    
    // Allocation Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < MSHR_SIZE; i = i + 1) begin
                entry_valid_data[i] = 1'b0;
                match_with_no_next[i] = 1'b1;
            end
        end else begin
            entry_valid_data[allocate_addr] = allocate_rw;
            match_with_no_next[allocate_addr] = 1'b0;
        end
    end
    
    assign valid_mask = 1'b1 - entry_valid_data;
    
    // Indexing Logic
    wire [DATA_WIDTH-1:0] allocate_id_d;
    wire leading_zeros;
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_idx (
        .data   (~valid_mask), // bit-wise invert for availabe slots
        .leading_zeros  (allocate_id_d),
        .all_zeros (full_d)
    );
    
    wire prev_idx;
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_prev_idx (
        .data   (match_with_no_next), // allocate address matches that doesn't have next address pointer
        .leading_zeros  (prev_idx),
        `NOTCONNECTED_PIN(all_zeros) // not connected
    );
    
    // Allocation Logic
    always @(posedge clk) begin
        if (allocate_valid) begin
            allocate_id_d = allocate_addr;
            prev_idx = allocate_prev_idx.leading_zeros;
        end else begin
            allocate_id_d = allocate_idx.leading_zeros;
            prev_idx = allocate_prev_idx.leading_zeros;
        end
    end
    
    // Linking Logic
    assign allocate_pending = prev_idx != 0;
    assign allocate_previd = prev_idx;
    
    // Ready Signal
    assign allocate_ready = (allocate_id_d == 0) && (valid_mask == 1'b0);
    
    // Finalize Logic
    always @(posedge clk or posedge reset) begin
        if (finalize_valid) begin
            // Implement finalize logic here
            // For example, mark the finalized entry as invalid
            // entry_valid_table[finalize_id] <= 1'b0;
        end
    end

endmodule
