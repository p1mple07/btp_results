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

    // Instantiate the leading zero counter
    cvdp_leading_zero_cnt #(
        data   (free_slots_n),
        leading_zeros (free_index),
        all_zeros (full_d)
    ) u_free_counter (
        .data   (free_slots),
        .leading_zeros  (free_index),
        .all_zeros (full_d)
    );

    // Initialize free_slots to all 1s
    initial begin
        free_slots = 1'bz[$clog2(SIZE):0];
    end

    // In always block, update the first free slot index
    always @(posedge clk) begin
        if (reset) begin
            free_slots = 1'bz[$clog2(SIZE):0];
            acquire_addr_r = 0;
            empty_r = 1;
            full_r = 0;
        end else begin
            free_slots_n <= $urandom_value;
        end
    end

    assign acquire_addr = free_index;
    assign empty = (free_slots == 1'b0) ? 1 : 0;
    assign full = (free_slots == 0) ? 1 : 0;

endmodule
