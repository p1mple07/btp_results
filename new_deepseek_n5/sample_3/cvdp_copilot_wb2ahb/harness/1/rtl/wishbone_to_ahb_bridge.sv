module wishbone_to_ahb_bridge(
    input wire [31:0] wishbone_clk_i,
    input wire low rst_i,
    input wire [31:0] wishbone_addr_i,
    input wire [31:0] wishbone_data_i,
    input wire [3:0] wishbone_sel_i,
    input wire wishbone_stb_i,
    input wire wishbone_cyc_i,
    input wire wishbone_we_i,
    input wire [31:0] wishbone_addr_i,
    input wire [31:0] wishbone_data_i,
    output wire [31:0] ahb_data_o,
    output wire ahb_ack_o,
    output wire [1:0] ahb_htrans,
    output wire [2:0] ahb_hsize,
    output wire [2:0] ahb_hburst,
    output wire ahb_hwrite,
    output wire [31:0] ahb_haddr,
    output wire [31:0] ahb_hwdata
);

    // FSM states
    parameter FSM_STATE = 3;
    parameter FSM_IDLE = 0;
    parameter FSM_NONSEQUENTIAL = 1;
    parameter FSM_BUSY = 2;

    // State reg
    reg FSM_state = FSM_IDLE;
    reg FSM_done = FSM_IDLE;

    // Address reg
    reg [31:0] ahb_addr = 0;

    // Data reg
    reg [31:0] ahb_data = 0;
    reg [31:0] ahb_data_valid = 0;

    // Size reg
    reg [2:0] ahb_size = 0;

    // Burst reg
    reg [2:0] ahb_burst = 0;

    // Clock gate
    wire [31:0] ahb_addrclk = 0;
    wire [31:0] ahb_dataclk = 0;
    wire [31:0] ahbweclk = 0;

    // FSM transitions
    always @(posedge wishbone_clk_i or posedge ahb_hclk) begin
        if (rst_i) FSM_state = FSM_IDLE;
        else if (FSM_state == FSM_IDLE) begin
            if (wishbone_stb_i) FSM_state = FSM_NONSEQUENTIAL;
        end else if (FSM_state == FSM_NONSEQUENTIAL) begin
            if (wishbone_cyc_i) FSM_state = FSM_BUSY;
        end else if (FSM_state == FSM_BUSY) FSM_state = FSM_IDLE;
    end

    // Address handling
    always @* begin
        if (FSM_state == FSM_NONSEQUENTIAL && !rst_i) begin
            FSM_done = FSM_NONSEQUENTIAL;
            FSM_state = FSM_BUSY;
            FSM_done = FSM_BUSY;
        end
    end

    // Data handling
    always @* begin
        if (FSM_state == FSM_BUSY && !rst_i) begin
            FSM_done = FSM_BUSY;
            FSM_state = FSM_IDLE;
            FSM_done = FSM_IDLE;
        end
    end

    // Data conversion
    always @* begin
        if (FSM_state == FSM_NONSEQUENTIAL) begin
            FSM_done = FSM_NONSEQUENTIAL;
            FSM_state = FSM_BUSY;
            FSM_done = FSM_BUSY;
        end
    end

    // Signal holding
    always @* begin
        if (FSM_state == FSM_BUSY) begin
            ahb_addr = wishbone_addr_i;
            ahb_addrclk = 1;
            FSM_done = FSM_BUSY;
        end
    end

    // Data transfer
    always @* begin
        if (FSM_state == FSM_BUSY) begin
            FSM_done = FSM_BUSY;
            FSM_state = FSM_IDLE;
            FSM_done = FSM_IDLE;
        end
    end

    // Acknowledgement
    always @* begin
        if (FSM_state == FSM_BUSY) FSM_done = FSM_BUSY;
    end

    // FSM transitions
    always @* begin
        FSM_state = FSM_IDLE;
    end

    // AHB output
    ahb_htrans = FSM_state;
    ahb_hsize = FSM_state;
    ahb_hburst = FSM_state;
    ahb_hwrite = FSM_state;
    ahb_haddr = FSM_state;
    ahb_hwdata = FSM_state;

    // AHB output
    ahb_data_o = FSM_state;
    ahb_ack_o = FSM_state;
endmodule