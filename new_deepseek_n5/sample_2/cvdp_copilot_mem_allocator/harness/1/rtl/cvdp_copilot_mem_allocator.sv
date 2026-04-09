module cvdp_copilot_mem_allocator #(
    parameter SIZE  = 4,
    parameter ADDRW = $clog2(SIZE)
) (
    input  wire             clk,
    input  wire             reset,
    input  wire             acquire_en,
    input  wire             release_en,
    input  wire [ADDRW-1:0] release_addr,
    
    output wire [ADDRW-1:0] acquire_addr,
    output wire             empty,
    output wire             full    
);
    reg [SIZE-1:0] free_slots, free_slots_n;
    reg [ADDRW-1:0] acquire_addr_r;
    reg empty_r, full_r;    
    wire [ADDRW-1:0] free_index;
    wire full_d;
    
    /* Leading zero counter module instantiation */
    cvdp_leading_zero_cnt #(
        DATA_WIDTH  = SIZE,
        REVERSE     = 0 
    ) free_slots_sel (
        .data   (free_slots_n),
        .leading_zeros  (free_index),
        .all_zeros (full_d)
    ); 
    //Memory allocation logic
    always begin
        if (reset) begin
            free_slots = (1 << SIZE) - 1;
            acquire_addr_r = 0;
            empty_r = 1;
            full_r = 0;
        end else if (acquire_en) begin
            free_index = free_slots_n;
            free_slots_r = free_slots_n ^ (1 << free_index);
        end else if (release_en) begin
            free_slots_n = free_slots_n | (1 << release_addr);
        end
        //Propagate updates
        free_slots_r = free_slots_n;
        acquire_addr_r = free_index;
        empty_r = (free_slots == (1 << SIZE) - 1);
        full_r = (free_slots == 0);
    end
    wire free_slots_r, acquire_addr_r, empty_r, full_r;
endmodule

module cvdp_leading_zero_cnt #(
    parameter DATA_WIDTH = 32,
    parameter REVERSE = 0 
)(
    input  [DATA_WIDTH -1:0] data,
    output  [$clog2(DATA_WIDTH)-1:0] leading_zeros,
    output all_zeros 
);
    // ... (rest of the existing code remains the same) ...
endmodule