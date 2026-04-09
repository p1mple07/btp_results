module instruction_cache_controller (
    input  wire        clk,                // Clock signal
    input  wire        rst,                // Reset signal

    output reg         io_mem_valid,       // Indicates that memory operation is valid
    input  wire        io_mem_ready,       // Indicates that memory is ready for the operation
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
    output wire [8:0]  ram512_d1_addr,     // Address for the RAM512_D1 (Data RAM 1)
    input  wire [15:0] ram512_d1_data      // Data read from the RAM512_D1 (Data RAM 1)
);
    wire [15:0] data_0;
    wire [15:0] data_1;

    // Unaligned access handling
    wire [15:0] addr_0_valid = (io_mem_addr[17:9] == l1b_addr[17:9] + 1) & io_mem_ready;
    wire [15:0] addr_1_valid = (io_mem_addr[17:9] == l1b_addr[17:9]) & io_mem_ready;

    // State machine logic
    localparam TAG_BITS = 8;
    localparam ADR_BITS = 9;

    localparam IDLE      = 3'd0,
               READMEM0  = 3'd1,
               READMEM1  = 3'd2,
               READCACHE = 3'd3;

    reg [2:0] state, next_state;
    reg [ADR_BITS-1:0] addr_0, addr_1;
    reg write_enable;

    wire [ADR_BITS-1:0] data_addr_0 = l1b_addr[17:9] + {{8{1'b0}}, l1b_addr[0]};
    wire [ADR_BITS-1:0] data_addr_1 = l1b_addr[17:9];

    wire valid_0, valid_1;
    wire [TAG_BITS-1:0] tag_0, tag_1;

    wire data_0_ready = (l1b_addr[17:9] == tag_0) && valid_0;
    wire data_1_ready = (l1b_addr[17:9] == tag_1) && valid_1;

    // Drive outputs for memory
    wire [15:0] io_mem_data = (data_0_ready ? data_0 : data_1_ready ? data_1 : 0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            write_enable <= 1'b0;
            addr_0 <= {ADR_BITS{1'b0}};
            addr_1 <= {ADR_BITS{1'b0}};
        end else begin
            if ((state == READMEM0 || state == READMEM1) && io_mem_ready) begin
                write_enable <= 1'b1;
            end else 
                write_enable <= 1'b0;
            end

            case (state)
                IDLE:
                    if (io_mem_ready) begin
                        state = READMEM0;
                        addr_0 = data_addr_0;
                        addr_1 = data_addr_1;
                    end
                    else
                        state = IDLE;
                    end

                READMEM0:
                    if (data_0_ready && data_1_ready) begin
                        // Valid data from both memories
                        state = READCACHE;
                    else 
                        state = IDLE;
                    end

                READMEM1:
                    if (data_1_ready) begin
                        // Valid data from second memory
                        state = READCACHE;
                    else 
                        state = IDLE;
                    end

                READCACHE:
                    if (io_mem_ready) begin
                        state = IDLE;
                    else 
                        state = READCACHE;
                    end
            end
        end
    end

    // Tag Controller Integration
    tag_controller tag_ctrl (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .write_addr(io_mem_addr[ADR_BITS-1:0]),
        .data_0_out({valid_0, tag_0}),
        .read_addr_0(data_addr_0[7:0]),
        .data_1_out({valid_1, tag_1}),
        .read_addr_1(data_addr_1[7:0]),
        .ram_t0_we(ram256_t0_we),
        .ram_t0_addr(ram256_t0_addr),
        .ram_t0_data(ram256_t0_data),
        .ram_t1_we(ram256_t1_we),
        .ram_t1_addr(ram256_t1_addr),
        .ram_t1_data(ram256_t1_data)
    );
endmodule