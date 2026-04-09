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

    // Leading zero counter module
    cvdp_leading_zero_cnt #(
        parameter DATA_WIDTH = 32,
        parameter REVERSE = 0
    ) free_slots_sel (
        .data   (free_slots_n),
        .leading_zeros  (free_index),
        .all_zeros (full_d)
    ); 

    // Reset on positive edge
    initial begin
        reset = 1;
        #5 reset = 0;
        // Initialize free_slots to all 1s
        free_slots = 1 {SIZE};
    end

    // Always block for acquiring
    always @(posedge clk) begin
        if (acquire_en) begin
            acquire_addr <= free_slots_n;
            free_slots[acquire_addr] <= 1'b0;
        end
    end

    // Always block for releasing
    always @(posedge clk) begin
        if (release_en) begin
            free_slots[release_addr] <= 1'b1;
        end
    end

    // Compute empty and full
    assign empty = ~full_d;
    assign full = ~empty;

    assign free_index = free_slots_sel.leading_zeros;

    assign acquire_addr = free_slots_n;

endmodule
