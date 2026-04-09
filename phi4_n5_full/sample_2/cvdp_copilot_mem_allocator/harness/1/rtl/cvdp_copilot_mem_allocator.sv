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
    // Register to hold current free slot bitmap
    reg [SIZE-1:0] free_slots, free_slots_n;
    // Registered output for next available address
    reg [ADDRW-1:0] acquire_addr_r;
    // Registered empty and full flags
    reg empty_r, full_r;    
    
    // Wire from leading zero counter: computes the index of the first free slot
    wire [ADDRW-1:0] free_index;
    // The leading zero counter also provides an "all zeros" flag (not used further)
    wire full_d;
    
    // Instantiate the leading zero counter.
    // DATA_WIDTH is set to SIZE so that it operates on the free_slots_n bitmap.
    cvdp_leading_zero_cnt #(
        .DATA_WIDTH(SIZE),
        .REVERSE(0)
    ) free_slots_sel (
        .data       (free_slots_n),
        .leading_zeros(free_index),
        .all_zeros  (full_d)
    ); 

    // Sequential process: update free_slots, acquire_addr, empty and full signals
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // On reset: mark all slots as free, set acquire_addr to 0,
            // and indicate that the pool is empty and not full.
            free_slots     <= {SIZE{1}};
            acquire_addr_r <= 0;
            empty_r        <= 1;
            full_r         <= 0;
        end else begin
            // Default: carry forward the current free_slots
            free_slots_n = free_slots;
            
            // If an allocation request is asserted, clear the free slot indicated
            // by the current acquire_addr (which reflects the previous cycle's free_index).
            if (acquire_en) begin
                free_slots_n = free_slots_n & ~(1 << acquire_addr_r);
            end
            
            // If a release request is asserted, mark the corresponding slot as free.
            if (release_en) begin
                free_slots_n = free_slots_n | (1 << release_addr);
            end
            
            // Register the updated free_slots for the next cycle.
            free_slots <= free_slots_n;
            
            // Update the acquire_addr output register with the new first available slot.
            // The leading zero counter computes free_index combinationally from free_slots_n.
            acquire_addr_r <= free_index;
            
            // Update the empty and full flags based on the registered free_slots.
            // The allocator is empty when all bits are 1, and full when no bits are 1.
            empty_r <= (free_slots == {SIZE{1}});
            full_r  <= (free_slots == 0);
        end
    end

    // Drive the output signals.
    assign acquire_addr = acquire_addr_r;
    assign empty        = empty_r;
    assign full         = full_r;

endmodule