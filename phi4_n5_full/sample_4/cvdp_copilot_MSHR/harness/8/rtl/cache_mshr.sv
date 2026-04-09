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

    // Internal storage for MSHR entries
    reg [CS_LINE_ADDR_WIDTH-1:0] cs_line_addr_table [0:MSHR_SIZE-1];
    reg [MSHR_SIZE-1:0] entry_valid_table_q, entry_valid_table_d;
    reg [MSHR_SIZE-1:0] is_write_table;

    // Next pointer flag and pointer table
    reg [MSHR_SIZE-2:0] next_ptr_valid_table_q, next_ptr_valid_table_d;
    reg [MSHR_ADDR_WIDTH-1:0] next_index_ptr [0:MSHR_SIZE-1]; // pointer to the next entry

    // Allocation pending signals
    reg  allocate_pending_q, allocate_pending_d;
    reg [MSHR_ADDR_WIDTH-1:0] allocate_id_q, allocate_id_d;
    wire [MSHR_ADDR_WIDTH-1:0] prev_idx ;
    reg [MSHR_ADDR_WIDTH-1:0]  prev_idx_q;

    // Dequeue interface temporary registers
    reg dequeue_valid_q, dequeue_valid_d ;
    reg [MSHR_ADDR_WIDTH-1:0] dequeue_id_q, dequeue_id_d ;

    // New registers for the dequeue state machine
    // state: 0 = IDLE, 1 = DEQUEUEING
    reg [1:0] state;
    reg [MSHR_ADDR_WIDTH-1:0] deq_ptr;

    // Allocation control signal: new request valid and ready
    wire allocate_fire = allocate_valid && allocate_ready;

    // Insert code here to determine when dequeue operation should occur

    // Address lookup: find any existing entry with the same cache line address
    wire [MSHR_SIZE-1:0] addr_matches;
    genvar i;
    generate
        for (i = 0; i < MSHR_SIZE; i = i + 1) begin : g_addr_matches
            assign addr_matches[i] = entry_valid_table_q[i] && (cs_line_addr_table[i] == allocate_addr) && allocate_fire;
        end
    endgenerate

    wire [MSHR_SIZE-1:0] match_with_no_next = addr_matches & ~next_ptr_valid_table_q ;
    wire full_d ; 

    // Leading zero counter to find first free slot
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_idx (
            .data   (~entry_valid_table_q),
            .leading_zeros  (allocate_id_d),
            .all_zeros (full_d)
    );

    // Leading zero counter to find the first entry in the chain with no next pointer
    leading_zero_cnt #(
            .DATA_WIDTH (MSHR_SIZE),
            .REVERSE (1)
    ) allocate_prev_idx (
            .data   (match_with_no_next),
            .leading_zeros  (prev_idx),
            `NOTCONNECTED_PIN(all_zeros) // not connected
    );
    
    // Combinational logic update for allocation and finalize operations
    always @(*) begin
        entry_valid_table_d     = entry_valid_table_q;
        next_ptr_valid_table_d  = next_ptr_valid_table_q;
       
        // No combinational logic needed for dequeue here as it's handled in a separate state machine.
        
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
    
    // Clocked process: update valid tables and pointers
    always @(posedge clk) begin
        if (reset) begin
            entry_valid_table_q  <= '0;
            next_ptr_valid_table_q  <=  0;
            allocate_pending_q <= 0 ;
        end else begin
            entry_valid_table_q  <= entry_valid_table_d;
            next_ptr_valid_table_q  <=  next_ptr_valid_table_d;
            allocate_pending_q <= allocate_pending_d ; 
        end

        if (allocate_fire) begin
            cs_line_addr_table[allocate_id_d]   <= allocate_addr;
            is_write_table[allocate_id_d]       <= allocate_rw;
        end

        if (allocate_pending_d) begin
            next_index_ptr[prev_idx] <= allocate_id_d;
        end
    end

    // Clocked process: update allocation ID and previous index signals
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

    // Single-Port RAM to store request data
    reg [DATA_WIDTH-1:0] ram [0:MSHR_SIZE-1];
    reg [DATA_WIDTH-1:0] dequeue_data_int;
    always @(posedge clk) begin
        if (allocate_fire) begin
            ram[allocate_id_d] <= allocate_data ;
        end
    end
    
    // Dequeue state machine: when a fill request is received, start dequeuing the chain
    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            deq_ptr <= 0;
        end else begin
            if (state == 0 && fill_valid) begin
                // Start the dequeue chain using the fill_id provided
                state <= 1;
                deq_ptr <= fill_id;
            end else if (state == 1) begin
                if (dequeue_ready) begin
                    // Dequeue the current entry and move to the next if available
                    if (next_ptr_valid_table_q[deq_ptr]) begin
                        deq_ptr <= next_index_ptr[deq_ptr];
                    end else begin
                        // End of chain reached; go back to idle
                        state <= 0;
                        deq_ptr <= 0;
                    end
                end
            end
        end
    end

    // Output assignments for allocation interface
    assign  allocate_pending_d = |addr_matches;
    assign allocate_id = allocate_id_q ;
    assign allocate_ready = ~full_d ;
    assign allocate_previd = prev_idx_q;

    assign allocate_pending = allocate_pending_q;

    // Fill interface: output the cache line address for the fill request
    assign fill_addr = fill_valid ? cs_line_addr_table[fill_id] : '0;

    // Dequeue interface: output the current entry from the dequeue chain
    assign dequeue_valid = (state == 1);
    assign dequeue_addr = cs_line_addr_table[deq_ptr];
    assign dequeue_rw = is_write_table[deq_ptr];
    assign dequeue_data = ram[deq_ptr];
    assign dequeue_id = deq_ptr;

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
    // Divide data into nibbles
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

    reg [$clog2(NIBBLES_NUM)-1:0] index ; 
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