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
        parameter DATA_WIDTH = 32,
        parameter REVERSE = 0
    ) free_slots_sel (
        .data   (free_slots_n),
        .leading_zeros  (free_index),
        .all_zeros (full_d)
    ); 

    initial begin
        // Initialize free_slots to all 1s
        for (int i = 0; i < SIZE; i++) begin
            free_slots[i] = 1'b1;
        end

        // Initial reset handling
        if (~reset) begin
            for (int i = 0; i < SIZE; i++) begin
                free_slots[i] = 1'b0;
            end
        end

        // Clock sensitive blocks
        always @(posedge clk) begin
            if (reset) begin
                for (int i = 0; i < SIZE; i++) begin
                    free_slots[i] = 1'b1;
                end
            end else begin
                free_slots_n = free_slots;
                free_slots = 0;
            end
        end

        // Find first free slot
        always @(posedge clk) begin
            free_index = -1;
            for (int i = 0; i < SIZE; i++) begin
                if (free_slots[i] == 1'b1) begin
                    free_index = i;
                    break;
                end
            end
        end

        // Outputs
        assign acquire_addr = free_index ? free_index : 0;
        assign empty = (free_slots == 1'b0);
        assign full = (!empty);
    end

endmodule
