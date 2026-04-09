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
    output wire [8:0]  ram512_d1_addr,     // Address for the RAM512_D1 (Data RAM 1)
    input  wire [15:0] ram512_d1_data      // Data read from the RAM512_D1 (Data RAM 1)
);
    wire [15:0] data_0;
    wire [15:0] data_1;

    // State machine logic
    reg [2:0] state, next_state;
    reg [ADR_BITS-1:0] addr_0, addr_1;
    reg write_enable;

    assign valid_0 = (l1b_addr[17:9] == ram256_t0_data) & (l1b_addr[8] == ram256_t1_data);
    assign data_0_ready = valid_0;
    assign data_1_ready = (l1b_addr[17:9] == ram256_t1_data) & (l1b_addr[8] == ram512_d0_data);

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

    // Unaligned access handling
    always @(io_mem_ready) begin
        if (io_mem_ready) begin
            case({l1b_addr[17], l1b_addr[16]})
                '00: addr_0 <= data_addr_0;
                '01: addr_0 <= data_addr_1;
                '10: addr_1 <= data_addr_0;
                '11: addr_1 <= data_addr_1;
            endcase
        end
    end

    // State transitions
    always @(state, io_mem_ready) begin
        case {state, io_mem_ready}
            IDLE: begin
                next_state = io_mem_ready ? READMEM0 : IDLE;
            end
            READMEM0: begin
                next_state = io_mem_ready ? READMEM1 : READMEM0;
            end
            READMEM1: begin
                next_state = io_mem_ready ? READCACHE : READMEM1;
            end
            READCACHE: begin
                if (data_0_ready) begin
                    io_mem_addr <= ram512_d0_addr;
                    l1b_data <= {ram512_d0_data, ram512_d1_data};
                    l1b_wait <= 1'b0;
                end else begin
                    l1b_wait <= 1'b1;
                end
            end
        end
    end

    // Drive outputs for memory
    always @(ram256_t0_we | ram256_t1_we | ram512_d0_we | ram512_d1_we) begin
        if (ram256_t0_we) ram_t0_addr <= ram256_t0_addr;
        if (ram256_t1_we) ram_t1_addr <= ram256_t1_addr;
        if (ram512_d0_we) ram512_d0_addr <= ram512_d0_addr;
        if (ram512_d1_we) ram512_d1_addr <= ram512_d1_addr;
    end

    // Tag controller interaction
    always @(ram256_t0_we | ram256_t1_we) begin
        if (ram256_t0_we) begin
            tag_ctrl.ram_t0_we <= ram256_t0_we;
            tag_ctrl.ram_t0_addr <= ram256_t0_addr;
            tag_ctrl.ram_t0_data <= ram256_t0_data;
        end
        if (ram256_t1_we) begin
            tag_ctrl.ram_t1_we <= ram256_t1_we;
            tag_ctrl.ram_t1_addr <= ram256_t1_addr;
            tag_ctrl.ram_t1_data <= ram256_t1_data;
        end
    end

endmodule
