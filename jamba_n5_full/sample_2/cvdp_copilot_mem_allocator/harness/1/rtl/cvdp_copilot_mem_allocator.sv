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

    // Leading zero counter
    cvdp_leading_zero_cnt #(
        DATA_WIDTH = $clog2(SIZE),
        REVERSE = 1
    ) free_slots_sel (
        .data   (free_slots_n),
        .leading_zeros  (free_index),
        .all_zeros (full_d)
    ); 

    // Memory allocation logic
    always @(posedge clk) begin
        if (reset) begin
            free_slots = 1'b1;
            free_slots_n = 1'b1;
            acquire_addr_r = 0;
            empty_r = 1;
            full_r = 0;
        end else begin
            if (acquire_en) begin
                // Find first free slot by scanning
                assign free_index = 8'hFFFFFFFF; // max value
                for (int i = 0; i < SIZE; i = i + 1) begin
                    if (free_slots[i] == 1'b1) begin
                        free_index = i;
                        break;
                    end
                end

                // Mark the slot as allocated
                free_slots[free_index] = 1'b0;
                free_slots_n[free_index] = 1'b0;

                // Update free_index for next time
                assign free_index = free_index + 1;
                if (free_index == SIZE) free_index = 0;

                // Update empty and full
                if (free_index == 0) empty_r = 1;
                else empty_r = 0;
                if (free_index == SIZE-1) full_r = 1;
                else full_r = 0;
            end
        end
    end

    assign empty = (full_r) ? 1 : 0;
    assign full = (free_index == 0) ? 1 : 0;

    assign acquire_addr = acquire_addr_r;

endmodule
