module instruction_cache_controller (
    input  wire        clk,                // Clock signal
    input  wire        rst,                // Reset signal

    output reg         io_mem_valid,       // Indicates that memory operation is valid
    output reg         io_mem_ready,       // Indicates that memory is ready for the operation
    output reg  [16:0] io_mem_addr,        // Address for memory operation

    output reg         l1b_wait,           // Indicates if the L1 cache is still waiting for data
    output wire [31:0] l1b_data,           // Data output from the L1 cache
    input  wire [17:0] l1b_addr,           // Address of the L1 cache (18-bits)

    // RAM256_T0 (Tag Memory 0)
    output wire       ram256_t0_we,        // Write enable for the RAM256_T0 (Tag RAM 0)
    output wire [7:0] ram256_t0_addr,      // Address for the RAM256_T0 (Tag RAM 0)
    input  wire [7:0] ram256_t0_data,      // Data read from the RAM256_T0 (Tag RAM 0)
    // RAM256_T1 (Tag Memory 1)
    output wire       ram256_t1_we,        // Write enable for the RAM256_T1 (Tag RAM 1)
    output wire [7:0] ram256_t1_addr,      // Address for the RAM256_T1 (Tag RAM 1)
    input  wire [7:0] ram256_t1_data,      // Data read from the RAM256_T1 (Tag RAM 1)
    // RAM512_D0 (Data Memory 0)
    output wire        ram512_d0_we,       // Write enable for the RAM512_D0 (Data RAM 0)
    output wire [8:0]  ram512_d0_addr,     // Address for the RAM512_D0 (Data RAM 0)
    input  wire [15:0] ram512_d0_data,     // Data read from the RAM512_D0 (Data RAM 0)
    // RAM512_D1 (Data Memory 1)
    output wire        ram512_d1_we,       // Write enable for the RAM512_D1 (Data RAM 1)
    input  wire [15:0] ram512_d1_data      // Data read from the RAM512_D1 (Data RAM 1)
);
    wire [15:0] data_0;
    wire [15:0] data_1;

    // Unaligned access handling
    assign ram512_d0_addr = ram512_d0_we ? ram512_d0_addr : ram512_d1_addr;

    // Tag and data validation signals
    reg [TAG_BITS-1:0] tag_0, tag_1;
    reg [ADR_BITS-1:0] addr_0, addr_1;
    reg write_enable;

    assign valid_0 = (l1b_addr[17:9] == tag_0) & (ram256_t0_data[7:0] == tag_0);
    assign valid_1 = (l1b_addr[17:9] == tag_1) & (ram256_t1_data[7:0] == tag_1);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            write_enable <= 1'b0;
            addr_0 <= {ADR_BITS{1'b0}};
            addr_1 <= {ADR_BITS{1'b0}};
        end else begin
            if ((state == READMEM0 || state == READMEM1) && io_mem_ready) begin
                write_enable <= 1'b1;
            end else begin 
                write_enable <= 1'b0;
            end
            state <= next_state;
            addr_0 <= data_addr_0;
            addr_1 <= data_addr_1;
        end
    end

    // State machine logic
    always @(state, io_mem_ready, valid_0, valid_1) begin
        case (state)
            IDLE: begin
                if (io_mem_ready & !valid_0) begin
                    state <= READMEM0;
                end else if (io_mem_ready & !valid_1) begin
                    state <= READMEM1;
                end else begin
                    state <= READCACHE;
                end
            end
            READMEM0: begin
                if (valid_0) begin
                    state <= READCACHE;
                end else begin
                    state <= IDLE;
                end
            end
            READMEM1: begin
                if (valid_1) begin
                    state <= READCACHE;
                end else begin
                    state <= IDLE;
                end
            end
            READCACHE: begin
                if (valid_0 & valid_1) begin
                    l1b_data <= {data_0, data_1};
                    io_mem_valid <= 1'b1;
                    state <= IDLE;
                end else begin
                    l1b_wait <= 1'b1;
                end
            end
        end
    end

    // Memory operation logic
    always @(posedge clk) begin
        if (io_mem_ready & write_enable) begin
            ram256_t0_we <= ram256_t0_we;
            ram256_t0_addr <= ram256_t0_addr;
            ram256_t1_we <= ram256_t1_we;
            ram256_t1_addr <= ram256_t1_addr;
            ram256_t1_data <= ram256_t1_data;

            ram512_d0_we <= ram512_d0_we;
            ram512_d0_addr <= ram512_d0_addr;
            ram512_d1_we <= ram512_d1_we;
            ram512_d1_addr <= ram512_d1_addr;
            ram512_d1_data <= ram512_d1_data;
        end
    end

    // Tag controller interaction
    always @(posedge clk) begin
        if (io_mem_ready) begin
            ram_t0_we <= ram256_t0_we;
            ram_t0_addr <= ram256_t0_addr;
            ram_t0_data <= ram256_t0_data;
            ram_t1_we <= ram256_t1_we;
            ram_t1_addr <= ram256_t1_addr;
            ram_t1_data <= ram256_t1_data;
        end
    end

endmodule
