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
    
    // Leading zero counter instantiation
    cvdp_leading_zero_cnt #(
        // Parameters for leading zero counter
        DATA_WIDTH = SIZE,
        REVERSE = 0
    ) free_slots_sel (
        .data   (free_slots_n),
        .leading_zeros  (free_index),
        .all_zeros (full_d)
    ); 
    
    // Memory allocation logic
    always @ (posedge clk) begin
        if (reset) begin
            free_slots <= {SIZE{1'b1}}; // All slots free
            acquire_addr_r <= 0; // No available address
            empty_r <= 1; // All slots are free
            full_r <= 0; // No slots fully occupied
        end else begin
            if (acquire_en) begin
                free_slots_n <= free_slots ^ (release_addr[ADDRW-1:0] << (SIZE-1)); // Mark slot as free
                acquire_addr_r <= free_index; // Get next available address
                empty_r <= (free_slots == {SIZE{1'b1}}); // Check if all slots are free
                full_r <= (free_slots == 0); // Check if all slots are occupied
            end
        end
    end
    
    assign acquire_addr = acquire_addr_r;
    assign empty = empty_r;
    assign full = full_r;

endmodule
