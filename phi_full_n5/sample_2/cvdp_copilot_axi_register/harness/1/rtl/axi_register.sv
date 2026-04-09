module axi_register #(parameter ADDR_WIDTH=32, DATA_WIDTH=32)
(
    input clk,
    input rst_n,
    input [ADDR_WIDTH-1:0] awaddr,
    input awvalid,
    input [DATA_WIDTH-1:0] wdata,
    input wvalid,
    input [ADDR_WIDTH/8-1:0] wstrb,
    input bready,
    input [ADDR_WIDTH-1:0] araddr,
    input arvalid,
    output reg rready,
    output reg [DATA_WIDTH-1:0] rdata,
    output reg rvalid,
    output reg [1:0] bresp,
    output reg bvalid,
    output reg [1:0] rresp,
    output reg beat,
    output reg start,
    output reg writeback
);

    // Registers
    reg [ADDR_WIDTH-1:0] beat_reg;
    reg [31:0] id_reg;

    // State machine
    reg [2:0] state, next_state;

    // Functional blocks
    function [DATA_WIDTH-1:0] read_beat();
        return beat_reg[DATA_WIDTH-1:0];
    endfunction

    function void write_beat(input [DATA_WIDTH-1:0] data);
        beat_reg = data;
    endfunction

    function void read_id();
        id_reg = 32'h0001_0001; // Fixed ID value
    endfunction

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            state <= ID_STATE;
            beat <= 0;
            start <= 0;
            writeback <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(state) begin
        case (state)
            ID_STATE: begin
                if (arvalid) begin
                    read_id();
                    rready <= 1;
                    next_state <= WRITE_STATE;
                end else begin
                    next_state <= ID_STATE;
                end
            end
            WRITE_STATE: begin
                if (awvalid) begin
                    if (wvalid) begin
                        write_beat(wdata);
                        start <= wdata[0];
                        writeback <= wdata[0];
                        rready <= 1;
                        next_state <= READ_STATE;
                    end else begin
                        bresp <= 2'b00; // OKAY
                        bvalid <= 1;
                        next_state <= READ_STATE;
                    end
                end else begin
                    bresp <= 2'b10; // SLVERR
                    bvalid <= 0;
                    next_state <= WRITE_STATE;
                end
            end
            READ_STATE: begin
                if (arvalid) begin
                    rdata <= read_beat();
                    rvalid <= 1;
                    rready <= 1;
                    next_state <= READ_STATE;
                end else begin
                    rresp <= 2'b00; // OKAY
                    next_state <= READ_STATE;
                end
            end
        endcase
    end

    // Interrupt or continuous assignments for outputs
    assign beat_o = beat;
    assign start_o = start;
    assign writeback_o = writeback;
    assign rdata_o = rdata;
    assign rvalid_o = rvalid;
    assign rresp_o = rresp;
    assign bresp_o = bresp;
    assign bvalid_o = bvalid;

endmodule
