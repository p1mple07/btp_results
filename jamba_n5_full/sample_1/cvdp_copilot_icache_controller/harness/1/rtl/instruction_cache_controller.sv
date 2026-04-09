module instruction_cache_controller (
    input  wire        clk,
    input  wire        rst,

    output reg         io_mem_valid,
    input  wire        io_mem_ready,
    output reg  [16:0] io_mem_addr,

    output reg         l1b_wait,
    output wire [31:0] l1b_data,
    input  wire [17:0] l1b_addr,

    // RAM256_T0
    output wire       ram256_t0_we,
    output wire [7:0] ram256_t0_addr,
    input  wire [7:0] ram256_t0_data,

    // RAM256_T1
    output wire       ram256_t1_we,
    output wire [7:0] ram256_t1_addr,
    input  wire [7:0] ram256_t1_data,

    // RAM512_D0
    output wire        ram512_d0_we,
    output wire [8:0]  ram512_d0_addr,
    input  wire [15:0] ram512_d0_data,

    // RAM512_D1
    output wire        ram512_d1_we,
    output wire [8:0]  ram512_d1_addr,
    input  wire [15:0] ram512_d1_data,

    // Output signals
    output reg         data_0,
    output reg         data_1,
    output reg [7:0]  l1b_data,
    output reg          io_mem_valid,
    output reg [31:0] l1b_addr,
    output reg [8:0]  l1b_data,
    output reg          ram256_t0_we,
    output reg [7:0]  ram256_t0_addr,
    output reg [7:0]  ram256_t1_we,
    output reg [7:0]  ram256_t1_addr,
    output reg [7:0]  ram512_d0_we,
    output reg [7:0]  ram512_d0_addr,
    output reg [7:0]  ram512_d1_we,
    output reg [7:0]  ram512_d1_addr,

    output reg data_0,
    output reg data_1,
    output reg io_mem_valid,
    output reg l1b_wait,
    output reg l1b_data,
    output reg ram256_t0_we,
    output reg ram256_t0_addr,
    output reg ram256_t1_we,
    output reg ram256_t1_addr,
    output reg ram512_d0_we,
    output reg ram512_d0_addr,
    output reg ram512_d1_we,
    output reg ram512_d1_addr,

    input  wire        clk,
    input  wire        rst,

    input  wire        io_mem_ready,
    input  wire        [17:0] l1b_addr,

    input  wire [15:0] ram256_t0_data,
    input  wire [15:0] ram256_t1_data,
    input  wire [15:0] ram512_d0_data,
    input  wire [15:0] ram512_d1_data,

    output reg        ram_t0_we,
    output reg [7:0] ram_t0_addr,
    input  wire        ram_t0_data,

    output reg        ram_t1_we,
    output reg [7:0] ram_t1_addr,
    input  wire        ram_t1_data,
);

// State machine registers
reg [2:0] state, next_state;
reg write_enable;
reg [8:0] data_addr_0, data_addr_1;
reg [7:0] data_0_ready, data_1_ready;

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

// Extract tag and data from RAM
wire [ADR_BITS-1:0] data_addr_0 = l1b_addr[17:9] + {{8'b0}}, l1b_addr[0];
wire [ADR_BITS-1:0] data_addr_1 = l1b_addr[17:9];
wire [7:0] tag_0_data;
wire [7:0] tag_1_data;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tag_0_data <= 0;
        tag_1_data <= 0;
    end else if (write_enable) begin
        RAM[write_addr[7:0]] <= 1'b1;
    end
end

assign tag_0_data = ram_t0_data;
assign tag_1_data = ram_t1_data;

// Check cache hit/miss
always @(*) begin
    case (state)
        IDLE: begin
            if (io_mem_ready) begin
                state <= READMEM0;
                next_state = READMEM0;
            end else
                next_state = IDLE;
        end
        READMEM0: begin
            if (io_mem_ready) begin
                data_0_ready <= true;
                data_1_ready <= true;
                state <= READMEM1;
            end else
                state <= IDLE;
        end
        READMEM1: begin
            if (io_mem_ready) begin
                state <= READCACHE;
            end else
                state <= IDLE;
        end
        READCACHE: begin
            data_0 <= tag_0_data;
            data_1 <= tag_1_data;
            data_0_ready <= true;
            data_1_ready <= true;
            state <= READMEM1;
        end
        READMEM1: begin
            if (io_mem_ready) begin
                l1b_data[31:0] = data_0 | data_1;
                io_mem_valid <= 1'b1;
            end else
                state <= IDLE;
        end
    endcase
end

// Tag controller
module tag_controller (
    input wire clk,
    input wire rst,

    output reg write_enable,
    input wire [8:0] write_addr,

    output reg [8:0] data_0_out,
    output reg [8:0] data_1_out,
    output reg l1b_wait,
    output reg [7:0] data_0,
    output reg [7:0] data_1,
    output reg io_mem_valid,
    output reg [31:0] l1b_addr,

    output reg ram_t0_we,
    output reg [7:0] ram_t0_addr,
    input  wire ram_t0_data,

    output reg ram_t1_we,
    output reg [7:0] ram_t1_addr,
    input  wire ram_t1_data,

);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        write_enable <= 1'b0;
        ram_t0_we <= 1'b0;
        ram_t1_we <= 1'b0;
        ram_t0_addr <= 8'b0;
        ram_t1_addr <= 8'b0;
        data_0_out <= 9'b0;
        data_1_out <= 9'b0;
        l1b_wait <= 1'b1;
        io_mem_valid <= 1'b0;
    end else if (write_enable) begin
        RAM[write_addr[7:0]] <= 1'b1;
    end
end

assign tag_0_data = ram_t0_data;
assign tag_1_data = ram_t1_data;

always @(*) begin
    data_0_out = tag_0_data;
    data_1_out = tag_1_data;
    l1b_wait <= 1'b0;
    io_mem_valid <= 1'b1;
end
