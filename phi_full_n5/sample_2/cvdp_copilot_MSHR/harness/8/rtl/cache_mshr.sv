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
) (
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

    reg [CS_LINE_ADDR_WIDTH-1:0] cs_line_addr_table [0:MSHR_SIZE-1];
    reg [MSHR_SIZE-1:0] entry_valid_table_q, entry_valid_table_d;
    reg [MSHR_SIZE-1:0] is_write_table;

    reg [MSHR_SIZE-2:0] next_ptr_valid_table_q, next_ptr_valid_table_d;
    reg [MSHR_ADDR_WIDTH-1:0] next_index_ptr [0:MSHR_SIZE-1]; // ptr to the next index

    reg [MSHR_ADDR_WIDTH-1:0] allocate_id_q, allocate_id_d;

    wire [MSHR_SIZE-1:0] prev_idx ;
    reg [MSHR_ADDR_WIDTH-1:0] prev_idx_q;

    reg dequeue_valid_q, dequeue_valid_d ;
    reg [MSHR_ADDR_WIDTH-1:0] dequeue_id_q, dequeue_id_d ;


    assign dequeue_valid_q = dequeue_valid & dequeue_ready ;
    assign dequeue_id_q = dequeue_id & dequeue_ready ;

    assign fill_addr = cs_line_addr_table[fill_id] ;

    // Insert code here to determine when dequeue operation should occur

    // Address lookup to find matches If there is a match ... link the latest req next ptr to the newly allocated idx
    wire [MSHR_SIZE-1:0] addr_matches;
    always @(*) begin : g_addr_matches
        assign addr_matches = entry_valid_table_q & (cs_line_addr_table == allocate_addr) ;
    end

    assign match_with_no_next = addr_matches & ~next_ptr_valid_table_q ;
    assign full_d = ~allocate_ready ;

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
        `NOTCONNECTED_PIN(all_zeros) // not connected
    );
    
    always @(posedge clk) begin
        if (reset) begin
            entry_valid_table_q  <= '0;
            next_ptr_valid_table_q  <=  0;
            allocate_pending_q <= 0 ;
        end else begin
            entry_valid_table_q  <= entry_valid_table_d;
            next_ptr_valid_table_q  <= next_ptr_valid_table_d;
            allocate_pending_q <= allocate_pending_d ; 
        end

        if (finalize_valid) begin
            entry_valid_table_d[finalize_id] = 0;
        end

        if (allocate_valid & allocate_ready) begin
            entry_valid_table_d[allocate_id_d] = 1;
            next_ptr_valid_table_d[allocate_id_d] = 0;
        end

        if (allocate_pending_d) begin
            next_ptr_valid_table_d[prev_idx] = 1;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            allocate_id_q       <=  0 ;
            prev_idx_q          <= 0 ;
        end else begin
            if (allocate_valid) begin
                allocate_id_q       <=  allocate_id_d       ;
                prev_idx_q          <= prev_idx ;
            end 
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            dequeue_valid_q  <= '0 ;
            dequeue_id_q       <=  0 ;
        end else begin
            dequeue_valid_q  <= entry_valid_table_q ;
            dequeue_id_q       <= entry_id_q ;
        end
    end

    // Insert code here to sequentially update signals related to dequeue operation

    // SP RAM
    reg [DATA_WIDTH-1:0] ram [0:MSHR_SIZE-1];
    reg [DATA_WIDTH-1:0] dequeue_data_int;
    always @(posedge clk) begin
        if (allocate_valid) begin
            ram[allocate_id_d] <= allocate_data ;
        end
    end

    
    
    assign  allocate_pending_d = addr_matches ;
    assign allocate_id = allocate_id_d ;
    assign allocate_ready = ~full_d ;
    assign allocate_previd = prev_idx_q ;

    assign allocate_pending = allocate_pending_q;

    // Insert code here for output fill and dequeue signal updates 
 
endmodule
