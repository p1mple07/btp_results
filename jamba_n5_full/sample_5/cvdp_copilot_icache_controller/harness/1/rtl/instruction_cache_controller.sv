// Top‑level controller for the instruction cache
module instruction_cache_controller (
    input  wire        clk,
    input  wire        rst,

    output reg         io_mem_valid,
    input  wire        io_mem_ready,
    output reg  [16:0] io_mem_addr,

    output reg         l1b_wait,
    output wire [31:0] l1b_data,
    input  wire [17:0] l1b_addr,

    // RAM256_T0 (Tag RAM 0)
    output wire       ram256_t0_we,
    output wire [7:0] ram256_t0_addr,
    input  wire [7:0] ram256_t0_data,

    // RAM256_T1 (Tag RAM 1)
    output wire       ram256_t1_we,
    output wire [7:0] ram256_t1_addr,
    input  wire [7:0] ram256_t1_data,

    // RAM512_D0 (Data RAM 0)
    output wire        ram512_d0_we,
    output wire [8:0]  ram512_d0_addr,
    input  wire [15:0] ram512_d0_data,

    // RAM512_D1 (Data RAM 1)
    output wire        ram512_d1_we,
    output wire [8:0]  ram512_d1_addr,
    input  wire [15:0] ram512_d1_data
);

    wire [15:0] data_0;
    wire [15:0] data_1;

    localparam TAG_BITS = 8;
    localparam ADR_BITS = 9;

    reg [2:0] state, next_state;
    reg [ADR_BITS-1:0] addr_0, addr_1;
    reg write_enable;

    wire [ADR_BITS-1:0] data_addr_0 = l1b_addr[17:9] + {{8'b0}, l1b_addr[0]};
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

    always @(*) begin
        data_0 = ram256_t0_data;
        data_1 = ram256_t1_data;
        tag_0 = ram256_t0_addr[TAG_BITS-1:0];
        tag_1 = ram256_t1_addr[TAG_BITS-1:0];
    end

    assign io_mem_valid = (l1b_addr[17:9] == tag_0) && valid_0 ||
                           (l1b_addr[17:9] == tag_1) && valid_1;

    assign io_mem_addr = data_addr_0[7:0];

    assign l1b_data = data_0 | data_1;

    assign l1b_wait = l1b_addr[17:9] == tag_0;

    assign ram256_t0_we = io_mem_ready;
    assign ram256_t1_we = io_mem_ready;

    assign ram512_d0_we = io_mem_ready;
    assign ram512_d1_we = io_mem_ready;

endmodule

// Tag controller for reading and writing tag data
module tag_controller (
    input wire clk,
    input wire rst,

    // Ports
    input wire       write_enable,
    input wire [8:0] write_addr,

    // Outputs
    output reg [8:0] data_0_out,
    input  wire [7:0] read_addr_0,

    output reg [8:0] data_1_out,
    input  wire [7:0] read_addr_1,

    // RAM
    output reg [7:0] ram_t0_we,
    output reg [7:0] ram_t1_we,

    input  reg       ram_t0_addr,
    input  reg       ram_t1_addr,
    input  reg [7:0] ram_t0_data,
    input  reg [7:0] ram_t1_data
);

    reg [511:0] RAM;

    wire [7:0] tag_0_data;
    wire [7:0] tag_1_data;

    wire [7:0] tag_addr_0 = write_enable ? write_addr[7:0] : read_addr_0;
    wire [7:0] tag_addr_1 = write_enable ? write_addr[7:0] : read_addr_1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RAM <= 0;
            ram_t0_we <= 1'b0;
            ram_t1_we <= 1'b0;
            ram_t0_addr <= 8'b0;
            ram_t1_addr <= 8'b0;
            data_0_out <= 9'b0;
            data_1_out <= 9'b0;
        end else if (write_enable) begin
            RAM[write_addr[7:0]] <= 1'b1;
        end
    end

    assign tag_0_data = RAM[tag_0_addr];
    assign tag_1_data = RAM[tag_1_addr];

    always @(*) begin
        data_0_out = tag_0_data;
        data_1_out = tag_1_data;
        data_0_out = tag_0_data;
        data_1_out = tag_1_data;
    end

endmodule
