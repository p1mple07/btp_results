module cache_mshr #(
    parameter INSTANCE_ID            = "mo_mshr"             ,
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

    reg [MSHR_SIZE-1:0] allocate_id_q, allocate_id_d;

    reg [MSHR_SIZE-1:0] prev_idx_q;

    reg dequeue_valid_q, dequeue_valid_d ;
    reg [MSHR_ADDR_WIDTH-1:0] dequeue_id_q, dequeue_id_d ;


    assign fill_addr = cs_line_addr_table[fill_id];

    always @(posedge clk) begin
        if (reset) begin
            entry_valid_table_q  <= '0;
            next_ptr_valid_table_q  <=  0;
            allocate_pending_q <= 0 ;
            dequeue_valid_q <= 0 ;
            dequeue_valid_d <= 0 ;
        end else begin
            entry_valid_table_q  <= entry_valid_table_d;
            next_ptr_valid_table_q  <= next_ptr_valid_table_d;
            allocate_pending_q <= allocate_pending_d ; 
            dequeue_valid_q <= dequeue_valid_d ;
        end

        if (allocate_valid) begin
            cs_line_addr_table[allocate_id_d]   <= allocate_addr;
            is_write_table[allocate_id_d]       <= allocate_rw;
        end

        if (allocate_pending_d) begin
            next_index_ptr[prev_idx_q] <= allocate_id_d;
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

    // Dequeue logic
    always @(posedge clk) begin
        if (dequeue_ready) begin
            dequeue_valid_d <= dequeue_valid_q;
            dequeue_addr <= cs_line_addr_table[dequeue_id_q];
            dequeue_rw <= is_write_table[dequeue_id_q];
            dequeue_data <= ram[dequeue_id_q];
            dequeue_id_d <= dequeue_id_q;
        end
        else begin
            dequeue_valid_d <= 0;
            dequeue_addr <= 0;
            dequeue_rw <= 0;
            dequeue_data <= 0;
            dequeue_id_d <= 0;
        end
    end

    // Allocate logic
    always @(posedge clk) begin
        if (allocate_valid) begin
            if (allocate_ready) begin
                allocate_id_d <= allocate_id_q;
                prev_idx_d <= prev_idx_q;
                entry_valid_table_d <= entry_valid_table_q;
                next_ptr_valid_table_d <= next_index_ptr;
                entry_valid_table_q <= 0;
                allocate_pending_d <= 0;
            end
        end
    end

    // Memory Fill logic
    always @(posedge clk) begin
        if (fill_valid) begin
            ram[allocate_id_q] <= allocate_data;
        end
    end

endmodule
