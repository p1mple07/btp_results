`define NOTCONNECTED_PIN(x) /* verilator lint_off PINCONNECTEMPTY */ . x () /* verilator lint_on PINCONNECTEMPTY */

module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr"             ,
    parameter MSHR_SIZE                     = 32                    ,
    parameter CS_LINE_ADDR_WIDTH            = 10                    ,
    parameter WORD_SEL_WIDTH                = 4                     ,
    parameter WORD_SIZE                     = 4                     ,
    // Derived parameters
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE)     , // default = 5
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH+ $clog2(WORD_SIZE) + WORD_SEL_WIDTH), // default = 16
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8 ,// default = 32 
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH // default =  4 + 4 + 32 + 16 = 56

    ) (
    input wire clk,
    input wire reset,

    // allocate
    input wire allocate_valid,
    output wire allocate_ready,
    input wire [CS_LINE_ADDR_WIDTH-1:0] allocate_addr,
    input wire allocate_rw,
    input wire [DATA_WIDTH-1:0] allocate_data,
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_id,
    output wire allocate_pending,
    output wire [MSHR_ADDR_WIDTH-1:0] allocate_previd,

    // finalize
    input wire finalize_valid,
    input wire [MSHR_ADDR_WIDTH-1:0] finalize_id
);

    localparam MSHR_ENTRIES = MSHR_SIZE;
    localparam FREE_BITS = $clog2(MSHR_ENTRIES);
    reg [FREE_BITS-1:0] free_index;
    reg [FREE_BITS-1:0] next_free_index;
    reg [FREE_BITS-1:0] prev_free_index;
    reg [FREE_BITS-1:0] current_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            free_index <= 0;
            next_free_index <= 0;
            prev_free_index <= 0;
            current_index <= 0;
        end else begin
            // Find the first free index
            if (allocate_valid) begin
                free_index <= 0;
            end else begin
                if (allocate_pending) begin
                    free_index <= next_free_index;
                end else if (allocate_valid) begin
                    free_index <= 0;
                end
            end
        end
    end

    assign allocate_ready = (allocate_valid && allocate_ready);

    assign allocate_pending = (allocate_valid && !allocate_ready);

    assign allocate_previd = (allocate_pending) ? prev_free_index : 0;

    assign allocate_id = free_index;

    assign allocate_addr = allocate_addr;
    assign allocate_data = allocate_data;
    assign allocate_rw = allocate_rw;

    assign finalize_valid = (finalize_valid && finalize_id);

    assign finalize_id = finalize_id;

endmodule
