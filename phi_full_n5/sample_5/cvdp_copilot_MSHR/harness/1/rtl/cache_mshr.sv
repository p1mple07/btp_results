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

    logic [WORD_SIZE-1:0] allocate_data_reg [MSHR_SIZE-1:0];
    logic [WORD_SEL_WIDTH-1:0] allocate_write_reg [MSHR_SIZE-1:0];
    logic [CS_LINE_ADDR_WIDTH-1:0] allocate_addr_reg [MSHR_SIZE-1:0];
    logic [MSHR_ADDR_WIDTH-1:0] allocate_id_reg [MSHR_SIZE-1:0];
    logic [1:0] allocate_pending_reg [MSHR_SIZE-1:0];
    logic [1:0] allocate_previd_reg [MSHR_SIZE-1:0];

    logic [$clog2(WORD_SIZE)-1:0] lead_zero_idx;

    // Allocation Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            foreach (allocate_id_reg[i]) begin
                allocate_id_reg[i] = 0;
                allocate_addr_reg[i] = 0;
                allocate_write_reg[i] = 0;
                allocate_pending_reg[i] = 0;
                allocate_previd_reg[i] = 0;
            end
        else begin
            allocate_id_reg[allocate_pending] = allocate_id;
            allocate_addr_reg[allocate_pending] = allocate_addr;
            allocate_write_reg[allocate_pending] = allocate_rw;
        end
    end

    // Find the first available slot
    always @(posedge clk) begin
        lead_zero_idx = allocate_idx(~allocate_valid_table_q);
        allocate_id_reg[allocate_pending] = allocate_id_reg[lead_zero_idx];
        allocate_addr_reg[allocate_pending] = allocate_addr_reg[lead_zero_idx];
        allocate_write_reg[allocate_pending] = allocate_write_reg[lead_zero_idx];
        allocate_pending_reg[allocate_pending] = 1;
    end

    // Link to the previous entry
    always @(posedge clk) begin
        foreach (allocate_previd_reg[i]) begin
            if (allocate_pending) begin
                allocate_previd_reg[i] = allocate_id_reg[allocate_prev_idx(allocate_addr_reg[i])];
            end else {
                allocate_previd_reg[i] = 0;
            }
        end
    end

    // Finalize Logic
    always @(posedge clk or posedge reset) begin
        if (finalize_valid) begin
            allocate_id_reg[finalize_id] = 0; // Clear the ID of the finalized entry
            allocate_addr_reg[finalize_id] = 0; // Clear the address of the finalized entry
            allocate_write_reg[finalize_id] = 0; // Clear the write status of the finalized entry
            allocate_pending_reg[finalize_id] = 0; // Mark as not pending
        end
    end

endmodule


module leading_zero_cnt #(
    parameter DATA_WIDTH = 32,
    parameter REVERSE = 0 
)(
    input  [DATA_WIDTH -1:0] data,
    output  [$clog2(DATA_WIDTH)-1:0] leading_zeros,
    output all_zeros 
);
    localparam NIBBLES_NUM = DATA_WIDTH/4 ; 
    reg [NIBBLES_NUM-1 :0] all_zeros_flag ;
    reg [1:0]  zeros_cnt_per_nibble [NIBBLES_NUM-1 :0]  ;

    genvar i;
    integer k ;
    // Assign data/nibble 
    reg [3:0]  data_per_nibble [NIBBLES_NUM-1 :0]  ;
    generate
        for (i=0; i < NIBBLES_NUM ; i=i+1) begin
            always @* begin
                data_per_nibble[i] = data[(i*4)+3: (i*4)];
            end
        end
    endgenerate

    generate
        for (i=0; i < NIBBLES_NUM ; i=i+1) begin : g_nibble
            if (REVERSE) begin : g_trailing
                always @* begin
                        zeros_cnt_per_nibble[i] [1] = ~(data_per_nibble[i][1] | data_per_nibble[i][0]); 
                        zeros_cnt_per_nibble[i] [0] = (~data_per_nibble[i][0]) &
                                                      ((~data_per_nibble[i][2]) | data_per_nibble[i][1]);
                        all_zeros_flag[i] = (data_per_nibble[i] == 4'b0000);
                end
            end else begin :g_leading
                always @* begin
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][1] = ~(data_per_nibble[i][3] | data_per_nibble[i][2]); 
                    zeros_cnt_per_nibble[NIBBLES_NUM-1-i][0] = (~data_per_nibble[i][3]) &
                                     ((~data_per_nibble[i][1]) | data_per_nibble[i][2]);
                    
                    all_zeros_flag[NIBBLES_NUM-1-i] = (data_per_nibble[i] == 4'b0000);
                end
            end
        end
    endgenerate

    
    
    reg [$clog2(NIBBLES_NUM)-1:0] index ; 
    reg [1:0]    choosen_nibbles_zeros_count ;
    reg [ $clog2(NIBBLES_NUM*4)-1:0] zeros_count_result ;
    assign leading_zeros =  zeros_count_result ;
    assign all_zeros = (data ==0) ;

endmodule
