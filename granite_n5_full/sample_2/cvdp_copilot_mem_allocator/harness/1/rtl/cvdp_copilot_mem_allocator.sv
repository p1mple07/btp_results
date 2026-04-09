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
    reg [SIZE-1:0] free_slots;
    reg [ADDRW-1:0] acquire_addr_r;
    reg empty_r, full_r;    
    wire [ADDRW-1:0] free_index;
    wire full_d;
    
    /* Leading zero counter instantiation */
    cvdp_leading_zero_cnt #(
       .DATA_WIDTH(SIZE),
       .REVERSE(0)
    ) free_slots_sel (
       .data   (free_slots),
       .leading_zeros  (free_index),
       .all_zeros (full_d)
    ); 

    //Insert Code here for memory allocation logic

    assign leading_zeros = free_index ;
    assign all_zeros = (data ==0) ;

endmodule

module cvdp_leading_zero_cnt #(
    parameter DATA_WIDTH = 32,
    parameter REVERSE = 0 
)(
    input  [DATA_WIDTH-1:0] data,
    output  [$clog2(DATA_WIDTH)-1:0] leading_zeros,
    output all_zeros 
);
    localparam NIBBLES_NUM = DATA_WIDTH/4 ; 
    reg [NIBBLES_NUM-1 :0 ] all_zeros_flag ; 
    reg [1:0 ] zeros_cnt_per_nibble [NIBBLES_NUM-1 :0 ]
    reg [NIBBLES_NUM-1 :0 ] data_per_nibble [NIBBLES_NUM-1 :0 ].
    reg [15:0] acquired_files.txt
    reg [15:0] released_files.txt
    reg [15:0] data.
    reg [15:0] acquired_data.
    reg [15:0] released_data.
    reg [15:0] acquired_data.
    reg [15:0] released_data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] acquired_data.
    reg [15:0] data.
    reg [15:0] acquired_data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.
    reg [15:0] data.

endmodule