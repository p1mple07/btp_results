`define NOTCONNECTED_PIN(x) /* ... */

module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr"             ,
    parameter MSHR_SIZE                     = 32                    ,
    parameter CS_LINE_ADDR_WIDTH            = 10                    ,
    parameter WORD_SEL_WIDTH                = 4                     ,
    parameter WORD_SIZE                     = 4                     ,
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE)     ,
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH+ $clog2(WORD_SIZE) + WORD_SEL_WIDTH),
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8 ,
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH
    );

(* SystemVerilog syntax for parameters *)

reg clk;
reg reset;

input wire allocate_valid,
        allocate_addr[CS_LINE_ADDR_WIDTH-1:0],
        allocate_data[DATA_WIDTH-1:0],
        allocate_rw,
        allocate_id[MSHR_ADDR_WIDTH-1:0],
        allocate_pending,
        allocate_previd[MSHR_ADDR_WIDTH-1:0],
        finalize_valid,
        finalize_id[MSHR_ADDR_WIDTH-1:0];

output wire allocate_ready,
        allocate_pending,
        allocate_previd[MSHR_ADDR_WIDTH-1:0];

output reg [MSHR_ADDR_WIDTH-1:0] allocate_id;
output reg [MSHR_ADDR_WIDTH-1:0] allocate_prev_id;
output reg [MSHR_ADDR_WIDTH-1:0] allocate_ready;

output reg [DATA_WIDTH-1:0] entry_data;
reg [MSHR_ADDR_WIDTH-1:0] cache_line_addr;

// Internal signals
reg [DATA_WIDTH-1:0] entry_data_in;
reg [MSHR_ADDR_WIDTH-1:0] index;
reg [1:0] next_ptr;
reg [1:0] prev_ptr;

always @(*) begin
    index = 0;
    for (int i = 0; i < MSHR_SIZE; i = i + 1) begin
        next_ptr = i + 1;
        prev_ptr = i;
        index = i;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk <= 0;
        next_ptr <= 0;
        prev_ptr <= 0;
        index <= 0;
    end else begin
        if (allocate_valid) begin
            if (head == 0) begin
                // Allocate first available slot
                head <= index;
                next_ptr <= 0;
                prev_ptr <= 0;
                index <= 0;
                allocate_ready = 1;
                allocate_pending = 0;
                allocate_previd <= 0;
            end else begin
                // Find the first free entry after head
                index = head;
                while (next_ptr != 0 && index != head) begin
                    index = next_ptr;
                    next_ptr = next_ptr + 1;
                end
                if (index != 0) begin
                    // Insert between head and next_ptr
                    // Need to adjust pointers
                    next_ptr = index;
                    prev_ptr = head;
                    head = index;
                    next_ptr = index + 1;
                    index = 0;
                end else begin
                    // No free slot, overflow?
                end
            end

            // Set entry data
            entry_data = allocate_data;
            // etc.
        end else begin
            allocate_ready = 0;
            allocate_pending = 1;
            allocate_previd <= index;
        end
    end
end

// Provide outputs
assign allocate_id = head;
assign allocate_prev_id = prev_ptr;
assign allocate_ready = 1;
assign allocate_pending = 0;
assign allocate_previd = 0;

endmodule
