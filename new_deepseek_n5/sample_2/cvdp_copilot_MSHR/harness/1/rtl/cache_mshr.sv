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

    // Internal signals
    reg [MSHR_ADDR_WIDTH-1:0] entry_valid_table_q;
    reg [MSHR_ADDR_WIDTH-1:0] data_valid_table_q;
    reg [MSHR_ADDR_WIDTH-1:0] prev_idx;
    reg [MSHR_ADDR_WIDTH-1:0] next_idx;
    reg [MSHR_ADDR_WIDTH-1:0] next_index;
    reg [MSHR_ADDR_WIDTH-1:0] alloc_next;

    // Leading zero counter for allocation
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_idx (
            .data   (~entry_valid_table_q), // bit-wise invert for available slots
            .leading_zeros  (allocate_id_d),
            .all_zeros (full_d)
    );

    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_prev_idx (
            .data   (match_with_no_next), // allocate address matches that doesn't have next address pointer
            .leading_zeros  (prev_idx),
            `NOTCONNECTED_PIN(all_zeros) // not connected
    );

    // Allocation logic
    always @* begin
        if (allocate_valid && !reset) begin
            if (entry_valid_table_q[0]) begin
                // Slot found
                allocate_id = 0;
                allocate_pending = 0;
                allocate_ready = 1;
                next_idx = allocate_prev_idx[0];
            else begin
                // Find first available slot
                allocate_id = allocate_idx[0];
                allocate_pending = 1;
                allocate_ready = 0;
                next_idx = allocate_prev_idx[0];
            end
        end
        // Finalize logic
        if (finalize_valid && !reset) begin
            // Mark slot as invalid
            entry_valid_table_q[allocate_id] = 0;
            // Update previous index
            prev_idx = allocate_prev_idx[allocate_id];
            // Update next index
            next_idx = next_idx[allocate_id];
            // Update allocation pointer
            alloc_next = next_idx;
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
                data_per_nibble[i] = data[(i*4)+3: (i*4)] ;
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

    
    
    reg [$clog2(NIBBLES_NUM*4)-1:0] index ; 
    reg [1:0]    choosen_nibbles_zeros_count ;
    reg [ $clog2(NIBBLES_NUM*4)-1:0] zeros_count_result ;
    wire [NIBBLES_NUM-1:0]         all_zeros_flag_decoded;
    
    assign all_zeros_flag_decoded[0] = all_zeros_flag[0] ;
    genvar j;
        generate
            for (j=1; j < NIBBLES_NUM; j=j+1) begin
                assign all_zeros_flag_decoded[j] = all_zeros_flag_decoded[j-1] & all_zeros_flag[j];
            end
        endgenerate

    always@ * begin
        index = 0 ;
        for ( k =0 ; k< NIBBLES_NUM ; k =k +1) begin
            index = index + all_zeros_flag_decoded[k] ;
        end
    end
    
    always@* begin
        choosen_nibbles_zeros_count = zeros_cnt_per_nibble[index]  ;  
        zeros_count_result = choosen_nibbles_zeros_count + (index <<2) ; 
    end
    
    assign leading_zeros =  zeros_count_result ;
    assign all_zeros = (data ==0) ;

endmodule