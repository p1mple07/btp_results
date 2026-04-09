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
    output wire [8:0]  ram516_d1_addr,     // Address for the RAM512_D1 (Data RAM 1)
    input  wire [15:0] ram512_d1_data      // Data read from the RAM512_D1 (Data RAM 1)
);
    wire [15:0] data_0;
    wire [15:0] data_1;

    // Unaligned access handling
    assign data_0 = ram512_d0_data;
    assign data_1 = ram512_d1_data;

    localparam TAG_BITS = 8;
    localparam ADR_BITS = 9;

    localparam IDLE      = 3'd0,
               READMEM0  = 3'd1,
               READMEM1  = 3'd2,
               READCACHE = 3'd3;

    reg [2:0] state, next_state;
    reg [ADR_BITS-1:0] addr_0, addr_1;
    reg write_enable;

    wire valid_0, valid_1;
    wire [TAG_BITS-1:0] tag_0, tag_1;

    wire data_0_ready = (l1b_addr[17:9] == tag_0) && valid_0;
    wire data_1_ready = (l1b_addr[17:9] == tag_1) && valid_1;


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
    always @(state, io_mem_ready) begin
        case({state, io_mem_ready})
            {IDLE, 1'b0} : begin
                next_state = READMEM0;
            end
            {READMEM0, 1'b1} : begin
                next_state = READMEM1;
            end
            {READMEM1, 1'b1} : begin
                next_state = READCACHE;
            end
            // Add additional states and transitions as required
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Drive outputs for memory
    always @(io_mem_ready or ram256_t0_we or ram256_t1_we) begin
        case({io_mem_ready, ram256_t0_we, ram256_t1_we})
            {1'b0, 1'b0, 1'b0} : begin
                l1b_data = {ram512_d0_data, ram512_d1_data}; // Unaligned access, combine both halves
            end
            // Add additional memory operation cases as required
            default: begin
                l1b_data = 32'b0; // Default case, handle errors or invalid states
            end
        endcase
    end


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
