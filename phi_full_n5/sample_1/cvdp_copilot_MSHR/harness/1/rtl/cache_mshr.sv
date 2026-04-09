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

    reg [DATA_WIDTH-1:0] entry_valid_table_q [MSHR_SIZE-1:0];
    reg [MSHR_ADDR_WIDTH-1:0] next_idx_table [MSHR_SIZE-1:0];
    reg [WORD_SEL_WIDTH-1:0] write_data [MSHR_SIZE-1:0];
    reg [WORD_SEL_WIDTH-1:0] byte_enable_signal [MSHR_SIZE-1:0];
    reg [CS_LINE_ADDR_WIDTH-1:0] cache_line_addr [MSHR_SIZE-1:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < MSHR_SIZE; i = i + 1) begin
                entry_valid_table_q[i] <= 0;
                next_idx_table[i] <= 0;
                write_data[i] <= 0;
                byte_enable_signal[i] <= 0;
                cache_line_addr[i] <= 0;
            end
        end else begin
            if (allocate_valid) begin
                cache_line_addr[next_idx_table[allocate_id]] = allocate_addr;
                write_data[next_idx_table[allocate_id]] = allocate_data;
                byte_enable_signal[next_idx_table[allocate_id]] = allocate_rw;
                entry_valid_table_q[next_idx_table[allocate_id]] <= 1;
                next_idx_table[allocate_id] <= next_idx;
            end
        end
    end

    always @(posedge clk) begin
        integer next_idx, next_idx_update;
        foreach (entry_valid_table_q[i]) begin
            if (entry_valid_table_q[i] && !allocate_pending) begin
                next_idx = next_idx_table[i];
                if (next_idx != 0) begin
                    next_idx_update = next_idx_table[next_idx];
                    if (next_idx_update == 0) begin
                        next_idx_table[i] = 0;
                        allocate_pending <= 1;
                    end else begin
                        next_idx_table[i] = next_idx_update;
                    end
                end
            end
        end
    end

    // Finalize logic
    always @(posedge clk or posedge reset) begin
        if (finalize_valid) begin
            integer finalize_idx;
            foreach (cache_line_addr[i]) begin
                if (entry_valid_table_q[i]) begin
                    finalize_idx = i;
                    entry_valid_table_q[i] <= 0;
                    cache_line_addr[i] <= finalize_id;
                end
            end
        end
    end

endmodule
