module virtual2physical_tlb #(parameter ADDR_WIDTH = 8, PAGE_WIDTH = 8, TLB_SIZE = 4, PAGE_TABLE_SIZE = 16) (
    input clk,
    input reset,
    input [ADDR_WIDTH-1:0] virtual_address,
    output [PAGE_WIDTH-1:0] physical_address,
    output hit, miss
);
    wire tlb_write_enable, flush, ready;
    wire [PAGE_WIDTH-1:0] page_table_entry;
    
    // Instantiate TLB module
    TLB #(.TLB_SIZE(TLB_SIZE), .ADDR_WIDTH(ADDR_WIDTH), .PAGE_WIDTH(PAGE_WIDTH)) tlb (
        .clk(clk),
        .reset(reset),
        .virtual_address(virtual_address),
        .tlb_write_enable(tlb_write_enable),
        .flush(flush),
        .page_table_entry(page_table_entry),
        .physical_address(physical_address),
        .hit(hit),
        .miss(miss)
    );

    // Instantiate Page Table Handler
    PageTableHandler #(.ADDR_WIDTH(ADDR_WIDTH), .PAGE_WIDTH(PAGE_WIDTH), .PAGE_TABLE_SIZE(PAGE_TABLE_SIZE)) page_table_handler(
        .clk(clk),
        .reset(reset),
        .miss(miss),
        .virtual_page(virtual_address),
        .page_table_entry(page_table_entry),
        .ready(ready)
    );

    // Instantiate Control Unit
    ControlUnit control_unit (
        .clk(clk),
        .reset(reset),
        .hit(hit),
        .miss(miss),
        .ready(ready),
        .tlb_write_enable(tlb_write_enable),
        .flush(flush)
    );
endmodule

// -------------------------------------------------------------------
// TLB Module: Implements a small cache of virtual-to-physical translations.
// Supports hit/miss detection, dynamic entry replacement (round-robin),
// and flush functionality.
// -------------------------------------------------------------------
module TLB #(parameter TLB_SIZE = 4, ADDR_WIDTH = 8, PAGE_WIDTH = 8) (
    input clk,
    input reset,
    input [ADDR_WIDTH-1:0] virtual_address,
    input tlb_write_enable,
    input flush,
    input [PAGE_WIDTH-1:0] page_table_entry,
    output reg [PAGE_WIDTH-1:0] physical_address,
    output reg hit,
    output reg miss
);
    // Storage arrays for virtual tags and physical pages
    reg [ADDR_WIDTH-1:0] virtual_tags[TLB_SIZE-1:0];
    reg [PAGE_WIDTH-1:0] physical_pages[TLB_SIZE-1:0];
    reg valid_bits[TLB_SIZE-1:0];
    // Replacement index for round-robin update
    reg [$clog2(TLB_SIZE)-1:0] replacement_index;
    integer i;

    // Combinational block: Check for a TLB hit by comparing virtual address tags.
    always_comb begin
        hit = 1'b0;
        miss = 1'b1;
        physical_address = {PAGE_WIDTH{1'b0}};
        for (i = 0; i < TLB_SIZE; i = i + 1) begin
            if (valid_bits[i] && (virtual_tags[i] == virtual_address)) begin
                hit = 1'b1;
                miss = 1'b0;
                physical_address = physical_pages[i];
            end
        end
    end

    // Sequential block: Update the TLB on write enable or flush.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Invalidate all entries on reset.
            for (i = 0; i < TLB_SIZE; i = i + 1) begin
                valid_bits[i] <= 1'b0;
                virtual_tags[i] <= {ADDR_WIDTH{1'b0}};
                physical_pages[i] <= {PAGE_WIDTH{1'b0}};
            end
            replacement_index <= 0;
        end else begin
            if (flush) begin
                // Flush all TLB entries.
                for (i = 0; i < TLB_SIZE; i = i + 1) begin
                    valid_bits[i] <= 1'b0;
                    virtual_tags[i] <= {ADDR_WIDTH{1'b0}};
                    physical_pages[i] <= {PAGE_WIDTH{1'b0}};
                end
                replacement_index <= 0;
            end else if (tlb_write_enable) begin
                // Update the entry at the current replacement index.
                physical_pages[replacement_index] <= page_table_entry;
                virtual_tags[replacement_index] <= virtual_address;
                valid_bits[replacement_index] <= 1'b1;
                // Move to the next index (round-robin replacement).
                replacement_index <= (replacement_index + 1) % TLB_SIZE;
            end
        end
    end
endmodule

// -------------------------------------------------------------------
// Page Table Handler: Simulates a page table memory access.
// On a TLB miss, it retrieves the corresponding page table entry.
// -------------------------------------------------------------------
module PageTableHandler #(parameter ADDR_WIDTH = 8, PAGE_WIDTH = 8, PAGE_TABLE_SIZE = 16) (
    input clk,
    input reset,
    input miss,
    input [ADDR_WIDTH-1:0] virtual_page,
    output reg [PAGE_WIDTH-1:0] page_table_entry,
    output reg ready
);
    // Simulated page table memory (for simulation purposes)
    reg [PAGE_WIDTH-1:0] page_table_memory [0:PAGE_TABLE_SIZE-1];
    
    // Combinational assignment for page table lookup.
    assign page_table_entry = page_table_memory[virtual_page];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize page table memory on reset.
            page_table_memory[0] <= 8'h00;
            page_table_memory[1] <= 8'h01;
            page_table_memory[2] <= 8'h02;
            page_table_memory[3] <= 8'h03;
            page_table_memory[4] <= 8'h04;
            page_table_memory[5] <= 8'h05;
            page_table_memory[6] <= 8'h06;
            page_table_memory[7] <= 8'h07;
            page_table_memory[8] <= 8'h08;
            page_table_memory[9] <= 8'h09;
            page_table_memory[10] <= 8'h0A;
            page_table_memory[11] <= 8'h0B;
            page_table_memory[12] <= 8'h0C;
            page_table_memory[13] <= 8'h0D;
            page_table_memory[14] <= 8'h0E;
            page_table_memory[15] <= 8'h0F;
            ready <= 1'b0;
        end else if (miss) begin
            // Simulate memory access delay; in a real design, ready would be asserted after a delay.
            ready <= 1'b1;
        end else begin
            ready <= 1'b0;
        end
    end
endmodule

// -------------------------------------------------------------------
// Control Unit: Manages the state transitions for TLB miss handling,
// page table retrieval, and TLB update.
// -------------------------------------------------------------------
module ControlUnit (
    input clk,
    input reset,
    input hit,
    input miss,
    input ready,
    output reg tlb_write_enable,
    output reg flush
);
    reg [1:0] state;
    
    localparam IDLE   = 2'b00,
               FETCH  = 2'b01,
               UPDATE = 2'b10;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tlb_write_enable <= 1'b0;
            flush <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    // Stay idle if hit; if miss, move to FETCH state.
                    if (miss) begin
                        state <= FETCH;
                    end
                    tlb_write_enable <= 1'b0;
                    flush <= 1'b0;
                end
                FETCH: begin
                    // Wait until the page table entry is ready.
                    if (ready) begin
                        state <= UPDATE;
                    end
                    tlb_write_enable <= 1'b0;
                    flush <= 1'b0;
                end
                UPDATE: begin
                    // Enable TLB write to update the TLB with the new page table entry.
                    tlb_write_enable <= 1'b1;
                    state <= IDLE;
                    flush <= 1'b0;
                end
                default: begin
                    state <= IDLE;
                    tlb_write_enable <= 1'b0;
                    flush <= 1'b0;
                end
            endcase
        end
    end
endmodule