module cache_mshr #(
    parameter INSTANCE_ID = "mo_mshr",
    parameter MSHR_SIZE = 32,
    parameter CS_LINE_ADDR_WIDTH = 10,
    parameter WORD_SEL_WIDTH = 4,
    parameter WORD_SIZE = 4,
    parameter MSHR_ADDR_WIDTH = $clog2(MSHR_SIZE),
    parameter TAG_WIDTH = 32 - (CS_LINE_ADDR_WIDTH + $clog2(WORD_SIZE) + WORD_SEL_WIDTH),
    parameter CS_WORD_WIDTH = WORD_SIZE * 8,
    parameter DATA_WIDTH = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH
) (
    input wire clk,
    input wire reset,

    // memory fill
    input wire fill_valid,
    input wire [MSHR_ADDR_WIDTH-1:0] fill_id,
    output wire [CS_LINE_ADDR_WIDTH-1:0] fill_addr,

    // dequeue
    output wire dequeue_valid,
    output wire [CS_LINE_ADDR_WIDTH-1:0] dequeue_addr,
    output wire dequeue_rw,
    output wire [DATA_WIDTH-1:0] dequeue_data,
    output wire [MSHR_ADDR_WIDTH-1:0] dequeue_id,
    input wire dequeue_ready,

    // allocate
    input wire allocate_valid,
    output wire allocate_ready,
    input wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
    input wire allocate_rw,
    input wire [DATA_WIDTH-1:0] allocate_data,
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_id,
    output wire allocate_pending,
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_previd,

    // finalize
    input wire finalize_valid,
    input wire [MSHR_ADDR_WIDTH-1:0] finalize_id
);

    // internal registers
    reg [CS_LINE_ADDR_WIDTH-1:0] cs_line_addr_table [0:MSHR_SIZE-1];
    reg [MSHR_SIZE-1:0] entry_valid_table_q, entry_valid_table_d;
    reg [MSHR_SIZE-1:0] is_write_table;

    reg [MSHR_SIZE-2:0] next_ptr_valid_table_q, next_ptr_valid_table_d;
    reg [MSHR_ADDR_WIDTH-1:0] next_index_ptr [0:MSHR_SIZE-1];
    reg [MSHR_ADDR_WIDTH-1:0] allocate_id_q, allocate_id_d;

    wire [MSHR_ADDR_WIDTH-1:0] prev_idx;
    reg [MSHR_ADDR_WIDTH-1:0] prev_idx_q;

    reg dequeue_valid_q, dequeue_valid_d;
    reg [MSHR_ADDR_WIDTH-1:0] dequeue_id_q, dequeue_id_d;

    wire allocate_fire = allocate_valid && allocate_ready;

    // ... rest of the code ...

endmodule
