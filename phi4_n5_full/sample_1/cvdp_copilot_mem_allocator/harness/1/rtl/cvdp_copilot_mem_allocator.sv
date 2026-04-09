module cvdp_copilot_mem_allocator #(
    parameter SIZE  = 4,
    parameter ADDRW = $clog2(SIZE)
) (
    input  wire             clk,
    input  wire             reset,

    input  wire             acquire_en,    
    output wire [ADDRW-1:0] acquire_addr,      
    
    input  wire             release_en,
    input  wire [ADDRW-1:0] release_addr,    
    
    output wire             empty,
    output wire             full    
);

    // Registers for tracking free slots and allocator state
    reg [SIZE-1:0] free_slots, free_slots_n;
    reg [ADDRW-1:0] acquire_addr_r;
    reg empty_r, full_r;    
    wire [ADDRW-1:0] free_index;
    wire full_d;
    
    // Instantiate the Leading Zero Counter module.
    // It computes the index of the first free slot (least significant free bit)
    cvdp_leading_zero_cnt #(
        .DATA_WIDTH(SIZE),
        .REVERSE(0)
    ) free_slots_sel (
        .data         (free_slots_n),
        .leading_zeros(free_index),
        .all_zeros    (full_d)
    );
    
    // Combinational logic to compute next state for free_slots_n.
    // On reset, all slots are free.
    // When acquire_en is asserted, clear the bit corresponding to acquire_addr_r.
    // When release_en is asserted, mark the slot specified by release_addr as free.
    always_comb begin
        if (reset)
            free_slots_n = {SIZE{1'b1}};
        else begin
            free_slots_n = free_slots;
            if (acquire_en)
                free_slots_n[acquire_addr_r] = 1'b0;
            if (release_en)
                free_slots_n[release_addr] = 1'b1;
        end
    end
    
    // Sequential logic: update free_slots and state registers on clock edge.
    always_ff @(posedge clk) begin
        if (reset) begin
            free_slots      <= {SIZE{1'b1}};
            acquire_addr_r  <= 0;
            empty_r         <= 1;  // All slots free
            full_r          <= 0;  // Not full
        end
        else begin
            free_slots      <= free_slots_n;
            // Register the precomputed first available slot for next acquisition.
            acquire_addr_r  <= free_index;
            // Update empty and full flags based on the new state of free_slots.
            empty_r         <= (free_slots == {SIZE{1'b1}});
            full_r          <= (free_slots == 0);
        end
    end
    
    // Drive outputs.
    assign acquire_addr = acquire_addr_r;
    assign empty        = empty_r;
    assign full         = full_r;
    
endmodule

// The following module is provided for the Leading Zero Count functionality.
module cvdp_leading_zero_cnt #(
    parameter DATA_WIDTH = 32,
    parameter REVERSE = 0 
)(
    input  [DATA_WIDTH -1:0] data,
    output [$clog2(DATA_WIDTH)-1:0] leading_zeros,
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
        for (i=0; i < NIBBLES_NUM ; i=i+1) begin
            if (REVERSE) begin
                always @* begin
                        zeros_cnt_per_nibble[i][1] = ~(data_per_nibble[i][1] | data_per_nibble[i][0]); 
                        zeros_cnt_per_nibble[i][0] = (~data_per_nibble[i][0]) &
                                                      ((~data_per_nibble[i][2]) | data_per_nibble[i][1]);
                        all_zeros_flag[i] = (data_per_nibble[i] == 4'b0000);
                end
            end else begin
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