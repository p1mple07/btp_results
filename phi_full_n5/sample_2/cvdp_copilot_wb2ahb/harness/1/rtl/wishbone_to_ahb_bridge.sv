module wishbone_to_ahb_bridge (
    input clk_i,
    input rst_i,
    input cyc_i,
    input stb_i,
    input [3:0] sel_i,
    input we_i,
    input [31:0] addr_i,
    input [31:0] data_i,
    output reg [31:0] data_o,
    output reg ack_o,
    output reg [1:0] hresp,
    output reg hready,
    output reg [31:0] haddr,
    output reg [31:0] hdata,
    output reg [2:0] hsize,
    output reg hwrite,
    output reg [3:0] hburst
);

    // Internal signals
    reg [31:0] ahrdata_i;
    reg [31:0] ahrdata_o;
    reg [2:0] hsize_reg;
    reg hsize_next;
    reg [1:0] hresp_next;
    reg [3:0] hburst_next;
    reg hwrite_next;

    // FSM states
    localparam IDLE = 0;
    localparam NON_SEQ = 1;
    localparam BUSY = 2;
    reg [2:0] fsm_state;

    // Reset logic
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            fsm_state <= IDLE;
            ahrdata_i <= 0;
            ahrdata_o <= 0;
            hsize_reg <= 4'b000;
            hsize_next <= 4'b000;
            hresp_next <= 2'b00;
            hresp <= 2'b00;
            hwrite_next <= 0;
            hwrite <= 0;
            hburst_next <= 4'b000;
            haddr <= 0;
            hdata <= 0;
            hsize <= 4'b000;
            hready <= 0;
        end else if (rst_i == 0) begin
            fsm_state <= IDLE;
            ahrdata_i <= 0;
            ahrdata_o <= 0;
            hsize_reg <= 4'b000;
            hsize_next <= 4'b000;
            hresp_next <= 2'b00;
            hresp <= 2'b00;
            hwrite_next <= 0;
            hwrite <= 0;
            hburst_next <= 4'b000;
            haddr <= 0;
            hdata <= 0;
            hsize <= 4'b000;
            hready <= 0;
        end else begin
            fsm_state <= fsm_state;
        end
    end

    // FSM logic
    always @(posedge clk_i or posedge cyc_i) begin
        case (fsm_state)
            IDLE: begin
                if (stb_i) begin
                    fsm_state <= NON_SEQ;
                    haddr <= addr_i;
                    hdata <= data_i;
                    hwrite_next <= we_i;
                    hsize_next <= hsize_reg;
                end
            end
            NON_SEQ: begin
                if (!hready) begin
                    fsm_state <= BUSY;
                end else begin
                    fsm_state <= IDLE;
                end
            end
            BUSY: begin
                ahrdata_o <= ahrdata_i;
                hdata <= ahrdata_o;
                hsize_next <= hsize_reg;
                hwrite_next <= hwrite;
                hresp_next <= hresp;
                hburst_next <= hburst_reg;
                fsm_state <= BUSY;
            end
        endcase
    end

    // Data handling
    always @(posedge clk_i) begin
        ahrdata_i <= data_o;
        ahrdata_o <= {ahrdata_i[31-sel_i:0], ahdata_i[31-sel_i:0]};
        hdata <= {ahrdata_o[31-sel_i:0], hdata};
        hsize_reg <= hsize_next;
    end

    // Control signals
    assign ack_o = hready & hresp_next;
    assign hresp = hresp_next;
    assign hwrite = hwrite_next;
    assign hburst = hburst_next;

    // Endian conversion
    always @(posedge clk_i) begin
        if (hwrite) begin
            case (sel_i)
                4'b0: haddr <= haddr;
                4'b1: haddr <= haddr >> 1;
                4'b2: haddr <= haddr >> 2;
                4'b3: haddr <= haddr >> 3;
                default: haddr <= 0;
            endcase
            hdata <= {hdata[31-sel_i:0], hdata};
        end
    end

endmodule
