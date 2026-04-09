module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr"             ,
    parameter MSHR_SIZE                     = 32                    ,
    parameter CS_LINE_ADDR_WIDTH            = 10                    ,
    parameter WORD_SEL_WIDTH                = 4                     ,
    parameter WORD_SIZE                     = 4                     ,
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE)     ,
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH+ $clog2(WORD_SIZE) + WORD_SEL_WIDTH),
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8 ,
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH
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

    reg [DATA_WIDTH-1:0] entry_valid_table_q [MSHR_SIZE-1:0];
    reg [MSHR_ADDR_WIDTH-1:0] entry_next_idx [MSHR_SIZE-1:0];
    reg [WORD_SIZE-1:0] entry_data [MSHR_SIZE-1:0];
    reg [WORD_SEL_WIDTH-1:0] entry_write [MSHR_SIZE-1:0];
    reg [WORD_SEL_WIDTH-1:0] entry_next [MSHR_SIZE-1:0];
    reg full_d;

    wire allocate_id_d, match_with_no_next;

    // Index Registers
    reg [MSHR_ADDR_WIDTH-1:0] allocate_idx;
    reg [MSHR_ADDR_WIDTH-1:0] allocate_prev_idx;

    // Leading Zero Counter
    leading_zero_cnt #(
        .DATA_WIDTH (MSHR_SIZE),
        .REVERSE (1)
    ) allocate_idx (
        .data   (~entry_valid_table_q),
        .leading_zeros (allocate_idx),
        .all_zeros (full_d)
    );

    leading_zero_cnt #(
        .DATA_WIDTH (MSHR_SIZE),
        .REVERSE (1)
    ) allocate_prev_idx (
        .data   (match_with_no_next),
        .leading_zeros (allocate_prev_idx),
        `NOTCONNECTED_PIN(all_zeros)
    );

    // Allocation Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < MSHR_SIZE; i = i + 1) begin
                entry_valid_table_q[i] <= 0;
                entry_next_idx[i] <= 0;
                entry_data[i] <= 0;
                entry_write[i] <= 0;
            end
            allocate_ready <= 1;
            allocate_pending <= 0;
            allocate_previd <= 0;
        end else if (allocate_valid) begin
            if (allocate_idx == 0) begin
                allocate_ready <= 0;
                allocate_pending <= 1;
                match_with_no_next <= 1;
                full_d <= 0;
            end else begin
                reg prev_idx = allocate_prev_idx;
                entry_valid_table_q[allocate_idx] <= 0;
                entry_next_idx[allocate_idx] <= allocate_idx + 1;
                entry_data[allocate_idx] <= allocate_data;
                entry_write[allocate_idx] <= allocate_rw;
                allocate_prev_idx <= prev_idx;
            end
        end
    end

    // Finalization Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            finalize_id <= 0;
        end else if (finalize_valid) begin
            int idx = allocate_id;
            int prev_idx = allocate_previd;
            if (idx != prev_idx) begin
                entry_valid_table_q[idx] <= 0;
                entry_next_idx[idx] <= 0;
                entry_data[idx] <= 0;
                entry_write[idx] <= 1; // Assuming write operation on finalize
            end
        end
    end

endmodule
