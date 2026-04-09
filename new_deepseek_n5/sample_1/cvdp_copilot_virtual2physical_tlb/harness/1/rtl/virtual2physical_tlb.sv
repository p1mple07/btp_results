module virtual2physical_tlb #(parameter ADDR_WIDTH = 8, PAGE_WIDTH = 8, TLB_SIZE = 4, PAGE_TABLE_SIZE = 16) (
    input clk,
    input reset,
    input [ADDR_WIDTH-1:0] virtual_address,
    output [PAGE_WIDTH-1:0] physical_address,
    output hit, miss
);
    wire tlb_write_enable, flush, ready;
    wire [PAGE_WIDTH-1:0] page_table_entry;
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

    PageTableHandler #(.ADDR_WIDTH(ADDR_WIDTH), .PAGE_WIDTH(PAGE_WIDTH), .PAGE_TABLE_SIZE(PAGE_TABLE_SIZE)) page_table_handler(
        .clk(clk),
        .reset(reset),
        .miss(miss),
        .virtual_page(virtual_address),
        .page_table_entry(page_table_entry),
        .ready(ready)
    );

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
    // TLB Storage
    reg [ADDR_WIDTH-1:0] virtual_tags[TLB_SIZE-1:0];
    reg [PAGE_WIDTH-1:0] physical_pages[TLB_SIZE-1:0];
    reg [TLB_SIZE-1:0] valid_bits;
    reg [log2(TLB_SIZE)-1:0] replacement_index;
    integer i;

    always_comb begin
        hit = 0;
        miss = 1;
        physical_address = 0;

        // Track valid entries
        valid_bits = (8'h00000000 | 
            (8'h10000000 & valid_bits) << 1 | 
            (8'h01000000 & valid_bits) << 2 | 
            (8'h00100000 & valid_bits) << 3 | 
            (8'h00010000 & valid_bits) << 4 | 
            (8'h00001000 & valid_bits) << 5 | 
            (8'h00000100 & valid_bits) << 6 | 
            (8'h00000010 & valid_bits) << 7 | 
            (8'h00000001 & valid_bits) << 8);

        // Check for match
        hit = 1;
        miss = 0;
        physical_address = page_table_entry;

        // Update TLB with new page
        if (valid_bits == 0) begin
            replacement_index = 0;
            virtual_tags[replacement_index] = virtual_address[4:0];
            physical_pages[replacement_index] = page_table_entry;
            valid_bits = 8'h10000000;
            tlb_write_enable = 1;
            flush = 1;
            i = 0;
        else begin
            // Find least recently used
            replacement_index = 0;
            for (i = 0; i < 8; i = i + 1) begin
                if ((valid_bits & (1 << i)) == 0) begin
                    replacement_index = i;
                    break;
                end
            end

            // Update TLB
            virtual_tags[replacement_index] = virtual_address[4:0];
            physical_pages[replacement_index] = page_table_entry;
            valid_bits = valid_bits ^ (1 << replacement_index);
            tlb_write_enable = 1;
            flush = 1;
        end
    end
endmodule

module PageTableHandler #(parameter ADDR_WIDTH = 8, PAGE_WIDTH = 8, PAGE_TABLE_SIZE = 16) (
    input clk,
    input reset,
    input miss,
    input [ADDR_WIDTH-1:0] virtual_page,
    output reg [PAGE_WIDTH-1:0] page_table_entry,
    output reg ready
);
    // Parameterized Page Table Memory
    reg [PAGE_WIDTH-1:0] page_table_memory [0:PAGE_TABLE_SIZE-1];
 assign   page_table_entry = page_table_memory[virtual_page];  
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize Page Table Memory during reset
            page_table_memory[0] <= 8'h0;
            page_table_memory[1] <= 8'h1;
            page_table_memory[2] <= 8'h2;
            page_table_memory[3] <= 8'h3;  
            page_table_memory[4] <= 8'h4;
            page_table_memory[5] <= 8'h5;
            page_table_memory[6] <= 8'h6;
            page_table_memory[7] <= 8'h7;
            page_table_memory[8] <= 8'h8;  
            page_table_memory[9] <= 8'h9;
            page_table_memory[10] <= 8'hA;
            page_table_memory[11] <= 8'hB;  
            page_table_memory[12] <= 8'hC;
            page_table_memory[13] <= 8'hD;
            page_table_memory[14] <= 8'hE;
            page_table_memory[15] <= 8'hF;          
            ready <= 0;
        end else if (miss) begin
            // Fetch the physical page number from the simulated page table         
            ready <= 1; // Indicate the entry is ready
        end else begin
            ready <= 0;
        end
    end
endmodule

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
    
    localparam IDLE = 2'b00,
               FETCH = 2'b01,
               UPDATE = 2'b10;

    always begin
        if (reset) begin
            state = IDLE;
        end else if (hit) begin
            state = FETCH;
        end else if (miss) begin
            state = UPDATE;
        end else begin
            state = IDLE;
        end
    end

    case(state)
        IDLE:
            // No action needed
            tlb_write_enable = 0;
            flush = 0;
            break;
        FETCH:
            // Fetch physical address from TLB
            tlb_write_enable = 0;
            flush = 0;
            break;
        UPDATE:
            // Write new entry to TLB
            tlb_write_enable = 1;
            flush = 0;
            break;
    endcase
endmodule