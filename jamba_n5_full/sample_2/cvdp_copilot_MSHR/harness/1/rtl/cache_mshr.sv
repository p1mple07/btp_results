module cache_mshr #(
    parameter INSTANCE_ID                   = "mo_mshr",
    parameter MSHR_SIZE                     = 32,
    parameter CS_LINE_ADDR_WIDTH            = 10,
    parameter WORD_SEL_WIDTH                = 4,
    parameter WORD_SIZE                     = 4,
    parameter MSHR_ADDR_WIDTH               = $clog2(MSHR_SIZE),
    parameter TAG_WIDTH                     = 32 - (CS_LINE_ADDR_WIDTH + $clog2(WORD_SIZE) + WORD_SEL_WIDTH),
    parameter CS_WORD_WIDTH                 = WORD_SIZE * 8,
    parameter DATA_WIDTH                    = WORD_SEL_WIDTH + WORD_SIZE + CS_WORD_WIDTH + TAG_WIDTH
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

    // Derived parameters
    localparam NIBBLES_NUM = DATA_WIDTH / 4;
    reg [NIBBLES_NUM-1:0] index;
    reg [1:0] chosen_nibbles_zeros_count;
    reg [$clog2(NIBBLES_NUM*4)-1:0] zeros_count_result;
    wire [NIBBLES_NUM-1:0] all_zeros_flag_decoded;

    always @(*) begin
        index = 0;
        for (genvar i = 0; i < NIBBLES_NUM; i = i + 1) begin
            index = index + all_zeros_flag_decoded[i];
        end
    end

    always @(*) begin
        choosen_nibbles_zeros_count = zeros_cnt_per_nibble[index];
        zeros_count_result = choosen_nibbles_zeros_count + (index << 2);
    end

    assign leading_zeros = zeros_count_result;
    assign all_zeros = (data == 4'b0);

    // Allocation logic
    always @(posedge clk) begin
        if (allocate_valid && !allocate_pending) begin
            // allocate the first available slot
            assign allocate_id = index;
            assign allocate_pending = 1'b1;
            assign allocate_previd = 32'hFFFF_FFF; // placeholder
            // allocate_rw = 1'b0; // but we need to handle data
            // allocate_data will be assigned later
            // We need to set the data fields? Actually the output signals are not fully defined.
            // For simplicity, we can leave data fields unset for now.
        end else if (allocate_pending) begin
            // mark as pending
            assign allocate_pending = 1'b0;
            assign allocate_ready = 1'b1;
        end
    end

endmodule
