module wishbone_to_ahb_bridge(
    input wire [31:0] addr_i,
    input wire [31:0] data_i,
    input wire [3:0] sel_i,
    input wire rst_i,
    input wire cyc_i,
    input wire stb_i,
    input wire we_i,
    output wire [31:0] data_o,
    output wire ack_o,
    output wire [1:0] htrans,
    output wire [2:0] hsize,
    output wire [2:0] hburst,
    output wire haddr,
    output wire hwdata
);

    // FSM states
    enum state { IDLE, NON-SEQUENTIAL, BUSY };
    reg state = IDLE;

    // Address and data buffers
    reg [31:0] ahb_addr;
    reg [31:0] ahb_data;
    reg [31:0] ahb_data_o;

    // Transaction control
    reg [2:0] hsize_val = 0;
    reg [1:0] htrans_val = 0;
    reg [1:0] hburst_val = 0;

    // Data conversion
    wire [31:0] temp_data;
    wire [31:0] temp_addr;

    // State transitions
    always @(posedge rst_i or posedge hreset_n) begin
        if (rst_i || hreset_n) begin
            state = IDLE;
            ahb_addr = 0;
            ahb_data = 0;
            ahb_data_o = 0;
            hsize_val = 0;
            htrans_val = 0;
            hburst_val = 0;
        end
    end

    // Address calculation
    always begin
        case (sel_i[3])
            1: ahb_addr = addr_i;
            2: ahb_addr = (addr_i >> 2);
            3: ahb_addr = (addr_i >> 4);
            default: ahb_addr = 0;
        endcase
    end

    // Data conversion
    always begin
        case (sel_i[3])
            1: ahb_data = data_i;
            2: ahb_data = (data_i >> 2);
            3: ahb_data = (data_i >> 4);
            default: ahb_data = 0;
        endcase
    end

    // Data handling
    always begin
        if (stb_i && cyc_i) begin
            if (state == IDLE) begin
                state = NON-SEQUENTIAL;
                haddr = ahb_addr;
                hwdata = ahb_data;
                hsize_val = sel_i[2];
                htrans_val = sel_i[1];
                hburst_val = 0;
            end else if (state == NON-SEQUENTIAL) begin
                if (hready) begin
                    state = BUSY;
                    ack_o = 1;
                    htrans = 3'b000;
                    hsize = 3'h000;
                    hburst = 3'h000;
                end
            end else if (state == BUSY) begin
                if (hready) begin
                    state = IDLE;
                    ack_o = 0;
                    htrans = 3'b000;
                    hsize = 3'h000;
                    hburst = 3'h000;
                end
            end
        end
    end