module wishbone_to_ahb_bridge(
    input wire clk_i,
    input wire rst_i,
    input wire cyc_i,
    input wire stb_i,
    input wire [3:0] sel_i,
    input wire we_i,
    input wire [31:0] addr_i,
    input wire [31:0] data_i,
    output reg ack_o,
    output reg [31:0] data_o,
    output reg [1:0] hresp,
    output reg hready,
    output reg [31:0] haddr,
    output reg [31:0] hdata,
    output reg [2:0] hsize,
    output reg hwrite,
    output reg hburst
);

    // Internal signals
    reg [31:0] wb_data;
    reg [31:0] wb_addr;
    reg [31:0] ahb_data;
    reg [31:0] ahb_addr;
    reg [2:0] hsize_reg;
    reg [2:0] hburst_reg;
    reg [1:0] htrans_reg;

    // State machine for managing transaction phases
    localparam IDLE = 0, NON_SEQUENTIAL = 1, BUSY = 2;
    reg [2:0] state, next_state;

    // Endian conversion logic
    function [31:0] convert_to_little_endian(input [31:0] data);
        return {data[31], data[30], data[29], data[28], data[27], data[26], data[25], data[24], data[23], data[22], data[21], data[20], data[19], data[18], data[17], data[16], data[15], data[14], data[13], data[12], data[11], data[10], data[9], data[8], data[7], data[6], data[5], data[4], data[3], data[2], data[1], data[0]};
    endfunction

    function [31:0] convert_to_big_endian(input [31:0] data);
        return {data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15], data[16], data[17], data[18], data[19], data[20], data[21], data[22], data[23], data[24], data[25], data[26], data[27], data[28], data[29], data[30], data[31]};
    endfunction

    // FSM implementation
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            state <= IDLE;
            wb_data <= 0;
            wb_addr <= 0;
            ahb_data <= 0;
            ahb_addr <= 0;
            ack_o <= 0;
            hready <= 0;
            hwrite <= 0;
            hburst <= 3'b000;
            hsize_reg <= 3'b000;
            haddr_reg <= 0;
            hdata_reg <= 0;
            hresp_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (cyc_i && stb_i) begin
                        wb_addr <= addr_i;
                        wb_data <= data_i;
                        state <= NON_SEQUENTIAL;
                    end
                end
                NON_SEQUENTIAL: begin
                    wb_data <= convert_to_big_endian(wb_data);
                    wb_addr <= convert_to_big_endian(wb_addr);
                    ahb_addr <= convert_to_little_endian(wb_addr) & (sel_i << 5);
                    ahb_data <= convert_to_little_endian(wb_data) & (sel_i << (32 - sel_i));
                    state <= BUSY;
                end
                BUSY: begin
                    if (we_i) begin
                        ahb_data <= ahb_data;
                        ahb_addr <= ahb_addr;
                        hwrite <= 1;
                        hsize_reg <= hsize;
                        hburst_reg <= hburst;
                        haddr_reg <= ahb_addr;
                        hdata_reg <= ahb_data;
                        hresp_reg <= 0;
                        hready <= 1;
                    end else begin
                        hwrite <= 0;
                        hresp_reg <= 1;
                    end
                    state <= NON_SEQUENTIAL;
                end
            endcase
        end
    end

    // Output logic
    assign data_o = convert_to_little_endian(ahb_data);
    assign ack_o = hresp_reg;
    assign haddr = ahb_addr;
    assign hdata = ahb_data;
    assign hsize = hsize_reg;
    assign hburst = hburst_reg;
    assign hwrite = hwrite;
    assign hready = hready;

endmodule
