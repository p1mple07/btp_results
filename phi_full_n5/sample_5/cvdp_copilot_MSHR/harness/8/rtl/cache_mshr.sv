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
    input wire fill_valid,
    input wire [MSHR_ADDR_WIDTH-1:0] fill_id,
    output reg fill_addr,

    // dequeue
    output reg dequeue_valid,
    output reg [CS_LINE_ADDR_WIDTH-1:0] dequeue_addr,
    output reg dequeue_rw,
    output reg [DATA_WIDTH-1:0] dequeue_data,
    output reg [MSHR_ADDR_WIDTH-1:0] dequeue_id,
    input reg dequeue_ready,

    // allocate
    input wire allocate_valid,
    output reg allocate_ready,
    input wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
    input wire allocate_rw,
    input reg [DATA_WIDTH-1:0] allocate_data,
    output reg allocate_id,
    output reg allocate_pending,
    output reg [MSHR_ADDR_WIDTH-1:0] allocate_previd
);

    reg [CS_LINE_ADDR_WIDTH-1:0] cs_line_addr_table [0:MSHR_SIZE-1];
    reg [MSHR_SIZE-1:0] entry_valid_table_q, entry_valid_table_d;
    reg [MSHR_SIZE-1:0] is_write_table;

    reg [MSHR_SIZE-2:0] next_ptr_valid_table_q, next_ptr_valid_table_d;
    reg [MSHR_ADDR_WIDTH-1:0] next_index_ptr [0:MSHR_SIZE-1]; // ptr to the next index

    reg [MSHR_ADDR_WIDTH-1:0] allocate_id_q, allocate_id_d;

    reg dequeue_valid_q, dequeue_valid_d ;
    reg [MSHR_ADDR_WIDTH-1:0] dequeue_id_q, dequeue_id_d ;


    reg [MSHR_SIZE-1:0] match_with_no_next;
    reg full_d ; 

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

        if (allocate_valid) begin
            cs_line_addr_table[allocate_id_d]   <= allocate_addr;
            is_write_table[allocate_id_d]       <= allocate_rw;
        end

        if (allocate_pending_d) begin
            next_index_ptr[prev_idx] <= allocate_id_d;
        end

        match_with_no_next = addr_matches & ~next_ptr_valid_table_q ;
        full_d = |match_with_no_next;

        allocate_idx = allocate_idx_inst(.data(~entry_valid_table_q),
                                .leading_zeros(allocate_id_d),
                                .all_zeros(full_d)
        );

        allocate_prev_idx = allocate_prev_idx_inst(.data(match_with_no_next),
                                .leading_zeros(prev_idx),
                                `NOTCONNECTED_PIN(all_zeros) // not connected
        );

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

    always @(posedge clk) begin
        if (reset) begin
            allocate_id_q       <=  0 ;
            prev_idx_q          <= 0 ;
        end else begin
            if (allocate_fire) begin
                allocate_id_q       <=  allocate_id_d       ;
                prev_idx_q          <= prev_idx ;
            end 
        end
    end

    reg [DATA_WIDTH-1:0] ram [0:MSHR_SIZE-1];
    reg [DATA_WIDTH-1:0] dequeue_data_int;
    always @(posedge clk) begin
        if (allocate_fire) begin
            ram[allocate_id_d] <= allocate_data ;
        end
    end

    assign allocate_pending_d = full_d ;
    assign allocate_id = allocate_id_q ;
    assign allocate_ready = ~full_d ;
    assign allocate_previd = prev_idx_q;

    always @(posedge clk) begin
        if (reset) begin
            dequeue_valid_q <= 0;
            dequeue_valid_d <= 0;
            dequeue_addr_q <= 'bx;
            dequeue_addr_d <= 'bx;
            dequeue_rw_q <= 0;
            dequeue_rw_d <= 0;
            dequeue_data_q <= 'bx;
            dequeue_data_d <= 'bx;
            dequeue_id_q <= 'bx;
            dequeue_id_d <= 'bx;
        end else begin
            if (dequeue_ready) begin
                dequeue_valid_q <= dequeue_valid_d ;
                dequeue_addr_q <= dequeue_addr_d ;
                dequeue_rw_q <= dequeue_rw_d ;
                dequeue_data_q <= dequeue_data_d ;
                dequeue_id_q <= dequeue_id_d ;
            end
        end
    end

    // Insert code here to sequentially update signals related to dequeue operation

    // SP RAM
    reg [DATA_WIDTH-1:0] ram_q [0:MSHR_SIZE-1];
    reg [DATA_WIDTH-1:0] dequeue_data_int_q;
    always @(posedge clk) begin
        if (dequeue_ready) begin
            dequeue_data_int_q <= dequeue_data_q ;
        end
    end

    assign dequeue_valid_q = dequeue_ready & dequeue_valid_d ;
    assign dequeue_addr_q = dequeue_addr_d ;
    assign dequeue_rw_q = dequeue_rw_d ;
    assign dequeue_data_q = dequeue_data_int_q ;
    assign dequeue_id_q = dequeue_id_d ;

    // Insert code here for output fill and dequeue signal updates 

endmodule
