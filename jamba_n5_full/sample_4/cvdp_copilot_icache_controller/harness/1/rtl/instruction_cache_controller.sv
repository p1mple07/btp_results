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

    wire [ADR_BITS-1:0] data_addr_0 = l1b_addr[17:9] + {{8'b0}}, l1b_addr[0];
    wire [ADR_BITS-1:0] data_addr_1 = l1b_addr[17:9];

    wire valid_0, valid_1;
    wire [TAG_BITS-1:0] tag_0, tag_1;

    wire data_0_ready = (l1b_addr[17:9] == tag_0) && valid_0;
    wire data_1_ready = (l1b_addr[17:9] == tag_1) && valid_1;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else begin
            case (state)
                IDLE: begin
                    next_state = READMEM0;
                    addr_0 <= {ADR_BITS{1'b0}};
                    addr_1 <= {ADR_BITS{1'b0}};
                end
                READMEM0: begin
                    if (io_mem_ready) begin
                        write_enable <= 1'b1;
                    end else begin
                        write_enable <= 1'b0;
                    end
                    next_state = READMEM1;
                    addr_0 <= data_addr_0;
                    addr_1 <= data_addr_1;
                end
                READMEM1: begin
                    if (data_0_ready) data_0 <= ram256_t0_data;
                    if (data_1_ready) data_1 <= ram256_t1_data;
                    next_state = READCACHE;
                    addr_0 <= data_addr_0;
                    addr_1 <= data_addr_1;
                end
                READCACHE: begin
                    data_0 <= data_0_ready ? ram256_t0_data : 9'b0;
                    data_1 <= data_1_ready ? ram256_t1_data : 9'b0;
                    l1b_data <= {data_0[7:0], data_1[7:0]};
                    l1b_wait <= 0;
                    state <= IDLE;
                end
            endcase
        end
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


module tag_controller (
    input wire clk,
    input wire rst,

    // Ports
    input wire       write_enable,
    input wire [8:0] write_addr,

    // Outputs
    output reg [8:0] data_0_out,
    output reg [8:0] data_1_out,
    output reg write_enable_0,
    output reg write_enable_1,

    // RAM256_T0 registers
    output reg       ram_t0_we,
    output reg [7:0] ram_t0_addr,
    input  wire [7:0] ram_t0_data,

    // RAM256_T1 registers
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
        if (rst)
            RAM <= 0;
        else if (write_enable)
            RAM[write_addr[7:0]] <= 1'b1;
    end

    assign tag_0_data = ram_t0_data;
    assign tag_1_data = ram_t1_data;

    always @(*) begin
        data_0_out = tag_0_data;
        data_1_out = tag_1_data;

        wire valid_0 = tag_0_data[TAG_BITS-1] & tag_1_data[TAG_BITS-1];
        wire valid_1 = tag_0_data[TAG_BITS-1] & tag_1_data[TAG_BITS-1];

        wire valid_0_out = valid_0;
        wire valid_1_out = valid_1;

        assign data_0_out = {valid_0_out, tag_0_data[TAG_BITS-1]};
        assign data_1_out = {valid_1_out, tag_1_data[TAG_BITS-1]};

        assign valid_0_out = tag_0_data[TAG_BITS-1] & tag_1_data[TAG_BITS-1];
        assign valid_1_out = tag_0_data[TAG_BITS-1] & tag_1_data[TAG_BITS-1];

        assign write_enable_0 = write_enable ? 1'b1 : 1'b0;
        assign write_enable_1 = write_enable ? 1'b1 : 1'b0;

        assign ram_t0_we = write_enable_0;
        assign ram_t0_addr = tag_addr_0;
        assign ram_t0_data = data_0_out;

        assign ram_t1_we = write_enable_1;
        assign ram_t1_addr = tag_addr_1;
        assign ram_t1_data = data_1_out;
    end

endmodule
