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

    // Tag Controller interaction
    wire valid_0, valid_1;
    wire [TAG_BITS-1:0] tag_0, tag_1;

    assign valid_0 = ram256_t0_data[TAG_BITS-1:0] & ram256_t0_data[7:0];
    assign valid_1 = ram256_t1_data[TAG_BITS-1:0] & ram256_t1_data[7:0];

    assign tag_0 = ram256_t0_data[7:TAG_BITS];
    assign tag_1 = ram256_t1_data[7:TAG_BITS];

    // State machine logic
    localparam IDLE      = 3'd0,
               READMEM0  = 3'd1,
               READMEM1  = 3'd2,
               READCACHE = 3'd3;

    reg [2:0] state, next_state;
    reg [ADR_BITS-1:0] addr_0, addr_1;
    reg write_enable;

    assign data_addr_0 = l1b_addr[17:9] + {{8{1'b0}}, l1b_addr[0];
    assign data_addr_1 = l1b_addr[17:9];

    assign data_0_ready = (l1b_addr[17:9] == tag_0) && valid_0;
    assign data_1_ready = (l1b_addr[17:9] == tag_1) && valid_1;

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

    // State machine transitions
    always @(state or io_mem_ready) begin
        case ({state, io_mem_ready})
            IDLE: next_state = READMEM0;
            READMEM0: if (data_0_ready) next_state = READCACHE;
            READMEM1: if (data_1_ready) next_state = READCACHE;
            READCACHE: if (!data_0_ready && !data_1_ready) next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Drive outputs for memory
    assign ram256_t0_we = write_enable & (io_mem_addr[7:0] == addr_0);
    assign ram256_t1_we = write_enable & (io_mem_addr[7:0] == addr_1);
    assign ram512_d0_we = write_enable & (io_mem_addr[8:0] == ram512_d0_addr);
    assign ram512_d1_we = write_enable & (io_mem_addr[8:0] == ram512_d1_addr);

    // Data output adjustment for unaligned access
    always @(l1b_addr[0]) begin
        if (l1b_addr[0] & 1'b1) begin
            l1b_data[31:22] = data_0;
            l1b_data[21:0] = data_1;
        end else begin
            l1b_data = {data_0, data_1};
        end
    end

    // Tag Controller interface
    tag_controller tag_ctrl (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .write_addr(io_mem_addr[ADR_BITS-1:0]),
        .data_0_out(valid_0 ? {tag_0, tag_0_data} : 1'b0),
        .read_addr_0(data_addr_0[7:0]),
        .data_1_out(valid_1 ? {tag_1, tag_1_data} : 1'b0),
        .read_addr_1(data_addr_1[7:0]),
        .ram_t0_we(ram256_t0_we),
        .ram_t0_addr(ram256_t0_addr),
        .ram_t0_data(ram256_t0_data),
        .ram_t1_we(ram256_t1_we),
        .ram_t1_addr(ram256_t1_addr),
        .ram_t1_data(ram256_t1_data)
    );

endmodule
