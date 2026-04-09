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
    
    cvdp_leading_zero_cnt #(
        .DATA_WIDTH (SIZE),
        .REVERSE (0)
    ) free_slots_sel (
        .data   (free_slots_n),
        .leading_zeros  (free_index),
        .all_zeros (full_d)
    ); 
    
    reg [SIZE-1:0] free_slots_copy;
    always @(posedge clk) begin
        if (reset) begin
            free_slots_copy <= {SIZE{1'b1}};
        end else begin
            free_slots_copy <= free_slots;
        end
    end
    
    assign free_slots_n = free_slots_copy;
    
    always @(posedge clk) begin
        if (reset) begin
            acquire_addr_r <= 0;
            empty_r <= 1;
            full_r <= 0;
        end else begin
            acquire_addr_r <= (free_index == 0) ? 0 : free_index;
            empty_r <= (free_slots_copy == {SIZE{1'b1}}) ? 1 : 0;
            full_r <= (free_slots_copy == {SIZE{0}}) ? 1 : 0;
        end
    end
    
    always @(acquire_en, release_en, free_slots_n) begin
        if (acquire_en) begin
            if (free_slots_n[0] == 0) begin
                acquire_addr <= 0;
            end else begin
                acquire_addr <= free_slots_n[0];
            end
        end else if (release_en) begin
            if (release_addr != 0) begin
                free_slots_n[release_addr] = 1;
                acquire_addr <= (free_slots_n == {SIZE{1'b1}}) ? 0 : free_slots_n;
            end
        end
    end
    
endmodule
