`define NOTCONNECTED_PIN(x) /* verilator lint_off PINCONNECTEMPTY */ \
  . x () /* verilator lint_on PINCONNECTEMPTY */

module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr"             ,
    parameter MSHR_SIZE                     = 32                    ,
    parameter CS_LINE_ADDR_WIDTH            = 10                    ,
    parameter WORD_SEL_WIDTH                = 4                     ,
    parameter WORD_SIZE                     = 4                     ,
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE)     ,
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH+ $clog2(WORD_SIZE) + WORD_SEL_WIDTH),
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8 ,
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH // default =  4 + 4 + 32 + 16 = 56

) (
    input wire clk,
    input wire reset,

    // allocate
    input wire                          allocate_valid,
    output wire                         allocate_ready,
    input wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
    input wire                          allocate_rw,
    input wire [DATA_WIDTH-1:0]         allocate_data,
    output wire [MSHR_ADDR_WIDTH-1:0]   allocate_id,
    output wire                         allocate_pending,
    output wire [MSHR_ADDR_WIDTH-1:0]   allocate_previd,

    // finalize
    input wire                          finalize_valid,
    input wire [MSHR_ADDR_WIDTH-1:0]    finalize_id
);

    // Internal state variables
    logic [MSHR_ADDR_WIDTH-1:0] index;
    logic [1:0] next_ptr;
    logic [1:0] prev_ptr;
    logic [MSHR_ADDR_WIDTH-1:0] next_ptr_list;
    logic [MSHR_ADDR_WIDTH-1:0] prev_prev_ptr;
    logic [MSHR_ADDR_WIDTH-1:0] next_idx;
    logic [MSHR_ADDR_WIDTH-1:0] prev_idx;

    // Initialize linked list
    always @(posedge clk) begin
        if (reset) begin
            index <= 0;
            next_ptr <= 0;
            prev_ptr <= 0;
            next_ptr_list <= 0;
            prev_prev_ptr <= 0;
            next_idx <= 0;
            prev_idx <= 0;
        end else begin
            next_ptr <= index;
            prev_ptr <= (index == 0 ? 0 : index - 1);
        end
    end

    // Allocate logic
    always @(assignable allocate_valid) begin
        if (allocate_valid && !allocate_ready) begin
            // find first free slot
            if (index == 0) begin
                index = 1;
                allocate_id[0] = 1'b0;
                allocate_pending[0] = 1'b1;
                allocate_previd[0] = 0;
                allocate_rw[0] = 1'b1;
                allocate_data[0] = 56'h0;
                allocate_ready[0] = 1'b1;
                next_ptr[0] = 1;
                prev_ptr[0] = 0;
            end
        end else begin
            allocate_ready = 0;
            allocate_pending = 0;
            allocate_previd[0] = 0;
            allocate_rw[0] = 1'b0;
            allocate_data[0] = 56'h0;
            allocate_ready[0] = 1'b0;
            next_ptr[0] = 0;
            prev_ptr[0] = 0;
        end
    end

    assign allocate_id = index;
    assign allocate_pending = 1'b1;
    assign allocate_rw = 1'b0;
    assign allocate_data = 56'h0;
    assign allocate_ready = 1'b1;
    assign next_ptr = 1'b1;
    assign prev_ptr = 0;

endmodule
