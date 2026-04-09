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
        .DATA_WIDTH (DATA_WIDTH)
    ) free_slots_sel (
        .data   (free_slots_n),
        .leading_zeros  (free_index),
        .all_zeros (full_d)
    ); 
    
    // Memory allocation logic
    always @(posedge clk) begin
        if (reset) begin
            free_slots <= (SIZE-1:0) << 1; // Initialize all slots to free
            acquire_addr_r <= (SIZE-1:0) << 1; // Initialize acquire_addr to indicate first slot
            empty_r <= 1; // All slots are initially free
            full_r <= 0; // No slots are initially full
        end else begin
            if (acquire_en) begin
                acquire_addr_r <= free_index;
                free_slots_n <= free_slots_n ^ (acquire_addr_r); // Mark slot as allocated
                free_slots <= free_slots_n;
                empty_r <= 0; // At least one slot is now occupied
                full_r <= (SIZE == (free_slots_n & ((1 << (ADDRW-1)) - 1)) ? 1 : 0); // Check if all slots are full
            end
            if (release_en) begin
                free_slots_n <= free_slots_n ^ (release_addr); // Mark slot as free
                free_slots <= free_slots_n;
                if (free_slots_n == (SIZE-1:0) << 1) begin
                    empty_r <= 0; // No more free slots
                    full_r <= 1; // All slots are now full
                end
            end
        end
    end

endmodule
