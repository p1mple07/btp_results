module virtual2physical_tlb #(parameter ADDR_WIDTH = 8, PAGE_WIDTH = 8, TLB_SIZE = 4, PAGE_TABLE_SIZE = 16) (
    input clk,
    input reset,
    input [ADDR_WIDTH-1:0] virtual_address,
    output [PAGE_WIDTH-1:0] physical_address,
    output hit, miss
);
    wire tlb_write_enable, flush, ready;
    wire [PAGE_WIDTH-1:0] page_table_entry;
    
    // Instantiate the TLB module
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

    // Instantiate the Page Table Handler module
    PageTableHandler #(.ADDR_WIDTH(ADDR_WIDTH), .PAGE_WIDTH(PAGE_WIDTH), .PAGE_TABLE_SIZE(PAGE_TABLE_SIZE)) page_table_handler(
        .clk(clk),
        .reset(reset),
        .miss(miss),
        .virtual_page(virtual_address),
        .page_table_entry(page_table_entry),
        .ready(ready)
    );

    // Instantiate the Control Unit module
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
    // TLB Storage arrays
    reg [ADDR_WIDTH-1:0] virtual_tags[TLB_SIZE-1:0];
    reg [PAGE_WIDTH-1:0] physical_pages[TLB_SIZE-1:0];
    reg [TLB_SIZE-1:0] valid_bits;
    reg [$clog2(TLB_SIZE)-1:0] replacement_index; // Index for the next replacement
    integer i;

    // Sequential block: update TLB entries on write enable or flush
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < TLB_SIZE; i = i + 1) begin
                valid_bits[i] <= 1'b0;
                virtual_tags[i] <= {ADDR_WIDTH{1'b0}};
                physical_pages[i] <= {PAGE_WIDTH{1'b0}};
            end
            replacement_index <= 0;
        end
        else if (flush) begin
            // Flush: Invalidate all TLB entries
            for (i = 0; i < TLB_SIZE; i = i + 1) begin
                valid_bits[i] <= 1'b0;
                virtual_tags[i] <= {ADDR_WIDTH{1'b0}};
                physical_pages[i] <= {PAGE_WIDTH{1'b0}};
            end
        end
        else if (tlb_write_enable) begin
            // Update TLB entry using a simple round-robin replacement policy
            virtual_tags[replacement_index] <= virtual_address;
            physical_pages[replacement_index] <= page_table_entry;
            valid_bits[replacement_index] <= 1'b1;
            replacement_index <= (replacement_index + 1) % TLB_SIZE;
        end
    end

    // Combinational block: Check for a TLB hit
    always_comb begin
        hit = 1'b0;
        miss = 1'b1;
        physical_address = {PAGE_WIDTH{1'b0}};
        for (i = 0; i < TLB_SIZE; i = i + 1) begin
            if (valid_bits[i] && (virtual_tags[i] == virtual_address)) begin
                hit = 1'b1;
                miss = 1'b0;
                physical_address = physical_pages[i];
                break;
            end
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
    // Parameterized Page Table Memory (ROM-like)
    reg [PAGE_WIDTH-1:0] page_table_memory [0:PAGE_TABLE_SIZE-1];
    
    // Combinational assignment to simulate memory lookup
    assign page_table_entry = page_table_memory[virtual_page];
    
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
            ready <= 1'b0;
        end
        else if (miss) begin
            // On a TLB miss, simulate fetching the page table entry.
            // Assume the entry is ready immediately.
            ready <= 1'b1;
        end
        else begin
            ready <= 1'b0;
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
    
    localparam IDLE   = 2'b00,
               FETCH  = 2'b01,
               UPDATE = 2'b10;

    // Simple state machine to manage TLB updates on a miss.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tlb_write_enable <= 1'b0;
            flush <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (miss) begin
                        state <= FETCH;
                        tlb_write_enable <= 1'b0;
                        flush <= 1'b0;
                    end
                    else begin
                        state <= IDLE;
                        tlb_write_enable <= 1'b0;
                        flush <= 1'b0;
                    end
                end
                FETCH: begin
                    if (ready) begin
                        state <= UPDATE;
                        tlb_write_enable <= 1'b1; // Assert write enable to update TLB
                        flush <= 1'b0;
                    end
                    else begin
                        state <= FETCH;
                        tlb_write_enable <= 1'b0;
                        flush <= 1'b0;
                    end
                end
                UPDATE: begin
                    state <= IDLE;
                    tlb_write_enable <= 1'b0;
                    flush <= 1'b0;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule