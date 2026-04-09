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
    input wire [MSHR_ADDR_WIDTH-1:0]     fill_id,
    output reg [CS_LINE_ADDR_WIDTH-1:0] fill_addr,

    // dequeue
    output reg dequeue_valid,
    output reg [CS_LINE_ADDR_WIDTH-1:0] dequeue_addr,
    output reg dequeue_rw,
    output reg [DATA_WIDTH-1:0]         dequeue_data,
    output reg [MSHR_ADDR_WIDTH-1:0]    dequeue_id,
    input wire dequeue_ready,

    // allocate
    input wire allocate_valid,
    output reg allocate_ready,
    input wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
    input wire allocate_rw,
    input reg [DATA_WIDTH-1:0]         allocate_data,
    output reg [MSHR_ADDR_WIDTH-1:0]   allocate_id,
    output reg allocate_pending,
    output reg [MSHR_ADDR_WIDTH-1:0]   allocate_previd
);

    reg [CS_LINE_ADDR_WIDTH-1:0] cs_line_addr_table [0:MSHR_SIZE-1];
    reg [MSHR_SIZE-1:0] entry_valid_table_q, entry_valid_table_d;
    reg [MSHR_SIZE-1:0] is_write_table;

    reg [MSHR_SIZE-2:0] next_ptr_valid_table_q, next_ptr_valid_table_d;
    reg [MSHR_ADDR_WIDTH-1:0] next_index_ptr [0:MSHR_SIZE-1]; // ptr to the next index

    reg [MSHR_ADDR_WIDTH-1:0] allocate_id_q, allocate_id_d;

    reg [MSHR_ADDR_WIDTH-1:0] prev_idx;
    reg prev_idx_q;

    reg dequeue_valid_q, dequeue_valid_d ;
    reg [MSHR_ADDR_WIDTH-1:0] dequeue_id_q, dequeue_id_d ;


    reg [DATA_WIDTH-1:0] ram [0:MSHR_SIZE-1];
    reg [DATA_WIDTH-1:0] dequeue_data_int;

    always @(posedge clk) begin
        if (reset) begin
            entry_valid_table_q  <= '0;
            next_ptr_valid_table_q  <=  0;
            dequeue_valid_q <= 0;
            dequeue_valid_d <= 0;
            allocate_id_q       <=  0 ;
            prev_idx_q          <= 0 ;
        end else begin
            entry_valid_table_q  <= entry_valid_table_d;
            next_ptr_valid_table_q  <= next_ptr_valid_table_d;
            dequeue_valid_q <= dequeue_valid_d ;
            allocate_id_q       <= allocate_id_d       ;
            prev_idx_q          <= prev_idx ;
        end
    end

    always @(posedge clk) begin
        if (allocate_valid) begin
            if (allocate_rw == 1'b1) begin
                cs_line_addr_table[allocate_id_d]   <= allocate_addr;
                is_write_table[allocate_id_d]       <= 1'b1;
                entry_valid_table_d     <= 1'b1;
                next_ptr_valid_table_d  <= next_index_ptr[allocate_id_d];
                allocate_pending_d <= 1'b1;
            end else begin
                cs_line_addr_table[allocate_id_d]   <= allocate_addr;
                is_write_table[allocate_id_d]       <= 1'b0;
                entry_valid_table_d     <= 1'b0;
                next_ptr_valid_table_d  <= 0;
                allocate_pending_d <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (dequeue_ready) begin
            dequeue_valid_q <= next_ptr_valid_table_q[allocate_id_q];
            dequeue_addr   <= cs_line_addr_table[allocate_id_q];
            dequeue_rw     <= is_write_table[allocate_id_q];
            dequeue_data   <= ram[allocate_id_q];
            dequeue_id_q   <= allocate_id_q;
            dequeue_valid_d <= 1'b1;
            prev_idx_q     <= next_index_ptr[allocate_id_q];
        end
    end

    always @(posedge clk) begin
        if (finalize_valid) begin
            entry_valid_table_d[finalize_id] = 0;
        end
    end

    assign allocate_pending_q = |next_ptr_valid_table_q[allocate_id_q];
    assign allocate_id = allocate_id_q;
    assign allocate_ready = ~next_ptr_valid_table_q[allocate_id_q];

    assign allocate_previd = prev_idx_q;

    always @(posedge clk) begin
        if (reset) begin
            prev_idx_q          <= 0 ;
        end else begin
            if (allocate_pending_d) begin
                next_index_ptr[prev_idx] <= allocate_id_q;
            end
        end
    end

    assign allocate_pending_d = |match_with_no_next;

    // SP RAM
    reg [DATA_WIDTH-1:0] ram [0:MSHR_SIZE-1];
    reg [DATA_WIDTH-1:0] dequeue_data_int;
    always @(posedge clk) begin
        if (allocate_fire) begin
            ram[allocate_id_d] <= allocate_data ;
        end
    end

    assign dequeue_valid_d = |addr_matches;

    assign dequeue_ready = dequeue_ready;

    // Miss Status Handling Registers (MSHR) entries allocation and finalize operations
    always @(posedge clk) begin
        if (fill_valid) begin
            cs_line_addr_table[fill_id] <= fill_addr;
            entry_valid_table_q <= 1'b1;
            next_ptr_valid_table_q <= next_index_ptr[fill_id];
        end
    end

    assign dequeue_id_d = fill_id;

    // Sequential update for dequeue operation
    always @(posedge clk) begin
        if (dequeue_valid_d) begin
            if (dequeue_id_d != dequeue_id_q) begin
                dequeue_id_q <= dequeue_id_d;
                dequeue_valid_q <= 1'b1;
            end else begin
                dequeue_id_q <= 0;
                dequeue_valid_q <= 0;
            end
        end
    end

    // Link the next entry for the same cache line
    always @(posedge clk) begin
        if (entry_valid_table_q[fill_id]) begin
            next_index_ptr[fill_id] <= next_ptr_valid_table_q[fill_id];
        end else {
            next_index_ptr[fill_id] <= 0;
        }
    end

endmodule
