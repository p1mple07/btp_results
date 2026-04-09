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

    assign data_0 = ram256_t0_data;
    assign data_1 = ram256_t1_data;

    assign l1b_data = data_0[7:0] + data_1[7:0];

    assign io_mem_valid = (state == READCACHE) ? 1'b1 : 1'b0;

    assign io_mem_addr = {ADR_BITS{1'b0}};

    assign l1b_wait = (state == READMEM0 || state == READMEM1);

endmodule

module tag_controller (
    input wire clk,
    input wire rst,

    // Port 0: Write operation (W)
    input wire       write_enable,
    input wire [8:0] write_addr,

    // Port 0: Read operation for address 0 (R)
    output reg [8:0] data_0_out,
    input  wire [7:0] read_addr_0,

    // Port 1: Read operation for address 1 (R)
    output reg [8:0] data_1_out,
    input  wire [7:0] read_addr_1,

    // RAM256_T0
    output reg       ram_t0_we,
    output reg [7:0] ram_t0_addr,
    input  wire [7:0] ram_t0_data,

    // RAM256_T1
    output reg       ram_t1_we,
    output reg [7:0] ram_t1_addr,
    input  wire [7:0] ram_t1_data,

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

    assign tag_0_data = ram_t0_data;
    assign tag_1_data = ram_t1_data;

    always @(*) begin
        data_0_out = tag_0_data;
        data_1_out = tag_1_data;

        assign data_0_valid = tag_0_data[TAG_BITS-1:0] == 1'b1;
        assign data_1_valid = tag_1_data[TAG_BITS-1:0] == 1'b1;

        assign data_0 = tag_0_data;
        assign data_1 = tag_1_data;

    end

endmodule
