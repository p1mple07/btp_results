module wishbone_to_ahb_bridge (
    input logic clk_i,
    input logic rst_i,
    input logic cyc_i,
    input logic stb_i,
    input logic [3:0] sel_i,
    input logic we_i,
    input logic [31:0] addr_i,
    input logic [31:0] data_i,
    output logic hclk,
    output logic hreset_n,
    output logic hrdata[31:0],
    output logic hresp[1:0],
    output logic hready,
    output logic htrans[1:0],
    output logic hsize[2:0],
    output logic hburst[2:0],
    output logic hwrite,
    output logic haddr[31:0],
    output logic hwdata[31:0]
);

    // Internal signals
    logic [31:0] wishbone_addr, wishbone_data;
    logic [31:0] ahb_addr;
    logic [31:0] ahb_data;
    logic ack_o, hwrite_o;

    // State machine for transaction phases
    typedef enum logic [2:0] {IDLE, NON_SEQUENTIAL, BUSY} transaction_state_t;
    transaction_state_t state = IDLE;

    // Functional blocks
    function logic [31:0] convert_address(input logic [31:0] addr, input logic [3:0] sel);
        return {(addr & ~(sel << 3)) | (addr & (sel << 3))};
    endfunction

    function logic [31:0] convert_data(input logic [31:0] data, input logic [3:0] sel);
        if (sel == 4'b0000)
            return data;
        else
            return {data[sel-1], data[sel], data[sel+1], data[sel+2], data[sel+3]};
    endfunction

    // Endian conversion functions
    function logic [31:0] little_to_big_endian(input logic [31:0] data);
        return {data[31], data[30], data[29], data[28], data[27], data[26], data[25],
                 data[24], data[23], data[22], data[21], data[20], data[19],
                 data[18], data[17], data[16], data[15], data[14], data[13],
                 data[12], data[11], data[10], data[9], data[8], data[7],
                 data[6], data[5], data[4], data[3], data[2], data[1],
                 data[0]};
    endfunction

    // State machine logic
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            state <= IDLE;
            ahb_addr <= 0;
            ahb_data <= 0;
            hready <= 0;
            ack_o <= 0;
            hwrite_o <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (cyc_i && stb_i) begin
                        state <= NON_SEQUENTIAL;
                        wishbone_addr = convert_address(addr_i, sel_i);
                        wishbone_data = convert_data(data_i, sel_i);
                    end
                end
                NON_SEQUENTIAL: begin
                    if (we_i) begin
                        ahb_addr = wishbone_addr;
                        ahb_data = little_to_big_endian(wishbone_data);
                        hready = 1;
                        state <= BUSY;
                    end
                end
                BUSY: begin
                    if (hready) begin
                        htrans = 2'b00;
                        hsize = 3'b000;
                        hburst = 3'b000;
                        hwrite_o = 1;
                        ahb_data = wishbone_data;
                        ack_o = 1;
                        hready = 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // Outputs
    assign hclk = clk_i;
    assign hreset_n = rst_i;
    assign hrdata = ahb_data;
    assign hresp = ack_o;
    assign hwrite = hwrite_o;
    assign haddr = ahb_addr;
    assign hwdata = ahb_data;

endmodule
