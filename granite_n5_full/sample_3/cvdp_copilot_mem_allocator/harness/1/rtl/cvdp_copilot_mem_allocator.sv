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
    reg [SIZE-1:0] free_slots, free_slots_n;
    reg [ADDRW-1:0] acquire_addr_r;
    reg empty_r, full_r;    
    wire [ADDRW-1:0] free_index;
    wire full_d;
    
    /* Leading zero counter instantiation */
    cvdp_leading_zero_cnt #(
       .DATA_WIDTH(SIZE), 
       .REVERSE(0)
    ) free_slots_sel (
       .data   (free_slots_n),
       .leading_zeros  (free_index),
       .all_zeros (full_d)
    ); 

    //Insert Code here for memory allocation logic

endmodule

module cvdp_leading_zero_cnt #(
    parameter DATA_WIDTH = 32,
    parameter REVERSE = 0 
)(
    input  [DATA_WIDTH -1:0] data,
    output [log2(DATA_WIDTH)-1:0] leading_zeros,
    output all_zeros 
);
    localparam NIBBLES_NUM = DATA_WIDTH/4 ; 
    reg [NIBBLES_NUM-1 :0] all_zeros_flag ;
    reg [NIBBLES_NUM-1 :0] data_per_nibble [NIBBLES_NUM-1 :0]  ;
    reg [1:0]  zeros_cnt_per_nibble [NIBBLES_NUM-1 :0]  
    reg [1:0]  choosen_nibbles_zeros_count 
    reg [1:0] zeros_count_result 
    reg [ $clog2(NIBBLES_NUM*4 -1 :0]  choosen_nibbles_zeros_count 
    reg [1:0]  zeros_count_result 
    assign leading_zeros = zeros_count_result 
    assign all_zeros = (data == 0 

endmodule