
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
        // Insert Code here for declaring parameters
        ) free_slots_sel (
            .data   (free_slots_n),
            .leading_zeros  (free_index),
            .all_zeros (full_d)
        ); 
    //Insert Code here for memory allocation logic
   
    
endmodule
