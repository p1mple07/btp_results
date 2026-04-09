`define NOTCONNECTED_PIN(x)   /* verilator lint_off PINCONNECTEMPTY */ \
                        . x () \
                        /* verilator lint_on PINCONNECTEMPTY */

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

    localparam NUM_ENTRIES = MSHR_SIZE;
    reg [NUM_ENTRIES-1:0] index;
    reg [1:0] chosen_nibbles_zeros_count;
    reg [NUM_ENTRIES-1:0] free_indices;

    initial begin
        free_indices = {};
        for (int i = 0; i < NUM_ENTRIES; i++) begin
            index.assign(i);
            free_indices.append(i);
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < NUM_ENTRIES; i++) begin
                index.assign(0);
                free_indices.append(i);
            end
        end else begin
            // allocate the first free index
            if (!free_indices.empty()) begin
                int first_free = free_indices[0];
                index.assign(first_free);
                free_indices = free_indices.slice(1);
                // allocate_id, etc.
                allocate_id[MSHR_ADDR_WIDTH-1:0] = first_free;
                allocate_pending[MSHR_ADDR_WIDTH-1:0] = 1'b1;
                allocate_previd[MSHR_ADDR_WIDTH-1:0] = 0;
                allocate_ready[MSHR_ADDR_WIDTH-1:0] = 1'b1;
            end else begin
                allocate_ready[MSHR_ADDR_WIDTH-1:0] = 1'b0;
            end
        end
    end

    always @(*) begin
        allocate_ready = (allocate_valid && free_indices.any());
        allocate_pending = allocate_valid && (allocate_pending);
        allocate_previd = if (allocate_pending) {
            free_indices[0]
        } else {
            0
        };
        allocate_id = allocate_id;
    end

    assign allocate_valid = true;

endmodule
