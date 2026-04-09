module cache_mshr #(
    parameter INSTANCE_ID            = "mo_mshr"             ,
    parameter MSHR_SIZE                     = 32                    ,
    parameter CS_LINE_ADDR_WIDTH            = 10                    ,
    parameter WORD_SEL_WIDTH                = 4                     ,
    parameter WORD_SIZE                     = 4                     ,
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

    wire [MSHR_SIZE-1:0] addr_matches;
    reg [MSHR_SIZE-1:0] prev_idx_q;

    reg dequeue_valid_q, dequeue_valid_d ;
    reg [MSHR_ADDR_WIDTH-1:0] dequeue_id_q, dequeue_id_d ;


    assign dequeue_valid_q = dequeue_ready & dequeue_valid_d ;
    assign dequeue_id_q = dequeue_id_d ;

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

        if (allocate_valid & allocate_ready) begin
            cs_line_addr_table[allocate_id_d]   <= allocate_addr;
            is_write_table[allocate_id_d]       <= allocate_rw;
        end

        next_index_ptr[prev_idx_q] <= allocate_id_d;

        if (finalize_valid) begin
            entry_valid_table_d[finalize_id] = 0;
        end

        next_ptr_valid_table_d <= next_ptr_valid_table_q;
    end

    always @(negedge clk) begin
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

    // Memory fill operation
    always @(posedge clk) begin
        if (fill_valid) begin
            if (allocate_ready) begin
                cs_line_addr_table[allocate_id_q] <= fill_addr;
                dequeue_valid_q <= 1;
                dequeue_id_q <= fill_id;
                dequeue_addr_q <= fill_addr;
                dequeue_rw_q <= 1'b0; // assuming read operation for fill
            end else begin
                dequeue_valid_q <= 0;
                dequeue_id_q <= 0;
                dequeue_addr_q <= 0;
                dequeue_rw_q <= 0;
            end
        end
    end

    // Dequeue operation
    always @(posedge clk) begin
        if (dequeue_valid_q) begin
            if (next_index_ptr[dequeue_id_q] != 0) begin
                allocate_id_q <= next_index_ptr[dequeue_id_q];
                prev_idx_q <= next_index_ptr[dequeue_id_q];
            end else {
                dequeue_id_q <= 0;
                prev_idx_q <= 0;
            }
        end
    end

    // Finalize operation
    always @(posedge clk) begin
        if (finalize_valid) begin
            entry_valid_table_d[finalize_id] = 0;
            cs_line_addr_table[allocate_id_d] <= 1'b0; // clear the entry
        end
    end

    // SP RAM
    reg [DATA_WIDTH-1:0] ram [0:MSHR_SIZE-1];
    reg [DATA_WIDTH-1:0] dequeue_data_int;
    assign dequeue_data = ram[dequeue_id_q];

endmodule
