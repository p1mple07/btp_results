module cvdp_copilot_mem_allocator #(
    parameter SIZE = 4,
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
        .DATA_WIDTH(SIZE),
        .REVERSE(0)
    ) free_slots_sel (
        .data(free_slots),
        .leading_zeros(free_index),
        .all_zeros(full_d)
    );

    assign free_slots_n = free_slots;

    assign empty = (free_slots == 32'b0) ? 1 : 0;
    assign full = (free_slots == 32'b0) ? 0 : 1;

    assign acquire_addr = free_index;

    always @(posedge clk) begin
        if (acquire_en) begin
            free_slots <= 32'b0;
            free_slots_n <= 0;
            free_index = 0;
        end
    end

    always @(posedge clk) begin
        if (release_en) begin
            free_slots_n <= free_slots_n + 1;
        end
    end

    assign acquire_addr_r = free_slots[0];

endmodule
