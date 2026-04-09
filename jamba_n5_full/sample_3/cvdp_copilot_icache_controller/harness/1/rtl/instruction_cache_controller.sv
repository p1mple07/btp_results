module instruction_cache_controller (
    input  wire        clk,
    input  wire        rst,

    output reg         io_mem_valid,
    input  wire        io_mem_ready,
    output reg  [16:0] io_mem_addr,

    output reg         l1b_wait,
    output wire [31:0] l1b_data,
    input  wire [17:0] l1b_addr,

    // RAM256_T0 (Tag Memory 0)
    output wire       ram256_t0_we,
    output wire [7:0] ram256_t0_addr,
    input  wire [7:0] ram256_t0_data,

    // RAM256_T1 (Tag Memory 1)
    output wire       ram256_t1_we,
    output wire [7:0] ram256_t1_addr,
    input  wire [7:0] ram256_t1_data,

    // RAM512_D0 (Data Memory 0)
    output wire        ram512_d0_we,
    output wire [8:0]  ram512_d0_addr,
    input  wire [15:0] ram512_d0_data,

    // RAM512_D1 (Data Memory 1)
    output wire        ram512_d1_we,
    output wire [8:0]  ram512_d1_addr,
    input  wire [15:0] ram512_d1_data,
);

    wire [15:0] data_0;
    wire [15:0] data_1;

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
    always @(*) begin
        case (state)
            IDLE: begin
                if (io_mem_ready) begin
                    state <= READMEM0;
                end else begin
                    state <= IDLE;
                end
            end
            READMEM0: begin
                // Fetch first part of the cache line from memory
                next_state = READMEM1;
            end
            READMEM1: begin
                // Fetch second part of the cache line from memory
                next_state = READCACHE;
            end
            READCACHE: begin
                // Simulate data read and validity check
                data_0_ready = (l1b_addr[17:9] == tag_0) && valid_0;
                data_1_ready = (l1b_addr[17:9] == tag_1) && valid_1;
                // Update data_out accordingly
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
